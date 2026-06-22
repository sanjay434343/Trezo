import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/services/auth_service.dart';
import '../core/services/database_service.dart';
import '../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  bool _notificationsEnabled = true;
  bool _autoScanEnabled = false;
  bool _appLockEnabled = false;
  bool _showExpiryDays = true;

  int _totalAssets = 0;
  int _expiringAssets = 0;
  double _totalValue = 0.0;
  String _userName = 'User';
  String _userEmail = '';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutExpo);
    _ctrl.forward();
    
    _loadAppLockState();
    _loadSettings();
    _loadUserData();
    _loadAssetStats();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _autoScanEnabled = prefs.getBool('auto_scan_enabled') ?? false;
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _showExpiryDays = prefs.getBool('show_expiry_days') ?? true;
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          _userName = user.displayName ?? 'User';
          _userEmail = user.email ?? '';
          _photoUrl = user.photoURL;
        });
      }
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          final data = doc.data()!;
          setState(() {
            _userName = data['displayName'] as String? ?? _userName;
            _userEmail = data['email'] as String? ?? _userEmail;
            _photoUrl = data['photoURL'] as String? ?? _photoUrl;
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _loadAssetStats() async {
    final all = await DatabaseService.getAllAssets();
    int total = all.length;
    int expiring = 0;
    double value = 0.0;
    for (var a in all) {
      if (a.status == 'expiring') expiring++;
      value += a.price;
    }
    if (mounted) {
      setState(() {
        _totalAssets = total;
        _expiringAssets = expiring;
        _totalValue = value;
      });
    }
  }

  Future<void> _loadAppLockState() async {
    final enabled = await AuthService.isAppLockEnabled();
    if (mounted) {
      setState(() => _appLockEnabled = enabled);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onAppLockToggled(bool value) async {
    if (value) {
      // Need to set up a PIN
      final success = await context.push<bool>('/lock?setup=true');
      if (success == true) {
        setState(() => _appLockEnabled = true);
      } else {
        // User cancelled or failed setup, revert toggle
        setState(() => _appLockEnabled = false);
      }
    } else {
      // Disable
      await AuthService.setAppLockEnabled(false);
      setState(() => _appLockEnabled = false);
    }
  }

  void _showLogoutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogoutSheet(
        onConfirm: () {
          Navigator.pop(context); // close sheet
          context.go('/splash');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _anim,
          child: Column(
            children: [
              // ── Top bar
              Padding(
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
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                  ],
                ),
              ),

              // ── Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar card
                      _buildAvatarCard(),
                      const SizedBox(height: 32),

                      // Preferences section
                      _SectionHeader(label: 'Preferences'),
                      const SizedBox(height: 12),
                      _ToggleRow(
                        icon: Icons.notifications_none_rounded,
                        label: 'Warranty Reminders',
                        subtitle: 'Get notified before warranties expire',
                        value: _notificationsEnabled,
                        onChanged: (v) async {
                          setState(() => _notificationsEnabled = v);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('notifications_enabled', v);
                        },
                      ),
                      const SizedBox(height: 10),
                      _ToggleRow(
                        icon: Icons.document_scanner_rounded,
                        label: 'Auto-scan on open',
                        subtitle: 'Launch camera when adding an asset',
                        value: _autoScanEnabled,
                        onChanged: (v) async {
                          setState(() => _autoScanEnabled = v);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('auto_scan_enabled', v);
                        },
                      ),
                      const SizedBox(height: 10),
                      _ToggleRow(
                        icon: Icons.timer_outlined,
                        label: 'Show Expiry Days',
                        subtitle: 'Show exactly how many days are left',
                        value: _showExpiryDays,
                        onChanged: (v) async {
                          setState(() => _showExpiryDays = v);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('show_expiry_days', v);
                        },
                      ),
                      const SizedBox(height: 10),
                      _ToggleRow(
                        icon: Icons.lock_outline_rounded,
                        label: 'App Lock',
                        subtitle: 'Require biometric or PIN to open',
                        value: _appLockEnabled,
                        onChanged: _onAppLockToggled,
                      ),
                      const SizedBox(height: 28),

                      // About section
                      _SectionHeader(label: 'About'),
                      const SizedBox(height: 12),
                      _InfoTile(
                        icon: Icons.shield_outlined,
                        label: 'Privacy Policy',
                        onTap: () async {
                           try { await launchUrl(Uri.parse('https://example.com/privacy')); } catch (_) {}
                        },
                      ),
                      const SizedBox(height: 10),
                      _InfoTile(
                        icon: Icons.article_outlined,
                        label: 'Terms of Service',
                        onTap: () async {
                           try { await launchUrl(Uri.parse('https://example.com/terms')); } catch (_) {}
                        },
                      ),
                      const SizedBox(height: 10),
                      _InfoTile(
                        icon: Icons.star_border_rounded,
                        label: 'Rate Trezo',
                        onTap: () async {
                           try { await launchUrl(Uri.parse('https://example.com/rate')); } catch (_) {}
                        },
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161616),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.info_outline_rounded,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  size: 18),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'App Version',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '1.0.0 (Build 1)',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Danger zone
                      _SectionHeader(label: 'Account'),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _showLogoutSheet,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.12)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded,
                                  color: Colors.redAccent.withValues(alpha: 0.8),
                                  size: 20),
                              const SizedBox(width: 14),
                              Text(
                                'Sign Out',
                                style: TextStyle(
                                  color: Colors.redAccent.withValues(alpha: 0.9),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tagline
                      Center(
                        child: Text(
                          'Made with ♥ · Everything stays local',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.12),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Avatar circle
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              _photoUrl != null
                  ? CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(_photoUrl!),
                      backgroundColor: Colors.transparent,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF9F6B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E0E),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF161616), width: 2),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _StatChip(value: '$_totalAssets', label: 'Assets'),
              const SizedBox(width: 10),
              _StatChip(
                  value: '$_expiringAssets',
                  label: 'Expiring',
                  color: const Color(0xFFFF6B35)),
              const SizedBox(width: 10),
              _StatChip(
                  value: '\$${_totalValue.toStringAsFixed(0)}',
                  label: 'Total Value',
                  color: const Color(0xFF8AFF80)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.25),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFFFF6B35).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: value
                  ? const Color(0xFFFF6B35)
                  : Colors.white.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFFF6B35),
            activeTrackColor: const Color(0xFFFF6B35).withValues(alpha: 0.25),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.3),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.07),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: Colors.white.withValues(alpha: 0.4), size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.15), size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.value,
    required this.label,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logout bottom sheet ───────────────────────────────────────────────────────

class _LogoutSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  const _LogoutSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout_rounded,
                color: Colors.redAccent, size: 28),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sign Out?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You\'ll need to sign in again to access your vault.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onConfirm,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Yes, Sign Out',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
