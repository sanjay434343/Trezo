import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import '../core/models/entity_result.dart';
import '../core/utils/permission_dialog.dart';
import '../core/services/entity_extractor_service.dart';
import 'add_asset_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cam;
  List<CameraDescription>? _cameras;
  bool _isReady = false;
  int _flashModeIndex = 0; // 0 = off, 1 = always on (torch), 2 = shutter to on (always)
  bool _isCapturing = false;
  String? _errorMsg;
  bool _showRecentPhotos = false;

  // ML Tracking
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  bool _isProcessingML = false;
  RecognizedText? _recognizedText;
  Size? _cameraImageSize;
  InputImageRotation _rotation = InputImageRotation.rotation0deg;
  String? _capturedImagePath;

  // Distance Guidance
  DateTime? _lastMLProcessTime;
  bool _isDistanceGood = false;
  bool _hasText = false;
  bool _isLandscapeMode = false;

  // Gallery images
  final List<AssetEntity> _galleryAssets = [];
  bool _galleryLoading = true;

  late AnimationController _uiAnim;
  late Animation<double> _uiFade;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _uiAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _uiFade = CurvedAnimation(parent: _uiAnim, curve: Curves.easeOut);
    _initCamera();
    _loadGallery();
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        setState(() => _errorMsg = 'Camera permission required.');
        return;
      }

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _errorMsg = 'No camera found');
        return;
      }
      await _startCamera(_cameras!.first);
    } catch (e) {
      setState(() => _errorMsg = 'Camera error: $e');
    }
  }

  Future<void> _startCamera(CameraDescription desc) async {
    final ctrl = CameraController(
      desc,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    try {
      await ctrl.initialize();
      if (!mounted) return;

      // Start live text scanning
      await ctrl.startImageStream(_processCameraImage);

      setState(() {
        _cam = ctrl;
        _isReady = true;
      });
      _uiAnim.forward();
    } catch (e) {
      setState(() => _errorMsg = 'Could not start camera: $e');
    }
  }

  Uint8List _concatPlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingML || _cam == null || !mounted) return;
    final now = DateTime.now();
    if (_lastMLProcessTime != null && now.difference(_lastMLProcessTime!).inMilliseconds < 500) {
      return;
    }
    _isProcessingML = true;
    _lastMLProcessTime = now;

    try {
      final sensorOrientation = _cam!.description.sensorOrientation;
      InputImageRotation rotation =
          InputImageRotationValue.fromRawValue(sensorOrientation) ??
          InputImageRotation.rotation0deg;

      final InputImageFormat format =
          InputImageFormatValue.fromRawValue(image.format.raw as int) ??
          InputImageFormat.nv21;

      if ((Platform.isAndroid &&
              format != InputImageFormat.nv21 &&
              format != InputImageFormat.yuv420) ||
          (Platform.isIOS && format != InputImageFormat.bgra8888)) {
        return;
      }

      final inputImage = InputImage.fromBytes(
        bytes: _concatPlanes(image.planes),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final recognizedText = await _textRecognizer.processImage(inputImage);

      bool isDistanceGood = false;
      bool hasText = false;

      if (recognizedText.blocks.isNotEmpty) {
        hasText = true;
      }
      isDistanceGood = true;

      if (mounted) {
        setState(() {
          _recognizedText = recognizedText;
          _cameraImageSize = Size(
            image.width.toDouble(),
            image.height.toDouble(),
          );
          _rotation = rotation;
          _hasText = hasText;
          _isDistanceGood = isDistanceGood;
        });
      }
    } catch (e) {
      debugPrint('ML error: $e');
    } finally {
      if (mounted) {
        _isProcessingML = false;
      }
    }
  }

  Future<void> _loadGallery() async {
    if (!mounted) return;
    try {
      // Use requestPermissionExtend which will check and prompt if necessary
      final permission = await PhotoManager.requestPermissionExtend();
      if (permission != PermissionState.authorized && permission != PermissionState.limited) {
        if (mounted) setState(() => _galleryLoading = false);
        return;
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        hasAll: true,
      );

      if (albums.isEmpty) {
        if (mounted) setState(() => _galleryLoading = false);
        return;
      }

      final List<AssetEntity> assetsList = [];

      // Try to get from the 'All' album first
      AssetPathEntity? allAlbum;
      try {
        allAlbum = albums.firstWhere((a) => a.isAll);
      } catch (_) {
        if (albums.isNotEmpty) allAlbum = albums.first;
      }

      if (allAlbum != null) {
        final recentAssets = await allAlbum.getAssetListPaged(
          page: 0,
          size: 150,
        );
        assetsList.addAll(recentAssets);
      }

      // If still empty, iterate over all other albums to find images
      if (assetsList.isEmpty) {
        for (final album in albums) {
          if (album == allAlbum) continue;
          final assets = await album.getAssetListPaged(page: 0, size: 150);
          assetsList.addAll(assets);
          if (assetsList.isNotEmpty) break;
        }
      }

      if (!mounted) return;
      setState(() {
        _galleryAssets.clear();
        _galleryAssets.addAll(assetsList);
        _galleryLoading = false;
      });
    } catch (e) {
      debugPrint('Gallery load error: $e');
      if (mounted) setState(() => _galleryLoading = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cam = _cam;
    if (cam == null || !cam.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      cam.dispose();
      setState(() => _isReady = false);
    } else if (state == AppLifecycleState.resumed) {
      _startCamera(cam.description);
    }
  }

  @override
  void dispose() {
    _uiAnim.dispose();
    _textRecognizer.close();
    _cam?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    if (_cam == null) return;
    final next = (_flashModeIndex + 1) % 3;
    FlashMode mode;
    if (next == 0) mode = FlashMode.off;
    else if (next == 1) mode = FlashMode.torch;
    else mode = FlashMode.always;
    await _cam!.setFlashMode(mode);
    setState(() => _flashModeIndex = next);
  }

  Future<void> _capture() async {
    if (_cam == null || _isCapturing) return;
    
    if (!_hasText) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No text detected. Please align document to scan.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF2A2A2A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final file = await _cam!.takePicture();
      
      final screenW = MediaQuery.of(context).size.width;
      final screenH = MediaQuery.of(context).size.height;
      final portraitW = screenW * 0.85;
      final portraitH = portraitW * 1.414;
      final landscapeW = screenW * 0.85;
      final landscapeH = landscapeW / 1.586;
      final rectWidth = _isLandscapeMode ? landscapeW : portraitW;
      final rectHeight = _isLandscapeMode ? landscapeH : portraitH;
      
      final imageBytes = await file.readAsBytes();
      final croppedBytes = await compute(_cropImageIsolate, {
        'bytes': imageBytes,
        'rectWidth': rectWidth,
        'rectHeight': rectHeight,
        'screenW': screenW,
        'screenH': screenH,
      });
      
      if (croppedBytes != null) {
        await File(file.path).writeAsBytes(croppedBytes);
      }

      if (!mounted) return;
      setState(() => _capturedImagePath = file.path);
      final cam = _cam;
      _cam = null;
      setState(() => _isReady = false);
      await cam?.dispose();
      await _goToResult(file.path);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _isCapturing = true;
      _capturedImagePath = picked.path;
    });
    final cam = _cam;
    _cam = null;
    setState(() => _isReady = false);
    await cam?.dispose();
    await _goToResult(picked.path);
    if (mounted) setState(() => _isCapturing = false);
  }

  Future<void> _useGalleryImage(AssetEntity asset) async {
    setState(() {
      _isCapturing = true;
    });
    final file = await asset.file;
    if (file == null) {
      if (mounted) setState(() => _isCapturing = false);
      return;
    }
    setState(() {
      _capturedImagePath = file.path;
    });
    final cam = _cam;
    _cam = null;
    setState(() => _isReady = false);
    await cam?.dispose();
    await _goToResult(file.path);
    if (mounted) setState(() => _isCapturing = false);
  }

  Future<void> _goToResult(String path) async {
    if (!mounted) return;

    // Run OCR and Entity Extraction on the final image
    String textToUse = _recognizedText?.text ?? '';
    List<EntityResult> entities = [];

    try {
      final inputImage = InputImage.fromFilePath(path);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await recognizer.processImage(inputImage);
      await recognizer.close();
      textToUse = result.text.trim();

      if (textToUse.isNotEmpty) {
        await EntityExtractorService.instance.initialize();
        entities = await EntityExtractorService.instance.extract(textToUse);
      }
    } catch (e) {
      debugPrint('OCR/Entity extraction error: $e');
    }

    if (!mounted) return;

    if (textToUse.isEmpty || entities.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            textToUse.isEmpty 
                ? 'No text detected. Please align document to scan.'
                : 'Not enough data detected. Please scan a clearer document.',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF2A2A2A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() {
        _isReady = false;
        _capturedImagePath = null;
      });
      _initCamera();
      return;
    }

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAssetScreen(
          initialImagePath: path,
          initialText: textToUse,
          initialEntities: entities,
        ),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      Navigator.pop(context, result);
    } else {
      // User tapped back/retake from AddAssetScreen
      setState(() {
        _isReady = false;
        _capturedImagePath = null;
      });
      _initCamera();
    }
  }

  Widget _buildCameraCard() {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    
    final portraitW = screenW * 0.85;
    final portraitH = portraitW * 1.414;
    final landscapeW = screenW * 0.85;
    final landscapeH = landscapeW / 1.586;
    
    final offsetY = -60.0;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      tween: Tween<double>(begin: _isLandscapeMode ? 1.0 : 0.0, end: _isLandscapeMode ? 1.0 : 0.0),
      builder: (context, t, child) {
        final rectWidth = portraitW + (landscapeW - portraitW) * t;
        final rectHeight = portraitH + (landscapeH - portraitH) * t;

        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Transform.translate(
                offset: Offset(0, offsetY),
                child: Container(
                  width: rectWidth,
                  height: rectHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // The actual camera or captured image
                        if (_capturedImagePath != null)
                          Image.file(File(_capturedImagePath!), fit: BoxFit.cover)
                        else if (_isReady && _cam != null)
                          _FullScreenCamera(
                            controller: _cam!,
                            recognizedText: _recognizedText,
                            imageSize: _cameraImageSize,
                            rotation: _rotation,
                          )
                        else if (_errorMsg != null)
                          _ErrorState(message: _errorMsg!),



                        // The portrait/landscape toggle button
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLandscapeMode = !_isLandscapeMode;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: Icon(
                                  _isLandscapeMode ? Icons.crop_portrait_rounded : Icons.crop_landscape_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Center Cross
            Center(
              child: Transform.translate(
                offset: Offset(0, offsetY),
                child: const Icon(Icons.add, color: Colors.white54, size: 24),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── The Central Camera Card ──
          if (_isReady || _capturedImagePath != null || _errorMsg != null)
            FadeTransition(
              opacity: _uiFade,
              child: _buildCameraCard(),
            ),

          // ── Loading indicator when starting ──
          if (!_isReady && _errorMsg == null && _capturedImagePath == null)
            const _LoadingCamera(),

          // ── Top Bar (Close and Flash) ──
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleBtn(
                      icon: HugeIcons.strokeRoundedCancel01,
                      onTap: () => Navigator.pop(context),
                    ),
                    if (_isReady && _cam != null && _capturedImagePath == null)
                      _CircleBtn(
                        icon: _flashModeIndex == 0
                            ? HugeIcons.strokeRoundedFlashOff
                            : (_flashModeIndex == 1
                                ? HugeIcons.strokeRoundedFlash
                                : Icons.flash_auto),
                        onTap: _toggleTorch,
                        active: _flashModeIndex != 0,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Gallery Card (bottom sheet style)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _GalleryBottomCard(
              galleryAssets: _galleryAssets,
              galleryLoading: _galleryLoading,
              isCapturing: _isCapturing,
              showRecentPhotos: _showRecentPhotos,
              torchOn: _flashModeIndex != 0,
              isDistanceGood: _isDistanceGood,
              hasText: _hasText,
              onCapture: _capture,
              onToggleRecentPhotos: () =>
                  setState(() => _showRecentPhotos = !_showRecentPhotos),
              onPickFromGallery: _pickFromGallery,
              onSelectImage: _useGalleryImage,
              onToggleTorch: _toggleTorch,
              onManualEntry: () {
                Navigator.pop(context, {'action': 'open_add_asset'});
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full screen camera ────────────────────────────────────────────────────────
class _FullScreenCamera extends StatelessWidget {
  final CameraController controller;
  final RecognizedText? recognizedText;
  final Size? imageSize;
  final InputImageRotation rotation;

  const _FullScreenCamera({
    required this.controller,
    this.recognizedText,
    this.imageSize,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize?.height ?? 1,
            height: controller.value.previewSize?.width ?? 1,
            child: Stack(
              fit: StackFit.expand,
              children: [CameraPreview(controller)],
            ),
          ),
        ),
      ),
    );
  }
}



// ── Bottom gallery card ───────────────────────────────────────────────────────
class _GalleryBottomCard extends StatelessWidget {
  final List<AssetEntity> galleryAssets;
  final bool galleryLoading;
  final bool isCapturing;
  final bool showRecentPhotos;
  final bool torchOn;
  final bool isDistanceGood;
  final bool hasText;
  final VoidCallback onCapture;
  final VoidCallback onToggleRecentPhotos;
  final VoidCallback onPickFromGallery;
  final ValueChanged<AssetEntity> onSelectImage;
  final VoidCallback onToggleTorch;
  final VoidCallback onManualEntry;

  const _GalleryBottomCard({
    required this.galleryAssets,
    required this.galleryLoading,
    required this.isCapturing,
    required this.showRecentPhotos,
    required this.torchOn,
    required this.isDistanceGood,
    required this.hasText,
    required this.onCapture,
    required this.onToggleRecentPhotos,
    required this.onPickFromGallery,
    required this.onSelectImage,
    required this.onToggleTorch,
    required this.onManualEntry,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -300 && !showRecentPhotos) {
            onToggleRecentPhotos();
          } else if (details.primaryVelocity! > 300 && showRecentPhotos) {
            onToggleRecentPhotos();
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ), // SafeArea
              decoration: BoxDecoration(
                color: Colors.grey.shade900.withValues(alpha: 0.85),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment.bottomCenter,
                    child: showRecentPhotos
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 24),
                              // Section label
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'RECENT PHOTOS',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: onPickFromGallery,
                                      child: Text(
                                        'Browse All →',
                                        style: TextStyle(
                                          color: const Color(
                                            0xFFFF6B35,
                                          ).withValues(alpha: 0.8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Photo Grid
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: galleryLoading
                                    ? _buildLoadingGrid()
                                    : galleryAssets.isEmpty
                                    ? _buildEmptyGrid()
                                    : _buildImageGrid(
                                        galleryAssets,
                                        onSelectImage,
                                      ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // Shutter row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // Gallery picker button
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: onToggleRecentPhotos,
                            child: Container(
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: Center(
                                child: HugeIcon(
                                  icon: showRecentPhotos
                                      ? HugeIcons.strokeRoundedCancel01
                                      : HugeIcons.strokeRoundedImage01,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        // Shutter button
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: onCapture,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              height: isCapturing ? 64 : 72,
                              margin: EdgeInsets.symmetric(vertical: isCapturing ? 4 : 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                color: Colors.green.withValues(alpha: 0.8),
                                border: Border.all(
                                  color: Colors.greenAccent, 
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: isCapturing
                                  ? const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Center(
                                      child: HugeIcon(
                                        icon: HugeIcons.strokeRoundedCamera01,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        // Manual entry button
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: onManualEntry,
                            child: Container(
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: const Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedEdit02,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: 9,
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildEmptyGrid() {
    return Center(
      child: Text(
        'No recent photos',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.2),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<AssetEntity> assets, ValueChanged<AssetEntity> onSelect) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: assets.length,
      itemBuilder: (_, i) {
        final asset = assets[i];
        return GestureDetector(
          onTap: () => onSelect(asset),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ThumbnailImage(asset: asset),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.25),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThumbnailImage extends StatefulWidget {
  final AssetEntity asset;
  const _ThumbnailImage({required this.asset});
  @override
  State<_ThumbnailImage> createState() => _ThumbnailImageState();
}

class _ThumbnailImageState extends State<_ThumbnailImage> {
  Uint8List? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_ThumbnailImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) {
      _data = null;
      _load();
    }
  }

  Future<void> _load() async {
    final data = await widget.asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));
    if (mounted) setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    if (_data != null) {
      return Image.memory(_data!, fit: BoxFit.cover);
    }
    return Container(color: Colors.white.withValues(alpha: 0.1));
  }
}

// ── Circle button ─────────────────────────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final dynamic icon;
  final VoidCallback onTap;
  final bool active;
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Center(
          child: icon is IconData
              ? Icon(
                  icon as IconData,
                  color: active ? Colors.black : Colors.white,
                  size: 20,
                )
              : HugeIcon(
                  icon: icon as List<List<dynamic>>,
                  color: active ? Colors.black : Colors.white,
                  size: 20,
                ),
        ),
      ),
    );
  }
}

Future<Uint8List?> _cropImageIsolate(Map<String, dynamic> params) async {
  final bytes = params['bytes'] as Uint8List;
  final rectWidth = params['rectWidth'] as double;
  final rectHeight = params['rectHeight'] as double;
  final screenW = params['screenW'] as double;
  final screenH = params['screenH'] as double;
  
  img.Image? decodedImage = img.decodeImage(bytes);
  if (decodedImage == null) return null;
  decodedImage = img.bakeOrientation(decodedImage);
  
  final imgW = decodedImage.width;
  final imgH = decodedImage.height;
  
  final screenRatio = screenW / screenH;
  final imgRatio = imgW / imgH;
  
  double scale;
  double dx = 0;
  double dy = 0;
  
  if (screenRatio > imgRatio) {
    scale = imgW / screenW;
    dy = (imgH - screenH * scale) / 2;
  } else {
    scale = imgH / screenH;
    dx = (imgW - screenW * scale) / 2;
  }
  
  final centerScreenX = screenW / 2;
  final centerScreenY = screenH / 2 - 60.0;
  
  final rectLeft = centerScreenX - rectWidth / 2;
  final rectTop = centerScreenY - rectHeight / 2;
  
  int cropX = (rectLeft * scale + dx).round();
  int cropY = (rectTop * scale + dy).round();
  int cropW = (rectWidth * scale).round();
  int cropH = (rectHeight * scale).round();
  
  cropX = cropX.clamp(0, imgW - 1);
  cropY = cropY.clamp(0, imgH - 1);
  cropW = cropW.clamp(1, imgW - cropX);
  cropH = cropH.clamp(1, imgH - cropY);
  
  final croppedImage = img.copyCrop(decodedImage, x: cropX, y: cropY, width: cropW, height: cropH);
  return img.encodeJpg(croppedImage, quality: 90);
}

// ── Loading state ─────────────────────────────────────────────────────────────
class _LoadingCamera extends StatelessWidget {
  const _LoadingCamera();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white30, strokeWidth: 2),
          SizedBox(height: 20),
          Text(
            'Starting camera…',
            style: TextStyle(color: Colors.white30, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: Colors.white.withValues(alpha: 0.2),
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            if (message.toLowerCase().contains('permission'))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextButton(
                  onPressed: () async {
                    final granted = await showGlobalPermissionDialog(context);
                    if (granted && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Grant Permission',
                    style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Scan Result Screen — ML Kit OCR + Entity Extraction
// ══════════════════════════════════════════════════════════════════════════════
class _ScanResultScreen extends StatefulWidget {
  final String imagePath;
  const _ScanResultScreen({required this.imagePath});

  @override
  State<_ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<_ScanResultScreen>
    with SingleTickerProviderStateMixin {
  // Analysis state
  bool _analyzing = true;
  String _status = 'Reading text…';
  String _recognizedText = '';
  List<EntityResult> _entities = [];
  String? _errorMsg;

  // Tab: 0 = Text, 1 = Entities
  int _tab = 1;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutExpo);
    _fadeCtrl.forward();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    try {
      // ── Step 1: OCR ──────────────────────────────────────────────────────
      setState(() => _status = 'Reading text…');
      final inputImage = InputImage.fromFilePath(widget.imagePath);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await recognizer.processImage(inputImage);
      await recognizer.close();

      final text = result.text.trim();
      if (!mounted) return;
      setState(() {
        _recognizedText = text.isEmpty ? '(No text detected)' : text;
        _status = 'Extracting entities…';
      });

      // ── Step 2: Entity Extraction ────────────────────────────────────────
      List<EntityResult> entities = [];
      if (text.isNotEmpty) {
        await EntityExtractorService.instance.initialize();
        entities = await EntityExtractorService.instance.extract(text);
      }

      if (!mounted) return;
      setState(() {
        _entities = entities;
        _analyzing = false;
        // Auto-switch to text tab if no entities found
        if (entities.isEmpty) _tab = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = 'Analysis failed: $e';
        _analyzing = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 16),
              _buildImagePreview(),
              const SizedBox(height: 16),
              _buildStatusCard(),
              if (!_analyzing) ..._buildTabs(),
              const SizedBox(height: 12),
              _buildActionButtons(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Scan Results',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Image preview ─────────────────────────────────────────────────────────
  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(widget.imagePath),
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ── Status card ───────────────────────────────────────────────────────────
  Widget _buildStatusCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _analyzing
            ? Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _status,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : _errorMsg != null
            ? Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFF87171),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMsg!,
                      style: const TextStyle(
                        color: Color(0xFFF87171),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8AFF80).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF8AFF80),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _entities.isEmpty
                              ? 'Text extracted'
                              : '${_entities.length} entit${_entities.length == 1 ? 'y' : 'ies'} found',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _entities.isEmpty
                              ? 'No structured entities detected'
                              : 'Dates, contacts, money & more extracted',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────
  List<Widget> _buildTabs() {
    return [
      const SizedBox(height: 16),
      // Tab selector
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _TabBtn(
                label: 'Entities',
                icon: Icons.label_outline_rounded,
                badge: _entities.length,
                selected: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
              _TabBtn(
                label: 'Text',
                icon: Icons.text_snippet_outlined,
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      // Tab content
      Expanded(
        child: _tab == 1
            ? _EntitiesPanel(entities: _entities)
            : _TextPanel(text: _recognizedText),
      ),
    ];
  }

  // ── Action buttons ────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Retake',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _analyzing
                  ? null
                  : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddAssetScreen(initialEntities: _entities),
                        ),
                      );
                      if (result != null && mounted) {
                        Navigator.pop(context, result);
                      }
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: _analyzing
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                        ),
                  color: _analyzing ? Colors.white10 : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Add to Vault →',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _analyzing ? Colors.white30 : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab button ────────────────────────────────────────────────────────────────
class _TabBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final int badge;
  final bool selected;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.icon,
    this.badge = 0,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2A2A2A) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.35),
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (badge > 0 && selected) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Entities panel ────────────────────────────────────────────────────────────
class _EntitiesPanel extends StatelessWidget {
  final List<EntityResult> entities;
  const _EntitiesPanel({required this.entities});

  @override
  Widget build(BuildContext context) {
    if (entities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: Colors.white.withValues(alpha: 0.15),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No entities detected',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try scanning a receipt, boarding pass\nor business card',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.18),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: entities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _EntityCard(entity: entities[i], index: i),
    );
  }
}

// ── Animated entity card ──────────────────────────────────────────────────────
class _EntityCard extends StatefulWidget {
  final EntityResult entity;
  final int index;
  const _EntityCard({required this.entity, required this.index});

  @override
  State<_EntityCard> createState() => _EntityCardState();
}

class _EntityCardState extends State<_EntityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entity;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: e.color, width: 3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: e.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(e.icon, color: e.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.type,
                        style: TextStyle(
                          color: e.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        e.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (e.detail != null && e.detail!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          e.detail!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Text panel ────────────────────────────────────────────────────────────────
class _TextPanel extends StatelessWidget {
  final String text;
  const _TextPanel({required this.text});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SelectableText(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 13,
            height: 1.7,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

// ── Live ML Text Overlay Painter ──────────────────────────────────────────────
class _LiveTextOverlayPainter extends CustomPainter {
  final RecognizedText recognizedText;
  final Size imageSize;
  final InputImageRotation rotation;

  _LiveTextOverlayPainter({
    required this.recognizedText,
    required this.imageSize,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFFF6B35).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint = Paint()
      ..color = const Color(0xFFFF6B35).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final bool isPortrait =
        rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;

    final double imgW = isPortrait ? imageSize.height : imageSize.width;
    final double imgH = isPortrait ? imageSize.width : imageSize.height;

    final double scale = max(size.width / imgW, size.height / imgH);

    final double scaledW = imgW * scale;
    final double scaledH = imgH * scale;

    final double dx = (size.width - scaledW) / 2;
    final double dy = (size.height - scaledH) / 2;

    double translateX(double x) {
      return x * scale + dx;
    }

    double translateY(double y) {
      return y * scale + dy;
    }

    for (final block in recognizedText.blocks) {
      final cornerPoints = block.cornerPoints;
      if (cornerPoints.length == 4) {
        final path = Path();
        path.moveTo(
          translateX(cornerPoints[0].x.toDouble()),
          translateY(cornerPoints[0].y.toDouble()),
        );
        path.lineTo(
          translateX(cornerPoints[1].x.toDouble()),
          translateY(cornerPoints[1].y.toDouble()),
        );
        path.lineTo(
          translateX(cornerPoints[2].x.toDouble()),
          translateY(cornerPoints[2].y.toDouble()),
        );
        path.lineTo(
          translateX(cornerPoints[3].x.toDouble()),
          translateY(cornerPoints[3].y.toDouble()),
        );
        path.close();

        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LiveTextOverlayPainter oldDelegate) {
    return oldDelegate.recognizedText != recognizedText;
  }
}


