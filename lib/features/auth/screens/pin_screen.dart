import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';

/// PIN Screen for app lock
class PinScreen extends ConsumerStatefulWidget {
  final bool isSetup;

  const PinScreen({super.key, this.isSetup = false});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  final List<String> _pin = [];
  final int _pinLength = 4;
  String? _firstPin;
  bool _isConfirming = false;
  bool _hasError = false;
  String _errorMessage = '';
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    if (!widget.isSetup) {
      _checkBiometric();
    }
  }

  Future<void> _checkBiometric() async {
    final settings = ref.read(settingsProvider);
    if (settings.biometricEnabled) {
      await _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        final didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Authenticate to access Spendora',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (didAuthenticate && mounted) {
          _navigateToHome();
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication error: $e');
    }
  }

  void _onKeyTap(String key) {
    if (_pin.length < _pinLength) {
      HapticFeedback.lightImpact();
      setState(() {
        _pin.add(key);
        _hasError = false;
      });

      if (_pin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _pin.removeLast();
        _hasError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final enteredPin = _pin.join();

    if (widget.isSetup) {
      // Setup mode
      if (_firstPin == null) {
        // First entry
        setState(() {
          _firstPin = enteredPin;
          _pin.clear();
          _isConfirming = true;
        });
      } else {
        // Confirming PIN
        if (_firstPin == enteredPin) {
          // PINs match - save and enable
          await ref.read(settingsProvider.notifier).setPinEnabled(
                true,
                pinCode: enteredPin,
              );
          if (mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PIN set successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // PINs don't match
          setState(() {
            _hasError = true;
            _errorMessage = 'PINs do not match. Try again.';
            _pin.clear();
            _firstPin = null;
            _isConfirming = false;
          });
          _shakeAnimation();
        }
      }
    } else {
      // Verification mode
      final settings = ref.read(settingsProvider);
      if (settings.verifyPin(enteredPin)) {
        _navigateToHome();
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Incorrect PIN';
          _pin.clear();
        });
        _shakeAnimation();
      }
    }
  }

  void _shakeAnimation() {
    HapticFeedback.heavyImpact();
  }

  void _navigateToHome() {
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Lock icon
            Icon(
              widget.isSetup ? Icons.lock_outline : Icons.lock_rounded,
              size: 64,
              color: context.colorScheme.primary,
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 24),

            // Title
            Text(
              widget.isSetup
                  ? (_isConfirming ? 'Confirm Your PIN' : 'Create a PIN')
                  : 'Enter Your PIN',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              widget.isSetup
                  ? (_isConfirming
                      ? 'Enter your PIN again to confirm'
                      : 'Choose a 4-digit PIN to secure your app')
                  : 'Enter your PIN to unlock',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                final isFilled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hasError
                        ? AppTheme.error
                        : (isFilled
                            ? context.colorScheme.primary
                            : Colors.transparent),
                    border: Border.all(
                      color: _hasError
                          ? AppTheme.error
                          : context.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ).animate(target: isFilled ? 1 : 0).scale(
                    begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
              }),
            ),

            // Error message
            if (_hasError) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.error,
                ),
              ).animate().shakeX(duration: 400.ms, hz: 4, amount: 8).fadeIn(),
            ],

            const Spacer(flex: 1),

            // Keypad
            _buildKeypad(),

            const Spacer(flex: 1),

            // Biometric button (if not setup and biometric is available)
            if (!widget.isSetup) ...[
              TextButton.icon(
                onPressed: _authenticateWithBiometric,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Use Biometric'),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3'].map((key) => _buildKey(key)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['4', '5', '6'].map((key) => _buildKey(key)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['7', '8', '9'].map((key) => _buildKey(key)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Empty space or biometric
              const SizedBox(width: 72, height: 72),
              _buildKey('0'),
              _buildBackspaceKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    return InkWell(
      onTap: () => _onKeyTap(key),
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colorScheme.surface,
          border: Border.all(
            color: context.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Text(
            key,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return InkWell(
      onTap: _onBackspace,
      borderRadius: BorderRadius.circular(36),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: context.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
