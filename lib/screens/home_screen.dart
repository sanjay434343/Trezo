import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/asset.dart';
import '../core/models/entity_result.dart';
import '../features/assets/presentation/controllers/home_controller.dart';
import 'asset_detail_screen.dart';
import 'add_asset_screen.dart';
import 'scan_screen.dart';
import 'scan_asset_screen.dart';
import 'profile_screen.dart';
import '../core/services/database_service.dart';
import 'package:page_transition/page_transition.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:animations/animations.dart';
import 'package:figma_squircle/figma_squircle.dart';

bool _globalHasPieChartAnimated = false;

// ── Screen ──────────────────────────────────────────────────────────────────
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _tab = 0;
  bool _showExpiryDays = true;
  late AnimationController _animCtrl;
  late AnimationController _imgCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _imgFadeAnim;
  late Animation<double> _bounceAnim;

  final _tabs = ['All', 'Active', 'Expiring', 'Expired'];

  @override
  void initState() {
    super.initState();
    if (!_globalHasPieChartAnimated) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _globalHasPieChartAnimated = true;
      });
    }
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _imgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    _bounceAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut));

    _imgFadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _imgCtrl, curve: Curves.easeOut));

    _animCtrl.forward();
    _imgCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadSettings();
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('auto_scan_enabled') == true && mounted) {
        _openScanScreen();
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _showExpiryDays = prefs.getBool('show_expiry_days') ?? true;
      });
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _imgCtrl.dispose();
    super.dispose();
  }

  List<Asset> _getFiltered(List<Asset> allAssets) {
    if (_tab == 0) return allAssets;
    final s = ['active', 'expiring', 'expired'][_tab - 1];
    return allAssets.where((a) => a.status == s).toList();
  }

  int _getExpiringCount(List<Asset> allAssets) =>
      allAssets.where((a) => a.status == 'expiring').length;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final secondaryAnim =
        route?.secondaryAnimation ?? const AlwaysStoppedAnimation(0.0);
    final scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: secondaryAnim, curve: Curves.easeOutCubic),
    );

    final asyncAssets = ref.watch(homeControllerProvider);

    return ScaleTransition(
      scale: scaleAnim,
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Stack(
          children: [
            // Background image at top-left
            Positioned(
              top: 0,
              left: 0,
              child: FadeTransition(
                opacity: _imgFadeAnim,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    // Fade out on the right
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.white, Colors.transparent],
                      stops: [0.25, 0.8],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      // Fade out at the bottom
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.transparent],
                        stops: [0.4, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Opacity(
                      opacity: 1.0,
                      child: Image.asset(
                        'assets/images/tbg.png',
                        width: 340,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Main content
            FadeTransition(
              opacity: _fadeAnim,
              child: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildSummaryBanner(asyncAssets)),
                    const SliverToBoxAdapter(child: SizedBox(height: 28)),
                    SliverToBoxAdapter(child: _buildTabBar()),
                    const SliverToBoxAdapter(child: SizedBox(height: 28)),
                    _buildSliver(asyncAssets),
                    // bottom padding so FAB doesn't cover last card
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ScaleTransition(
          scale: _bounceAnim,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OpenContainer<Object?>(
                transitionType: ContainerTransitionType.fade,
                openBuilder: (context, _) => const ScanScreen(),
                onClosed: _handleNewAssetResult,
                closedElevation: 8.0,
                closedShape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 32,
                    cornerSmoothing: 1,
                  ),
                ),
                closedColor: const Color(0xFF1A1A1A),
                openColor: const Color(0xFF000000),
                middleColor: const Color(0xFF1A1A1A),
                closedBuilder: (context, VoidCallback openContainer) {
                  return InkWell(
                    onTap: openContainer,
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 32,
                      cornerSmoothing: 1,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xFF1A1A1A),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 32,
                            cornerSmoothing: 1,
                          ),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0x1AFFFFFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Add Asset',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 3),
              OpenContainer<Object?>(
                transitionType: ContainerTransitionType.fade,
                openBuilder: (context, _) => const ProfileScreen(),
                onClosed: (_) => _loadSettings(),
                closedElevation: 8.0,
                closedShape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 32,
                    cornerSmoothing: 1,
                  ),
                ),
                closedColor: const Color(0xFF1A1A1A),
                openColor: const Color(0xFF000000),
                middleColor: const Color(0xFF1A1A1A),
                closedBuilder: (context, VoidCallback openContainer) {
                  return Container(
                    decoration: ShapeDecoration(
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 32,
                          cornerSmoothing: 1,
                        ),
                      ),
                    ),
                    child: Material(
                      color: const Color(0xFF1A1A1A),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 32,
                          cornerSmoothing: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: openContainer,
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 32,
                          cornerSmoothing: 1,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: ShapeDecoration(
                            shape: SmoothRectangleBorder(
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 32,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedSettings01,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trezo',
                  style: TextStyle(
                    fontFamily: 'LibreBaskerville',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'My Vault',
                  style: TextStyle(
                    fontFamily: 'LibreBaskerville',
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: const AssetSearchScreen(),
                ),
              );
            },
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBanner(AsyncValue<List<Asset>> asyncAssets) {
    final allAssets = asyncAssets.valueOrNull ?? [];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildGlassCard(
              child: _SummaryTile(
                value: '${allAssets.length}',
                label: 'Total',
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildGlassCard(
              child: _SummaryTile(
                value: '${_getExpiringCount(allAssets)}',
                label: 'Expiring',
                color: const Color(0xFFFF6B35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipSmoothRect(
      radius: SmoothBorderRadius(cornerRadius: 32, cornerSmoothing: 1),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: ShapeDecoration(
            color: const Color(0xFF141416).withValues(alpha: 0.6),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 32,
                cornerSmoothing: 1,
              ),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final active = _tab == i;
          return GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: ShapeDecoration(
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.05),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 40,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: Text(
                _tabs[i],
                style: TextStyle(
                  color: active
                      ? const Color(0xFF000000)
                      : Colors.white.withValues(alpha: 0.35),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSliver(AsyncValue<List<Asset>> asyncAssets) {
    return asyncAssets.when(
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF6B35),
            strokeWidth: 2,
          ),
        ),
      ),
      error: (err, stack) => SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      data: (allAssets) {
        final items = _getFiltered(allAssets);
        if (items.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    color: Colors.white.withValues(alpha: 0.08),
                    size: 56,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nothing here',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              // interleave 3px gaps
              if (i.isOdd) return const SizedBox(height: 3);
              final idx = i ~/ 2;
              return ScaleTransition(
                scale: _bounceAnim,
                child: OpenContainer<Object?>(
                  transitionType: ContainerTransitionType.fade,
                  closedElevation: 0,
                  closedColor: Colors.transparent,
                  openColor: const Color(0xFF000000),
                  middleColor: const Color(0xFF000000),
                  closedShape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 32,
                      cornerSmoothing: 1,
                    ),
                  ),
                  onClosed: (_) =>
                      ref.read(homeControllerProvider.notifier).refresh(),
                  closedBuilder: (context, action) {
                    return _AssetCard(
                      asset: items[idx],
                      showExpiryDays: _showExpiryDays,
                      onTap: action,
                    );
                  },
                  openBuilder: (context, _) =>
                      AssetDetailScreen(asset: items[idx]),
                ),
              );
            }, childCount: items.length * 2 - 1),
          ),
        );
      },
    );
  }

  Future<void> _handleNewAssetResult(dynamic result) async {
    if (result is Asset && mounted) {
      // Asset was already saved to Isar by AddAssetScreen — just reload
      await ref.read(homeControllerProvider.notifier).refresh();
    } else if (result is Map && mounted) {
      if (result['action'] == 'open_add_asset') {
        final newAsset = await Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, a, _) => AddAssetScreen(
              initialText: result['recognizedText'] as String?,
              initialEntities: result['entities'] as List<EntityResult>?,
              initialImagePath: result['path'] as String?,
            ),
            transitionsBuilder: (_, a, _, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
        );
        if (newAsset != null) {
          _handleNewAssetResult(newAsset);
        }
      }
    }
  }

  Future<void> _openAddAsset() async {
    final result = await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: const AddAssetScreen(),
      ),
    );
    _handleNewAssetResult(result);
  }

  Future<void> _openScanAsset() async {
    await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: const ScanAssetScreen(),
      ),
    );
  }

  Future<void> _openScanScreen() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ScanScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide =
              Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          final scale = Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );

          return SlideTransition(
            position: slide,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
      ),
    );
    _handleNewAssetResult(result);
  }
}

