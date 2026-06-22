import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/models/asset.dart';
import '../core/services/database_service.dart';
import '../core/services/reminder_service.dart';
import '../core/services/auth_service.dart';
import 'add_asset_screen.dart';
import 'lock_screen.dart';
import 'package:figma_squircle/figma_squircle.dart';

class AssetDetailScreen extends StatefulWidget {
  final Asset asset;
  const AssetDetailScreen({super.key, required this.asset});

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen>
    with SingleTickerProviderStateMixin {
  late Asset _currentAsset;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _currentAsset = widget.asset;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutExpo);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (_currentAsset.status) {
      case 'expiring':
        return const Color(0xFFFF6B35);
      case 'expired':
        return Colors.redAccent;
      default:
        return const Color(0xFF8AFF80);
    }
  }

  String get _statusLabel {
    switch (_currentAsset.status) {
      case 'expiring':
        return 'Expiring Soon';
      case 'expired':
        return 'Expired';
      default:
        return 'Active';
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'N/A';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _getTimeRemaining(int? days) {
    if (days == null) return 'N/A';
    if (days < 0) return 'Expired';
    if (days == 0) return 'Expires today';

    int y = days ~/ 365;
    int m = (days % 365) ~/ 30;
    int d = (days % 365) % 30;

    List<String> parts = [];
    if (y > 0) parts.add('${y}y');
    if (m > 0) parts.add('${m}m');
    if (d > 0 || parts.isEmpty) parts.add('${d}d');

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final a = _currentAsset;
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: FadeTransition(
                  opacity: _anim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDigitalCardPreview(),
                      // Hero icon + status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161616),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              IconData(
                                a.iconCodePoint,
                                fontFamily: a.iconFontFamily,
                                fontPackage: a.iconFontPackage,
                              ),
                              color: const Color(0xFFFF6B35),
                              size: 34,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _statusColor.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _statusLabel,
                                  style: TextStyle(
                                    color: _statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Name
                      Text(
                        a.name,
                        style: const TextStyle(
                          fontFamily: 'LibreBaskerville',
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [a.brand, a.category].where((s) => s.trim().isNotEmpty).join(' · '),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Price card
                      if (a.price > 0) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161616),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Purchase Value',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '\$${a.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Details grid
                      _InfoSection(
                        title: 'Asset Details',
                        rows: [
                          if (a.serial.trim().isNotEmpty &&
                              a.serial.trim().toLowerCase() != 'n/a' &&
                              a.serial.trim() != '-')
                            _InfoRow(
                              label: 'Serial Number',
                              value: a.serial,
                              mono: true,
                            ),
                          if (a.category.trim().isNotEmpty)
                            _InfoRow(label: 'Category', value: a.category),
                          if (a.brand.trim().isNotEmpty)
                            _InfoRow(label: 'Brand', value: a.brand),
                          if (a.notes != null && a.notes!.trim().isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notes',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  a.notes!.trim(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (a.startDate != null || a.endDate != null)
                        _InfoSection(
                          title: 'Warranty Info',
                          rows: [
                            if (a.startDate != null)
                              _InfoRow(
                                label: 'Purchased',
                                value: _fmt(a.startDate),
                              ),
                            if (a.endDate != null)
                              _InfoRow(
                                label: 'Expires',
                                value: _fmt(a.endDate),
                                valueColor: _statusColor,
                              ),
                            if (a.endDate != null)
                              _InfoRow(
                                label: 'Remaining',
                                value: _getTimeRemaining(a.daysUntilExpiry),
                              ),
                          ],
                        ),

                      const SizedBox(height: 32),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: 'Edit',
                              icon: HugeIcons.strokeRoundedEdit01,
                              onTap: () async {
                                final updated = await Navigator.push<Asset>(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, a, _) => AddAssetScreen(editAsset: _currentAsset),
                                    transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
                                  ),
                                );
                                if (updated != null && mounted) {
                                  setState(() {
                                    _currentAsset = updated;
                                  });
                                }
                              },
                              outlined: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              label: 'Reminder',
                              icon: HugeIcons.strokeRoundedNotification01,
                              onTap: () {
                                _showReminderSheet(context);
                              },
                              primary: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              label: 'Delete',
                              icon: HugeIcons.strokeRoundedDelete01,
                              onTap: () => _showDeleteConfirmation(context),
                              danger: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedDelete01, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            const Text('Delete Asset?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'This asset will be removed from your list. You can restore it later if needed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Cancel',
                    icon: HugeIcons.strokeRoundedCancel01,
                    outlined: true,
                    onTap: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'Delete',
                    icon: HugeIcons.strokeRoundedDelete01,
                    danger: true,
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmDeleteWithAuth(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteWithAuth(BuildContext context) async {
    final isLocked = await AuthService.isAppLockEnabled();
    if (isLocked) {
      if (!context.mounted) return;
      bool? authSuccess = await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LockScreen(isVerificationMode: true),
          transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
        ),
      );
      if (authSuccess != true) return;
    }
    await DatabaseService.softDeleteAsset(_currentAsset.id);
    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showReminderSheet(BuildContext context) {
    bool oneWeek = true;
    bool oneMonth = true;
    bool customEnabled = _currentAsset.customReminderDate != null ? _currentAsset.customReminderEnabled : true;
    DateTime? customDate = _currentAsset.customReminderDate ?? _currentAsset.endDate;
    TimeOfDay? customTime = _currentAsset.customReminderDate != null 
        ? TimeOfDay.fromDateTime(_currentAsset.customReminderDate!) 
        : const TimeOfDay(hour: 8, minute: 0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set Reminder',
                    style: TextStyle(
                      fontFamily: 'LibreBaskerville',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When should we notify you about ${_currentAsset.name}?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ReminderOption(
                    label: '1 Week Before Expiry',
                    icon: Icons.date_range_rounded,
                    value: oneWeek,
                    onChanged: (val) {
                      setState(() => oneWeek = val);
                    },
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ReminderOption(
                    label: '1 Month Before Expiry',
                    icon: Icons.calendar_month_rounded,
                    value: oneMonth,
                    onChanged: (val) {
                      setState(() => oneMonth = val);
                    },
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit_calendar_rounded, color: Colors.white.withValues(alpha: 0.8), size: 20),
                            const SizedBox(width: 16),
                            const Text(
                              'Custom Date & Time',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: customEnabled,
                              onChanged: (val) => setState(() => customEnabled = val),
                              activeColor: const Color(0xFFFF6B35),
                            ),
                          ],
                        ),
                        if (customEnabled) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final d = await showDatePicker(
                                      context: ctx,
                                      initialDate: customDate ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (d != null) setState(() => customDate = d);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: Text(
                                        customDate == null
                                            ? 'Select Date'
                                            : '${customDate!.day}/${customDate!.month}/${customDate!.year}',
                                        style: TextStyle(
                                          color: customDate == null ? Colors.white.withValues(alpha: 0.5) : Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final t = await showTimePicker(
                                      context: ctx,
                                      initialTime: customTime ?? TimeOfDay.now(),
                                    );
                                    if (t != null) setState(() => customTime = t);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: Text(
                                        customTime == null
                                            ? 'Select Time'
                                            : customTime!.format(ctx),
                                        style: TextStyle(
                                          color: customTime == null ? Colors.white.withValues(alpha: 0.5) : Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      if (customEnabled && (customDate == null || customTime == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                            'Custom reminder requires both date and time to be selected.',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: const Color(0xFF2A2A2A),
                          duration: const Duration(seconds: 1),
                          margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                        ));
                        return;
                      }

                      _currentAsset.reminderOneWeek = oneWeek;
                      _currentAsset.reminderOneMonth = oneMonth;
                      _currentAsset.customReminderEnabled = customEnabled;
                      if (customEnabled) {
                        _currentAsset.customReminderDate = DateTime(
                          customDate!.year, customDate!.month, customDate!.day,
                          customTime!.hour, customTime!.minute,
                        );
                      } else {
                        _currentAsset.customReminderDate = null;
                      }

                      await DatabaseService.updateAsset(_currentAsset);
                      await ReminderService.scheduleCustomReminderForAsset(_currentAsset);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                            'Reminders saved successfully.',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: const Color(0xFF2A2A2A),
                          duration: const Duration(seconds: 1),
                          margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                        ));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Text(
                          'Save Reminders',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDigitalCardPreview() {
    final a = _currentAsset;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 24,
            cornerSmoothing: 1,
          ),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Category Pill & Brand
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconData(
                        a.iconCodePoint,
                        fontFamily: a.iconFontFamily,
                        fontPackage: a.iconFontPackage,
                      ),
                      size: 14,
                      color: const Color(0xFFFF6B35),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      a.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFF6B35),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              if (a.brand.trim().isNotEmpty)
                Text(
                  a.brand.trim().toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Asset Name
          Text(
            a.name.isEmpty ? 'Asset Name' : a.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Serial Number
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_rounded, size: 16, color: Colors.white.withValues(alpha: 0.3)),
              const SizedBox(width: 6),
              Text(
                a.serial.trim().isEmpty ? 'S/N: •••• ••••' : 'S/N: ${a.serial}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          if (a.startDate != null || a.endDate != null) ...[
            const SizedBox(height: 32),
            // Dates Timeline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (a.startDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PURCHASED',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 9,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fmt(a.startDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(),

                if (a.startDate != null && a.endDate != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Builder(
                        builder: (context) {
                          final total = a.endDate!.difference(a.startDate!).inMilliseconds;
                          final elapsed = DateTime.now().difference(a.startDate!).inMilliseconds;
                          double progress = 0.0;
                          if (total > 0) {
                            progress = (elapsed / total).clamp(0.0, 1.0);
                          } else {
                            progress = 1.0;
                          }
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: progress),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutExpo,
                            builder: (context, animatedProgress, child) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      Container(
                                        height: 4,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: animatedProgress,
                                        child: Stack(
                                          alignment: Alignment.centerRight,
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF6B35),
                                                borderRadius: BorderRadius.circular(2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFFFF6B35).withValues(alpha: 0.5),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              right: -4,
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFF6B35),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xFFFF6B35),
                                                      blurRadius: 12,
                                                      spreadRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${(animatedProgress * 100).toStringAsFixed(2)}% ELAPSED',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      fontSize: 8,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                if (a.endDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'EXPIRES',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 9,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fmt(a.endDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReminderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool? value;
  final ValueChanged<bool>? onChanged;

  const _ReminderOption({
    required this.label, 
    required this.icon, 
    required this.onTap,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (value != null && onChanged != null) {
          onChanged!(!value!);
        } else {
          onTap();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (value != null)
              Switch(
                value: value!,
                onChanged: onChanged,
                activeColor: const Color(0xFFFF6B35),
              )
            else
              Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Info Section ─────────────────────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _InfoSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  child: e.value,
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.05),
                    indent: 20,
                    endIndent: 20,
                  ),
              ],
            );
          }),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  final Color? valueColor;
  const _InfoRow({
    required this.label,
    required this.value,
    this.mono = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor ?? Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: mono ? 'monospace' : null,
              letterSpacing: mono ? 0.5 : 0,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final String label;
  final List<List<dynamic>> icon;
  final VoidCallback onTap;
  final bool outlined;
  final bool primary;
  final bool danger;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
    this.primary = false,
    this.danger = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() async {
    widget.onTap();
    await _ctrl.forward();
    if (mounted) {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (widget.danger) {
      bg = Colors.redAccent;
      fg = Colors.white;
    } else if (widget.primary) {
      bg = const Color(0xFFFF6B35);
      fg = Colors.white;
    } else if (widget.outlined) {
      bg = Colors.white.withValues(alpha: 0.05);
      fg = Colors.white.withValues(alpha: 0.7);
    } else {
      bg = Colors.white;
      fg = const Color(0xFF0E0E0E);
    }

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          final sigma = (_scale.value - 1.0) * 15;
          Widget current = Transform.scale(
            scale: _scale.value,
            child: child,
          );
          if (sigma > 0) {
            current = ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: current,
            );
          }
          return current;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: widget.icon,
                color: fg,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: fg,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
