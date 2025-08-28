import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool _isBiometricAvailable = false;
  bool _isLoading = true;
  bool _showPinEntry = false;
  List<String> _availableBiometrics = [];

  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isSettingUpPin = false;
  bool _isVerifyingPin = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _checkBiometricSupport();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final isAvailable = await AuthService.isBiometricAvailable();
      final biometrics = await AuthService.getAvailableBiometrics();
      final hasAuthSetup = await AuthService.hasAuthenticationSetup();
      final hasPin = await AuthService.hasFinancialPin();

      setState(() {
        _isBiometricAvailable = isAvailable;
        _availableBiometrics = biometrics.map((e) => e.toString()).toList();
        _isLoading = false;
        _showPinEntry = !hasAuthSetup && !isAvailable;
        _isSettingUpPin = !hasPin && !isAvailable;
      });

      if (hasAuthSetup && isAvailable) {
        _authenticateWithBiometrics();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showPinEntry = true;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final isAuthenticated = await AuthService.authenticateWithBiometrics(
        reason: 'Authenticate to access AI Finance Buddy',
      );

      if (isAuthenticated) {
        _navigateToMainApp();
      } else {
        setState(() {
          _showPinEntry = true;
          _isVerifyingPin = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Biometric authentication failed: $e');
      setState(() {
        _showPinEntry = true;
        _isVerifyingPin = true;
      });
    }
  }

  Future<void> _setupPin() async {
    if (_pinController.text.length < 4) {
      _showErrorSnackBar('PIN must be at least 4 digits');
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      _showErrorSnackBar('PINs do not match');
      return;
    }

    try {
      await AuthService.storeFinancialPin(_pinController.text);
      await AuthService.setAuthenticationSetup(true);
      _navigateToMainApp();
    } catch (e) {
      _showErrorSnackBar('Failed to setup PIN: $e');
    }
  }

  Future<void> _verifyPin() async {
    if (_pinController.text.isEmpty) {
      _showErrorSnackBar('Please enter your PIN');
      return;
    }

    try {
      final isValid = await AuthService.verifyFinancialPin(_pinController.text);
      if (isValid) {
        _navigateToMainApp();
      } else {
        _showErrorSnackBar('Invalid PIN. Please try again.');
        _pinController.clear();
      }
    } catch (e) {
      _showErrorSnackBar('PIN verification failed: $e');
    }
  }

  void _navigateToMainApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthenticatedApp()),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and App Name
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          size: 60,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'AI Finance Buddy',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Secure • Smart • Simple',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Authentication Options
                if (!_showPinEntry) ...[
                  _buildBiometricSection(),
                ] else ...[
                  _buildPinSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 24),
              Text(
                'Setting up secure access...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                _getBiometricIcon(),
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Secure Authentication',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Use ${_getBiometricName()} to securely access your financial data',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _authenticateWithBiometrics,
                  icon: Icon(_getBiometricIcon()),
                  label: Text('Authenticate with ${_getBiometricName()}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showPinEntry = true;
                    _isVerifyingPin = true;
                  });
                },
                child: const Text('Use PIN instead'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.pin, size: 60, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text(
            _isSettingUpPin ? 'Setup Security PIN' : 'Enter Your PIN',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _isSettingUpPin
                ? 'Create a secure PIN to protect your financial data'
                : 'Enter your PIN to access your account',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // PIN Input Field
          TextFormField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: _isSettingUpPin ? 'Create PIN' : 'Enter PIN',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '',
            ),
          ),

          if (_isSettingUpPin) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                counterText: '',
              ),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSettingUpPin ? _setupPin : _verifyPin,
              icon: Icon(_isSettingUpPin ? Icons.check : Icons.login),
              label: Text(_isSettingUpPin ? 'Setup PIN' : 'Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (_isBiometricAvailable && _isVerifyingPin) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showPinEntry = false;
                });
              },
              icon: Icon(_getBiometricIcon()),
              label: Text('Use ${_getBiometricName()} instead'),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains('fingerprint')) {
      return Icons.fingerprint;
    } else if (_availableBiometrics.contains('face')) {
      return Icons.face;
    } else if (_availableBiometrics.contains('iris')) {
      return Icons.visibility;
    }
    return Icons.security;
  }

  String _getBiometricName() {
    if (_availableBiometrics.contains('fingerprint')) {
      return 'Fingerprint';
    } else if (_availableBiometrics.contains('face')) {
      return 'Face ID';
    } else if (_availableBiometrics.contains('iris')) {
      return 'Iris';
    }
    return 'Biometric';
  }
}
