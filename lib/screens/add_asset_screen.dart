import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/models/entity_result.dart';
import '../core/models/asset.dart';
import '../core/services/database_service.dart';
import '../core/services/entity_extractor_service.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:hugeicons/hugeicons.dart';

// ── Add Asset Screen ─────────────────────────────────────────────────────────
class AddAssetScreen extends StatefulWidget {
  final List<EntityResult>? initialEntities;
  final String? initialText;
  final String? initialImagePath;
  final Asset? editAsset;
  const AddAssetScreen({
    super.key,
    this.initialEntities,
    this.initialText,
    this.initialImagePath,
    this.editAsset,
  });

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _anim;

  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedCategory = 'Document';
  DateTime? _purchaseDate;
  DateTime? _warrantyExpiry;
  bool _saving = false;
  bool _retrying = false;
  bool _showBrand = false;
  bool _showPrice = false;
  List<String> _extractedTags = [];
  List<EntityResult>? _currentEntities;

  static const _categories = [
    'Receipt',
    'Warranty',
    'ID Proof',
    'Passport',
    'Contract',
    'Medical Record',
    'Certificate',
    'Insurance Policy',
    'Vehicle Reg.',
    'Tax Document',
    'Document',
    'Other',
  ];

  static const _categoryIcons = <String, IconData>{
    'Receipt': Icons.receipt_long_rounded,
    'Warranty': Icons.verified_user_rounded,
    'ID Proof': Icons.badge_rounded,
    'Passport': Icons.flight_takeoff_rounded,
    'Contract': Icons.handshake_rounded,
    'Medical Record': Icons.medical_services_rounded,
    'Certificate': Icons.workspace_premium_rounded,
    'Insurance Policy': Icons.health_and_safety_rounded,
    'Vehicle Reg.': Icons.directions_car_rounded,
    'Tax Document': Icons.request_quote_rounded,
    'Document': Icons.description_rounded,
    'Other': Icons.inventory_2_rounded,
  };

