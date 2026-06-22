import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ScanAssetScreen extends StatefulWidget {
  const ScanAssetScreen({super.key});

  @override
  State<ScanAssetScreen> createState() => _ScanAssetScreenState();
}

class _ScanAssetScreenState extends State<ScanAssetScreen>
    with TickerProviderStateMixin {
  // ── Camera ──────────────────────────────────────────────────────────────────
  CameraController? _camCtrl;
  List<CameraDescription> _cameras = [];
  bool _cameraReady = false;
  int _camIndex = 0;

  // ── Flash ────────────────────────────────────────────────────────────────────
  FlashMode _flashMode = FlashMode.auto;
  final _flashModes = [FlashMode.auto, FlashMode.always, FlashMode.off];
  final _flashIcons = [
    Icons.flash_auto_rounded,
    Icons.flash_on_rounded,
    Icons.flash_off_rounded,
  ];

  // ── Zoom ─────────────────────────────────────────────────────────────────────
  double _zoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 5.0;
  double _baseZoom = 1.0;

  // ── Focus tap ────────────────────────────────────────────────────────────────
  Offset? _focusPoint;
  late AnimationController _focusCtrl;
  late Animation<double> _focusScale;
  late Animation<double> _focusOpacity;

  // ── Photos ───────────────────────────────────────────────────────────────────
  final List<XFile> _photos = [];
  final ImagePicker _picker = ImagePicker();

  // ── Shutter press animation ──────────────────────────────────────────────────
  late AnimationController _shutterCtrl;
  late Animation<double> _shutterScale;

  // ── Flash blink animation ────────────────────────────────────────────────────
  late AnimationController _blinkCtrl;
  late Animation<double> _blinkOpacity;

  // ── Bottom panel slide-up ────────────────────────────────────────────────────
  late AnimationController _panelCtrl;
  late Animation<double> _panelAnim;

  // ── Flip animation ───────────────────────────────────────────────────────────
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _focusCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _focusScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOut));
    _focusOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_focusCtrl);

    _shutterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _shutterScale = Tween(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _shutterCtrl, curve: Curves.easeIn));

    _blinkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _blinkOpacity = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _blinkCtrl, curve: Curves.easeOut));

    _panelCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _panelAnim =
        CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOutExpo);

    _flipCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _flipAnim = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      await _startCamera(_camIndex);
    } catch (_) {
      if (mounted) setState(() => _cameraReady = false);
    }
  }

  Future<void> _startCamera(int index) async {
    final prev = _camCtrl;
    _camCtrl = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _camCtrl!.initialize();
    await prev?.dispose();
    if (!mounted) return;
    _minZoom = await _camCtrl!.getMinZoomLevel();
    _maxZoom = await _camCtrl!.getMaxZoomLevel();
    _zoom = _minZoom;
    await _camCtrl!.setFlashMode(_flashMode);
    setState(() => _cameraReady = true);
    _panelCtrl.forward();
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    _flipCtrl.forward(from: 0);
    final next = (_camIndex + 1) % _cameras.length;
    setState(() {
      _cameraReady = false;
      _camIndex = next;
    });
    await _startCamera(next);
  }

  Future<void> _cycleFlash() async {
    if (_camCtrl == null || !_cameraReady) return;
    final i = (_flashModes.indexOf(_flashMode) + 1) % _flashModes.length;
    setState(() => _flashMode = _flashModes[i]);
    try {
      await _camCtrl!.setFlashMode(_flashMode);
    } catch (_) {}
  }

  Future<void> _onTapFocus(TapUpDetails details, BoxConstraints constraints) async {
    if (_camCtrl == null || !_cameraReady) return;
    final size = constraints.biggest;
    final offset = details.localPosition;
    setState(() => _focusPoint = offset);
    _focusCtrl.forward(from: 0);
    final x = (offset.dx / size.width).clamp(0.0, 1.0);
    final y = (offset.dy / size.height).clamp(0.0, 1.0);
    try {
      await _camCtrl!.setFocusPoint(Offset(x, y));
      await _camCtrl!.setExposurePoint(Offset(x, y));
    } catch (_) {}
  }

  Future<void> _onScaleUpdate(ScaleUpdateDetails d) async {
    if (_camCtrl == null || !_cameraReady) return;
    final newZoom = (_baseZoom * d.scale).clamp(_minZoom, _maxZoom);
    setState(() => _zoom = newZoom);
    try {
      await _camCtrl!.setZoomLevel(newZoom);
    } catch (_) {}
  }

  void _onScaleStart(ScaleStartDetails d) {
    _baseZoom = _zoom;
  }

  Future<void> _capture() async {
    if (_camCtrl == null || !_cameraReady) return;
    // Animate shutter
    await _shutterCtrl.forward();
    _shutterCtrl.reverse();
    // Flash blink
    _blinkCtrl.forward(from: 0).then((_) => _blinkCtrl.reverse());
    try {
      final file = await _camCtrl!.takePicture();
      if (mounted) setState(() => _photos.insert(0, file));
    } catch (_) {}
  }

  Future<void> _pickGallery() async {
    final result = await _picker.pickMultiImage(imageQuality: 90);
    if (result.isNotEmpty && mounted) {
      setState(() {
        for (final img in result) {
          if (!_photos.any((e) => e.path == img.path)) {
            _photos.insert(0, img);
          }
        }
      });
    }
  }

  void _removePhoto(int i) => setState(() => _photos.removeAt(i));

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _camCtrl?.dispose();
    _focusCtrl.dispose();
    _shutterCtrl.dispose();
    _blinkCtrl.dispose();
    _panelCtrl.dispose();
    _flipCtrl.dispose();
    super.dispose();
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCamera(),
          _buildFlashBlink(),
          _buildFocusIndicator(),
          _buildTopBar(),
          _buildZoomLabel(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, 1), end: Offset.zero)
                  .animate(_panelAnim),
              child: _buildBottomPanel(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Camera preview ───────────────────────────────────────────────────────────
  Widget _buildCamera() {
    if (!_cameraReady || _camCtrl == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white24),
              ),
              const SizedBox(height: 14),
              Text('Opening camera…',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTapUp: (d) => _onTapFocus(d, constraints),
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: AnimatedBuilder(
          animation: _flipAnim,
          builder: (_, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateY(_flipAnim.value * math.pi),
            child: _flipAnim.value < 0.5
                ? child
                : SizedBox.expand(child: Container(color: Colors.black)),
          ),
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _camCtrl!.value.previewSize!.height,
                height: _camCtrl!.value.previewSize!.width,
                child: CameraPreview(_camCtrl!),
              ),
            ),
          ),
        ),
      );
    });
  }

  // ── White blink on capture ───────────────────────────────────────────────────
  Widget _buildFlashBlink() => IgnorePointer(
        child: FadeTransition(
          opacity: _blinkOpacity,
          child: Container(color: Colors.white),
        ),
      );

  // ── Focus ring ───────────────────────────────────────────────────────────────
  Widget _buildFocusIndicator() {
    if (_focusPoint == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _focusCtrl,
        builder: (_, _) => Positioned(
          left: _focusPoint!.dx - 30,
          top: _focusPoint!.dy - 30,
          child: Opacity(
            opacity: _focusOpacity.value,
            child: Transform.scale(
              scale: _focusScale.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: const Color(0xFFFFD60A), width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Close
            _TopBtn(
              icon: Icons.close_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
            // Flash cycle
            _TopBtn(
              icon: _flashIcons[_flashModes.indexOf(_flashMode)],
              active: _flashMode == FlashMode.always,
              onTap: _cycleFlash,
            ),
            const SizedBox(width: 16),
            // Done button (top right when photos exist)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _photos.isNotEmpty
                  ? GestureDetector(
                      key: const ValueKey('done'),
                      onTap: () => Navigator.of(context).pop(_photos),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Done',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${_photos.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }

  // ── Zoom label ───────────────────────────────────────────────────────────────
  Widget _buildZoomLabel() {
    if (_zoom <= _minZoom + 0.05) return const SizedBox.shrink();
    return Positioned(
      left: 0,
      right: 0,
      bottom: 260,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_zoom.toStringAsFixed(1)}×',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom panel ─────────────────────────────────────────────────────────────
  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.88),
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Thumbnail strip ───────────────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutExpo,
            child: _photos.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _buildThumbnailStrip(),
                  )
                : const SizedBox(height: 24),
          ),

          // ── Shutter row ───────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gallery thumbnail
                _buildGalleryThumb(),

                // Shutter
                _buildShutter(),

                // Flip camera
                _buildFlipBtn(),
              ],
            ),
          ),

          // ── Zoom strip ────────────────────────────────────────────────────
          const SizedBox(height: 20),
          _buildZoomPills(),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // ── Thumbnail strip ──────────────────────────────────────────────────────────
  Widget _buildThumbnailStrip() {
    return SizedBox(
      height: 86,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _photos.length,
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () => _showPreview(_photos[i]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(_photos[i].path), fit: BoxFit.cover),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removePhoto(i),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Gallery button ───────────────────────────────────────────────────────────
  Widget _buildGalleryThumb() {
    return GestureDetector(
      onTap: _pickGallery,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: _photos.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.file(
                  File(_photos.last.path),
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                Icons.photo_library_outlined,
                color: Colors.white.withValues(alpha: 0.6),
                size: 24,
              ),
      ),
    );
  }

  // ── Shutter button ───────────────────────────────────────────────────────────
  Widget _buildShutter() {
    return GestureDetector(
      onTap: _capture,
      child: AnimatedBuilder(
        animation: _shutterScale,
        builder: (_, child) => Transform.scale(
          scale: _shutterScale.value,
          child: child,
        ),
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3.5),
          ),
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── Flip camera button ───────────────────────────────────────────────────────
  Widget _buildFlipBtn() {
    return GestureDetector(
      onTap: _flipCamera,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
        ),
        child: const Icon(Icons.flip_camera_ios_rounded,
            color: Colors.white, size: 26),
      ),
    );
  }

  // ── Zoom pills (0.5× 1× 2×) ─────────────────────────────────────────────────
  Widget _buildZoomPills() {
    final levels = [0.5, 1.0, 2.0]
        .where((z) => z >= _minZoom && z <= _maxZoom)
        .toList();
    if (levels.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: levels.map((z) {
        final active = (_zoom - z).abs() < 0.25;
        return GestureDetector(
          onTap: () async {
            final clamped = z.clamp(_minZoom, _maxZoom);
            setState(() => _zoom = clamped);
            try {
              await _camCtrl?.setZoomLevel(clamped);
            } catch (_) {}
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Text(
              '${z == 0.5 ? '·5' : z.toInt()}×',
              style: TextStyle(
                color: active ? Colors.white : Colors.white.withValues(alpha: 0.45),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Full-screen image preview ────────────────────────────────────────────────
  void _showPreview(XFile img) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF0E0E0E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.file(File(img.path), fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Top icon button ───────────────────────────────────────────────────────────
class _TopBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _TopBtn({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.35),
          border: Border.all(
              color: active
                  ? const Color(0xFFFFD60A)
                  : Colors.white.withValues(alpha: 0.15),
              width: 1),
        ),
        child: Icon(
          icon,
          color: active ? const Color(0xFFFFD60A) : Colors.white,
          size: 19,
        ),
      ),
    );
  }
}