// ── Asset Card ───────────────────────────────────────────────────────────────
class _AssetCard extends StatelessWidget {
  final Asset asset;
  final bool showExpiryDays;
  final VoidCallback onTap;
  const _AssetCard({
    required this.asset,
    this.showExpiryDays = true,
    required this.onTap,
  });

  IconData get _icon {
    return IconData(
      asset.iconCodePoint,
      fontFamily: asset.iconFontFamily,
      fontPackage: asset.iconFontPackage,
    );
  }

  Color get _statusColor {
    switch (asset.status) {
      case 'expiring':
        return const Color(0xFFFF6B35); // Orange
      case 'expired':
        return Colors.redAccent; // Red
      default:
        return const Color(0xFF8AFF80); // Green
    }
  }

  String get _statusLabel {
    final days = asset.daysUntilExpiry;
    if (days == null) return 'Active';
    if (days < 0) return 'Expired';
    if (days == 0) return 'Expires today';

    int y = days ~/ 365;
    int m = (days % 365) ~/ 30;
    int d = (days % 365) % 30;

    List<String> parts = [];
    if (y > 0) parts.add('${y}y');
    if (m > 0) parts.add('${m}m');
    if (d > 0 || parts.isEmpty) parts.add('${d}d');

    return 'Expires in ${parts.join(' ')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(cornerRadius: 32, cornerSmoothing: 1),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 32,
                  cornerSmoothing: 1,
                ),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Icon box
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, color: const Color(0xFFFF6B35), size: 26),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${asset.brand} ${asset.category}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (asset.endDate != null && showExpiryDays) ...[
                        const SizedBox(height: 6),
                        Text(
                          _statusLabel,
                          style: TextStyle(
                            color: _statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],


                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Status + price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (asset.endDate != null)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: _globalHasPieChartAnimated
                                ? (asset.progressValue < 0.01 ? 0.01 : asset.progressValue)
                                : 0.0,
                            end: (asset.progressValue < 0.01 ? 0.01 : asset.progressValue),
                          ),
                          duration: _globalHasPieChartAnimated
                              ? Duration.zero
                              : const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return CustomPaint(
                              painter: _PieChartPainter(
                                progress: value,
                                color: _statusColor,
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (asset.price > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '\$${asset.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Summary Tile ─────────────────────────────────────────────────────────────
class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _SummaryTile({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ── Search Screen ────────────────────────────────────────────────────────────
class AssetSearchScreen extends StatefulWidget {
  const AssetSearchScreen({super.key});

  @override
  State<AssetSearchScreen> createState() => _AssetSearchScreenState();
}

class _AssetSearchScreenState extends State<AssetSearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _query = '';
  late AnimationController _fadeCtrl;
  late Animation<double> _imgFadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _imgFadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // Background image at top-left
          Positioned(
            top: 0,
            left: 0,
            child: FadeTransition(
              opacity: _imgFadeAnim,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.white, Colors.transparent],
                    stops: [0.25, 0.8],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.transparent],
                      stops: [0.4, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/images/tbg.png',
                    width: 340,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: const Color(0xFF141416),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 16,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowLeft01,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Search Input
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF141416),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 16,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            autofocus: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            onChanged: (val) => setState(() => _query = val),
                            decoration: InputDecoration(
                              hintText: 'Search assets...',
                              hintStyle: const TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(
                                left: 20,
                                right: 10,
                                top: 16,
                                bottom: 16,
                              ),
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      icon: const HugeIcon(
                                        icon: HugeIcons.strokeRoundedCancel01,
                                        color: Colors.white54,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _query = '');
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Results Area
                Expanded(child: _buildResults()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.08),
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              'Search your vault',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<Asset>>(
      future: DatabaseService.searchAssets(_query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
          );
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_rounded,
                  color: Colors.white.withValues(alpha: 0.08),
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  'No assets found',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 3),
          itemBuilder: (context, index) {
            return _AssetCard(
              asset: results[index],
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (_, animation, __) => SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: AssetDetailScreen(asset: results[index]),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PieChartPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final sweepAngle = 2 * 3.141592653589793 * progress;
    // -pi/2 is the top of the circle. true means useCenter to draw a pie wedge
    canvas.drawArc(rect, -3.141592653589793 / 2, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(_PieChartPainter old) {
    return old.progress != progress || old.color != color;
  }
}