  @override
  void initState() {
    super.initState();
    _currentEntities = widget.initialEntities;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.fastOutSlowIn));
    _ctrl.forward();

    _autoFill();
  }

  void _autoFill() {
    if (widget.editAsset != null) {
      final a = widget.editAsset!;
      _nameCtrl.text = a.name;
      _brandCtrl.text = a.brand;
      if (a.brand.isNotEmpty) _showBrand = true;
      _selectedCategory = a.category;
      _serialCtrl.text = a.serial;
      _priceCtrl.text = a.price > 0 ? a.price.toStringAsFixed(2) : '';
      if (a.price > 0) _showPrice = true;
      _purchaseDate = a.startDate;
      _warrantyExpiry = a.endDate;

      return;
    }

    if (_currentEntities != null) {
      final dateEntities = _currentEntities!
          .where((e) => e.type == 'Date / Time')
          .toList();

      if (dateEntities.length == 1) {
        final e = dateEntities.first;
        if (e.detail != null && e.detail!.length >= 10) {
          final parsedDate = DateTime.tryParse(e.detail!.substring(0, 10));
          if (parsedDate != null && parsedDate.isAfter(DateTime.now())) {
            _warrantyExpiry = parsedDate;
            _purchaseDate = DateTime.now();
          } else {
            _purchaseDate = parsedDate;
          }
        }
      } else {
        for (final e in dateEntities) {
          if (e.detail != null && e.detail!.length >= 10) {
            final parsedDate = DateTime.tryParse(e.detail!.substring(0, 10));
            if (parsedDate != null) {
              if (parsedDate.isAfter(DateTime.now())) {
                _warrantyExpiry ??= parsedDate;
              } else {
                _purchaseDate ??= parsedDate;
              }
            }
          }
        }
      }

      for (final e in _currentEntities!) {
        if (e.type == 'Money' && _priceCtrl.text.isEmpty) {
          final m = RegExp(
            r'\d+(\.\d+)?',
          ).firstMatch(e.text.replaceAll(',', ''));
          if (m != null) _priceCtrl.text = m.group(0)!;
        } else if ((e.type == 'Tracking #' ||
                e.type == 'Payment Card' ||
                e.type == 'IBAN') &&
            _serialCtrl.text.isEmpty) {
          _serialCtrl.text = e.text;
        } else if (e.type == 'Driving License') {
          _serialCtrl.text = e.text;
        }
      }
    }

    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      bool foundPaymentCard =
          _currentEntities?.any(
            (e) => e.type == 'Payment Card' || e.type == 'IBAN',
          ) ??
          false;
      bool foundDocument = RegExp(
        r'\b(invoice|receipt|statement|bill|contract|certificate)\b',
        caseSensitive: false,
      ).hasMatch(widget.initialText!);
      bool foundIDProof = RegExp(
        r'\b(passport|driver license|id card|identity|ssn|aadhar|pan card|voter id)\b',
        caseSensitive: false,
      ).hasMatch(widget.initialText!);
      bool foundDL =
          RegExp(
            r'\b(driving license|dl no|licence)\b',
            caseSensitive: false,
          ).hasMatch(widget.initialText!) ||
          (_currentEntities?.any((e) => e.type == 'Driving License') ?? false);

      if (foundPaymentCard) {
        _selectedCategory = 'Document';
        if (RegExp(
          r'\b(debit)\b',
          caseSensitive: false,
        ).hasMatch(widget.initialText!)) {
          _nameCtrl.text = 'Debit Card';
        } else if (RegExp(
          r'\b(credit)\b',
          caseSensitive: false,
        ).hasMatch(widget.initialText!)) {
          _nameCtrl.text = 'Credit Card';
        } else {
          _nameCtrl.text = 'ATM Card';
        }
      } else if (foundDL) {
        _selectedCategory = 'ID Proof';
        _nameCtrl.text = 'Driving License';
      } else if (foundIDProof) {
        _selectedCategory = 'ID Proof';
      } else if (foundDocument) {
        _selectedCategory = 'Document';
      }

      final lines = widget.initialText!
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e.length > 2)
          .toList();

      if (lines.isNotEmpty && _nameCtrl.text.isEmpty) {
        // Try to avoid using raw numbers/symbols as name
        final nameCandidates = lines
            .where((l) => !RegExp(r'^[\d\s\W_]+$').hasMatch(l))
            .toList();
        if (nameCandidates.isNotEmpty) {
          _nameCtrl.text = nameCandidates.first;
        } else {
          _nameCtrl.text = lines.first;
        }
      }

      if (_brandCtrl.text.isEmpty) {
        // Only assign brand if it resembles a common brand or bank
        final knownBrands = RegExp(
          r'\b(Apple|Samsung|Sony|LG|Dell|HP|Lenovo|Asus|Acer|Microsoft|Visa|Mastercard|American Express|Discover|Chase|Citi|Bank of America|Wells Fargo|Capital One)\b',
          caseSensitive: false,
        );
        final match = knownBrands.firstMatch(widget.initialText!);
        if (match != null) {
          _brandCtrl.text = match.group(0)!;
        }
      }

      if (_serialCtrl.text.isEmpty) {
        final serialCandidates = lines.where((l) {
          final stripped = l.replaceAll(RegExp(r'[\s-]'), '');
          return stripped.length >= 10 && RegExp(r'\d').hasMatch(stripped);
        }).toList();
        if (serialCandidates.isNotEmpty) {
          _serialCtrl.text = serialCandidates.first;
        }
      }

        if (_brandCtrl.text.isNotEmpty) {
          _showBrand = true;
        }
        if (_priceCtrl.text.isNotEmpty) {
          _showPrice = true;
        }

        // Store all extracted text separated by commas, removing meaningless stop words
        final stopWords = {
          'is', 'that', 'this', 'the', 'a', 'an', 'and', 'or', 'of', 'to', 'in', 
          'it', 'was', 'for', 'on', 'with', 'as', 'by', 'at', 'from', 'are', 'be', 'were', 'like'
        };
        
        final words = widget.initialText!
            .replaceAll(RegExp(r'[^\w\s]'), ' ')
            .split(RegExp(r'\s+'))
            .map((w) => w.trim())
            .where((w) {
              if (w.isEmpty) return false;
              // Remove single letters unless they are digits
              if (w.length < 2 && !RegExp(r'\d').hasMatch(w)) return false;
              return !stopWords.contains(w.toLowerCase());
            })
            .toList();

        if (words.isNotEmpty) {
          _extractedTags = words;
        }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _serialCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({bool isPurchase = false}) async {
    final now = DateTime.now();
    DateTime initial;
    DateTime first;
    DateTime last;

    if (isPurchase) {
      first = DateTime(1000);
      last = DateTime(2100);
      initial = _purchaseDate ?? now;
      if (initial.isBefore(first)) initial = first;
      if (initial.isAfter(last)) initial = last;
    } else {
      first = DateTime(1000);
      last = DateTime(2100);
      initial = _warrantyExpiry ?? now.add(const Duration(days: 365));
      if (initial.isBefore(first)) initial = first;
      if (initial.isAfter(last)) initial = last;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF6B35),
            onPrimary: Colors.white,
            surface: Color(0xFF1A1A1A),
            onSurface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF111111),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isPurchase) {
          _purchaseDate = picked;
        } else {
          _warrantyExpiry = picked;
        }
      });
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Select date';
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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.initialText != null || widget.initialEntities != null) {
      final confirmed = await _showScanWarningSheet();
      if (confirmed != true) return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final iconData =
        _categoryIcons[_selectedCategory] ?? Icons.inventory_2_rounded;
    final newAsset = widget.editAsset ?? Asset();
    final p = double.tryParse(_priceCtrl.text.trim().replaceAll(',', ''));
    
    // Auto-select the comprehensive note if user leaves notes blank
    if (_notesCtrl.text.trim().isEmpty) {
      final comprehensiveNote = _premadeNotes.firstWhere(
        (n) => n['title'] == 'Detailed Summary',
        orElse: () => _premadeNotes.first,
      );
      _notesCtrl.text = comprehensiveNote['content']!;
    }

    newAsset
      ..name = _nameCtrl.text.trim()
      ..brand = _brandCtrl.text.trim()
      ..category = _selectedCategory
      ..serial = _serialCtrl.text.trim()
      ..price = p ?? 0.0
      ..startDate = _purchaseDate
      ..endDate = _warrantyExpiry
      ..notes = _notesCtrl.text.trim()
      ..scannedRawText = widget.initialText
      ..iconCodePoint = iconData.codePoint
      ..iconFontFamily = iconData.fontFamily ?? ''
      ..iconFontPackage = iconData.fontPackage;

    if (widget.editAsset == null) {
      newAsset.createdAt = DateTime.now();
      newAsset.isAvailable = true;
    }

    if (widget.editAsset != null) {
      await DatabaseService.updateAsset(newAsset);
    } else {
      await DatabaseService.saveAsset(newAsset);
    }

    if (!mounted) return;
    Navigator.pop(context, newAsset); // return the asset
  }

  Future<bool?> _showScanWarningSheet() {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: Color(0xFF161616),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Are these details correct?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please review the auto-filled data.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Review',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8AFF80),
                        foregroundColor: const Color(0xFF000000),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, String>> get _premadeNotes {
    final name = _nameCtrl.text.trim();
    final brand = _brandCtrl.text.trim();
    final serial = _serialCtrl.text.trim();
    final price = _priceCtrl.text.trim();
    final category = _selectedCategory;
    
    final purchaseStr = _purchaseDate != null ? _fmt(_purchaseDate) : '';
    final expiryStr = _warrantyExpiry != null ? _fmt(_warrantyExpiry) : '';

    final List<Map<String, String>> notes = [];

    // 1. Comprehensive natural paragraph
    final List<String> parts = [];
    parts.add('This is a $category');
    if (brand.isNotEmpty || name.isNotEmpty) {
      final item = [brand, name].where((e) => e.isNotEmpty).join(' ');
      parts.add('for a $item');
    }
    if (price.isNotEmpty) {
      parts.add('purchased for \$$price');
    }
    if (purchaseStr.isNotEmpty && purchaseStr != 'Select date') {
      parts.add('on $purchaseStr');
    }
    if (serial.isNotEmpty) {
      parts.add('with serial number $serial');
    }
    String longNote = parts.join(' ') + '.';
    
    if (expiryStr.isNotEmpty && expiryStr != 'Select date') {
      if (category == 'Warranty') {
        longNote += '\nThe warranty is valid until $expiryStr.';
      } else {
        longNote += '\nIt expires on $expiryStr.';
      }
    }
    notes.add({'title': 'Detailed Summary', 'content': longNote});

    // 2. Clean bulleted format
    final List<String> bullets = [];
    if (name.isNotEmpty) bullets.add('Item: $name');
    if (brand.isNotEmpty) bullets.add('Brand: $brand');
    if (serial.isNotEmpty) bullets.add('Serial: $serial');
    if (price.isNotEmpty) bullets.add('Cost: \$$price');
    if (purchaseStr.isNotEmpty && purchaseStr != 'Select date') bullets.add('Date: $purchaseStr');
    if (expiryStr.isNotEmpty && expiryStr != 'Select date') bullets.add('Expires: $expiryStr');
    
    if (bullets.isNotEmpty) {
      notes.add({'title': 'Bullet Points', 'content': bullets.join('\n')});
    }

    // 3. Short single-liners
    if (price.isNotEmpty && name.isNotEmpty && purchaseStr.isNotEmpty && purchaseStr != 'Select date') {
      notes.add({'title': 'Purchase Info', 'content': 'Purchased $name on $purchaseStr for \$$price.'});
    }

    if (serial.isNotEmpty && name.isNotEmpty) {
      notes.add({'title': 'Serial Info', 'content': '$name (S/N: $serial)'});
    }

    if (notes.isEmpty) {
      notes.add({'title': 'Basic', 'content': 'Document for $category.'});
    }

    return notes;
  }

  Widget _buildPremadeNotesChips() {
    return AnimatedBuilder(
      animation: Listenable.merge([_nameCtrl, _brandCtrl, _serialCtrl, _priceCtrl]),
      builder: (context, _) {
        final notes = _premadeNotes;
        if (notes.isEmpty) return const SizedBox.shrink();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: notes.map((note) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(
                    note['title']!, 
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF181818),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onPressed: () {
                    setState(() {
                      _notesCtrl.text = note['content']!;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showAddMoreDetailsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: const BoxDecoration(
              color: Color(0xFF161616),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Additional Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                if (!_showBrand)
                  ListTile(
                    leading: const Icon(Icons.business_rounded, color: Colors.white70),
                    title: const Text('Add Brand / Make', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _showBrand = true);
                    },
                  ),
                if (!_showPrice)
                  ListTile(
                    leading: const Icon(Icons.attach_money_rounded, color: Colors.white70),
                    title: const Text('Add Purchase Price', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _showPrice = true);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: SlideTransition(
          position: _anim,
          child: Column(
            children: [
              // ── Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'New Asset',
                      style: TextStyle(
                        fontFamily: 'LibreBaskerville',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (widget.initialText != null) ...[
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Retake',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _retrying ? null : _retryExtraction,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: _retrying
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // ── Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 44, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDigitalCardPreview(),
                        // Category grid
                        _SectionLabel('Category'),
                        const SizedBox(height: 12),
                        _CategoryGrid(
                          categories: _categories,
                          icons: _categoryIcons,
                          selected: _selectedCategory,
                          onSelect: (c) {
                            setState(() {
                              _selectedCategory = c;
                            });
                          },
                        ),
                        const SizedBox(height: 28),

                        // Name
                        _SectionLabel('Asset / Document Name'),
                        const SizedBox(height: 10),
                        _TField(
                          controller: _nameCtrl,
                          hint: 'e.g. Passport',
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),

                        // Brand
                        if (_showBrand) ...[
                          _SectionLabel('Brand / Make'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _TField(
                                  controller: _brandCtrl,
                                  hint: 'e.g. Apple, Toyota',
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _brandCtrl.clear();
                                    _showBrand = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6B35),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: Colors.black, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Serial number
                        _SectionLabel('Serial Number'),
                        const SizedBox(height: 10),
                        _TField(
                          controller: _serialCtrl,
                          hint: 'e.g. C02XL0HAJGH8',
                          mono: true,
                        ),
                        const SizedBox(height: 20),

                        // Purchase Price
                        if (_showPrice) ...[
                          _SectionLabel('Purchase Price'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _TField(
                                  controller: _priceCtrl,
                                  hint: '0.00',
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  prefix: '\$ ',
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _priceCtrl.clear();
                                    _showPrice = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6B35),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: Colors.black, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Notes
                        _SectionLabel('Notes'),
                        const SizedBox(height: 10),
                        _TField(
                          controller: _notesCtrl,
                          hint: 'Additional details...',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        _buildPremadeNotesChips(),
                        if (_extractedTags.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _SectionLabel('Asset Tags'),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 20),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF181818),
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 16,
                                  cornerSmoothing: 1,
                                ),
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                            ),
                            width: double.infinity,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(left: 16, right: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: _extractedTags.map((tag) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF1E1E1E),
                                        shape: SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius(
                                            cornerRadius: 10,
                                            cornerSmoothing: 1,
                                          ),
                                          side: BorderSide(
                                            color: Colors.white.withValues(alpha: 0.05),
                                          ),
                                        ),
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: '# ',
                                              style: TextStyle(
                                                color: Color(0xFFFF6B35),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            TextSpan(
                                              text: tag,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (!_showBrand || !_showPrice)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _showAddMoreDetailsSheet,
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                              label: const Text('Add Optional Fields'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFFF6B35),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                backgroundColor: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Dates
                        _SectionLabel('Dates'),
                        const SizedBox(height: 12),
                        _DateRow(
                          label: 'Date Purchased / Issued',
                          value: _fmt(_purchaseDate),
                          icon: Icons.calendar_today_rounded,
                          hasValue: _purchaseDate != null,
                          onTap: () => _pickDate(isPurchase: true),
                        ),
                        const SizedBox(height: 12),

                        _DateRow(
                          label: _selectedCategory == 'Warranty'
                              ? 'Warranty Expires'
                              : 'Expiry Date',
                          value: _fmt(_warrantyExpiry),
                          icon: _selectedCategory == 'Warranty'
                              ? Icons.shield_outlined
                              : Icons.event_busy_rounded,
                          hasValue: _warrantyExpiry != null,
                          onTap: () => _pickDate(isPurchase: false),
                        ),
                        const SizedBox(height: 48),

                        // Save button
                        GestureDetector(
                          onTap: _saving ? null : _save,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: _saving
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: _saving
                                ? const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Color(0xFF0E0E0E),
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Save Asset',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF0E0E0E),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalCardPreview() {
    return AnimatedBuilder(
      animation: Listenable.merge([_nameCtrl, _brandCtrl, _serialCtrl]),
      builder: (context, _) {
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
                          _categoryIcons[_selectedCategory] ?? Icons.inventory_2_rounded,
                          size: 14,
                          color: const Color(0xFFFF6B35),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedCategory.toUpperCase(),
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
                  if (_brandCtrl.text.isNotEmpty)
                    Text(
                      _brandCtrl.text.toUpperCase(),
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
              Text(
                _nameCtrl.text.isEmpty ? 'Asset Name' : _nameCtrl.text,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_rounded, size: 16, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(width: 6),
                  Text(
                    _serialCtrl.text.isEmpty ? 'S/N: •••• ••••' : 'S/N: ${_serialCtrl.text}',
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
              if (_purchaseDate != null || _warrantyExpiry != null) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_purchaseDate != null)
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
                            _fmt(_purchaseDate),
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
                    if (_purchaseDate != null && _warrantyExpiry != null)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Builder(
                            builder: (context) {
                              final total = _warrantyExpiry!.difference(_purchaseDate!).inMilliseconds;
                              final elapsed = DateTime.now().difference(_purchaseDate!).inMilliseconds;
                              double progress = 0.0;
                              if (total > 0) {
                                progress = (elapsed / total).clamp(0.0, 1.0);
                              } else {
                                progress = 1.0;
                              }
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
                                        widthFactor: progress,
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
                                    '${(progress * 100).toInt()}% ELAPSED',
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
                          ),
                        ),
                      ),
                    if (_warrantyExpiry != null)
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
                            _fmt(_warrantyExpiry),
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
      },
    );
  }

  Future<void> _retryExtraction() async {
    if (widget.initialText == null || widget.initialText!.isEmpty) return;
    setState(() => _retrying = true);

    // Clear out existing fields before re-filling
    _nameCtrl.clear();
    _brandCtrl.clear();
    _serialCtrl.clear();
    _priceCtrl.clear();
    _purchaseDate = null;
    _warrantyExpiry = null;

    final newEntities = await EntityExtractorService.instance.extract(
      widget.initialText!,
    );

    if (!mounted) return;

    setState(() {
      _currentEntities = newEntities;
      _retrying = false;
    });

    _autoFill();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Auto-fill refreshed!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF2A2A2A),
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ── Text Field ────────────────────────────────────────────────────────────────
class _TField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final bool mono;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _TField({
    required this.controller,
    required this.hint,
    this.prefix,
    this.mono = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        fontFamily: mono ? 'monospace' : null,
        letterSpacing: mono ? 0.5 : 0,
      ),
      cursorColor: const Color(0xFFFF6B35),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.2),
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: mono ? 'monospace' : null,
        ),
        prefixText: prefix,
        prefixStyle: const TextStyle(
          color: Color(0xFFFF6B35),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: const Color(0xFF181818),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
      ),
    );
  }
}

// ── Category Grid ─────────────────────────────────────────────────────────────
class _CategoryGrid extends StatelessWidget {
  final List<String> categories;
  final Map<String, IconData> icons;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryGrid({
    required this.categories,
    required this.icons,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((c) {
        return _CategoryChip(
          category: c,
          icon: icons[c] ?? Icons.inventory_2_rounded,
          isSelected: c == selected,
          onTap: () => onSelect(c),
        );
      }).toList(),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final String category;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> with SingleTickerProviderStateMixin {
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
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          final sigma = (_scale.value - 1.0) * 15; // 0 to 1.5 blur
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected ? const Color(0xFFFF6B35) : const Color(0xFF181818),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: widget.isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.07),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.isSelected ? Colors.white : Colors.white.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 7),
              Text(
                widget.category,
                style: TextStyle(
                  color: widget.isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Date Row ──────────────────────────────────────────────────────────────────
class _DateRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool hasValue;
  final VoidCallback onTap;

  const _DateRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: ShapeDecoration(
          color: const Color(0xFF181818),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
            side: BorderSide(
              color: hasValue
                  ? const Color(0xFFFF6B35).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: hasValue
                  ? const Color(0xFFFF6B35)
                  : Colors.white.withValues(alpha: 0.25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: hasValue
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.2),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.15),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
