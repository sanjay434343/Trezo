import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/auth_service.dart';
import 'package:figma_squircle/figma_squircle.dart';
import '../core/theme/app_colors.dart';

class LockScreen extends StatefulWidget {
  final bool isSetupMode;
  final bool isVerificationMode;
  
  const LockScreen({
    super.key, 
    this.isSetupMode = false,
    this.isVerificationMode = false,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;
  bool _error = false;
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    if (widget.isSetupMode) return; // Don't use biometrics during setup
    final available = await AuthService.canUseBiometrics();
    setState(() {
      _biometricsAvailable = available;
    });
    if (available) {
      _attemptBiometrics();
    }
  }

  Future<void> _attemptBiometrics() async {
    final success = await AuthService.authenticateWithBiometrics();
    if (success && mounted) {
      if (widget.isVerificationMode) {
        context.pop(true);
      } else {
        context.go('/home');
      }
    }
  }

  void _onKeyPress(String key) async {
    if (_pin.length < 4) {
      setState(() {
        _pin += key;
        _error = false;
      });

      if (_pin.length == 4) {
        if (widget.isSetupMode) {
          _handleSetupStep();
        } else {
          _verifyPin();
        }
      }
    }
  }

  void _handleSetupStep() async {
    if (!_isConfirming) {
      setState(() {
        _confirmPin = _pin;
        _pin = '';
        _isConfirming = true;
      });
    } else {
      if (_pin == _confirmPin) {
        setState(() => _isLoading = true);
        await AuthService.setPin(_pin);
        await AuthService.setAppLockEnabled(true);
        if (mounted) {
          context.pop(true);
        }
      } else {
        setState(() {
          _error = true;
          _pin = '';
        });
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    final isValid = await AuthService.verifyPin(_pin);
    if (mounted) {
      if (isValid) {
        if (widget.isVerificationMode) {
          context.pop(true);
        } else {
          context.go('/home');
        }
      } else {
        setState(() {
          _error = true;
          _pin = '';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Icon(
              widget.isSetupMode ? Icons.shield_rounded : Icons.lock_rounded,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              widget.isSetupMode
                  ? (_isConfirming ? 'Confirm PIN' : 'Set PIN')
                  : 'Enter PIN',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isSetupMode
                  ? (_isConfirming ? 'Re-enter your PIN' : 'Enter a 4-digit PIN for Trezo')
                  : 'Please unlock Trezo to continue',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _pin.length;
                
                BorderRadius borderRadius;
                if (!isFilled) {
                  borderRadius = BorderRadius.circular(8); // Default Circle
                } else {
                  switch (index) {
                    case 0:
                      borderRadius = BorderRadius.circular(8); // Circle
                      break;
                    case 1:
                      borderRadius = BorderRadius.circular(4); // Rounded Square
                      break;
                    case 2:
                      borderRadius = BorderRadius.circular(4); // Diamond (will be rotated)
                      break;
                    case 3:
                    default:
                      borderRadius = const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        topRight: Radius.circular(2),
                        bottomLeft: Radius.circular(2),
                      ); // Leaf shape
                  }
                }

                Widget dot = AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    color: isFilled
                        ? (_error ? Colors.redAccent : Colors.white)
                        : Colors.white.withValues(alpha: 0.1),
                    border: isFilled && !_error
                        ? null
                        : Border.all(
                            color: _error ? Colors.redAccent : Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                  ),
                );

                if (isFilled && index == 2) {
                  // Make it a diamond by rotating 45 degrees
                  dot = Transform.rotate(angle: 3.14159 / 4, child: dot);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: dot,
                );
              }),
            ),
            const SizedBox(height: 16),
            if (_error)
              Text(
                widget.isSetupMode ? 'PINs do not match' : 'Incorrect PIN',
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              )
            else
              const SizedBox(height: 20), // Placeholder to maintain height
            const Spacer(flex: 2),
            // Numpad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16), // Increased slightly
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildNumKey((i * 3 + 1).toString()),
                          const SizedBox(width: 16), // Increased from 12
                          _buildNumKey((i * 3 + 2).toString()),
                          const SizedBox(width: 16),
                          _buildNumKey((i * 3 + 3).toString()),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _biometricsAvailable && !widget.isSetupMode
                          ? _buildIconButton(Icons.fingerprint_rounded, _attemptBiometrics)
                          : const SizedBox(width: 90, height: 90), // Matched new width
                      const SizedBox(width: 16),
                      _buildNumKey('0'),
                      const SizedBox(width: 16),
                      _buildIconButton(Icons.backspace_rounded, _onBackspace),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumKey(String number) {
    return _AnimatedKey(
      onTap: _isLoading ? null : () => _onKeyPress(number),
      hasBackground: true,
      text: number,
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return _AnimatedKey(
      onTap: _isLoading ? null : onTap,
      hasBackground: false,
      icon: icon,
    );
  }
}

class _AnimatedKey extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool hasBackground;

  const _AnimatedKey({
    this.text,
    this.icon,
    this.onTap,
    this.hasBackground = true,
  });

  @override
  State<_AnimatedKey> createState() => _AnimatedKeyState();
}

class _AnimatedKeyState extends State<_AnimatedKey> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = false);
          widget.onTap!();
        }
      },
      onTapCancel: () {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 90,
        height: 90,
        decoration: ShapeDecoration(
          color: widget.hasBackground 
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.transparent,
          shape: SmoothRectangleBorder(
            side: widget.hasBackground
                ? BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)
                : BorderSide.none,
            borderRadius: SmoothBorderRadius(
              cornerRadius: _isPressed ? 23 : 50,
              cornerSmoothing: 1,
            ),
          ),
        ),
        child: Center(
          child: widget.text != null
              ? AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _isPressed ? 26 : 32,
                    fontWeight: FontWeight.w600,
                  ),
                  child: Text(widget.text!),
                )
              : Icon(
                  widget.icon,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: _isPressed ? 24 : 28,
                ),
        ),
      ),
    );
  }
}
