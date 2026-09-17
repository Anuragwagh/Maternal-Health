import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/database/local_db.dart';
import '../../../app_state.dart';

class AshaPinLoginScreen extends StatefulWidget {
  const AshaPinLoginScreen({super.key});

  @override
  State<AshaPinLoginScreen> createState() => _AshaPinLoginScreenState();
}

class _AshaPinLoginScreenState extends State<AshaPinLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _savedPin;
  bool _isSettingUp = false;

  @override
  void initState() {
    super.initState();
    _checkSavedPin();
  }

  void _checkSavedPin() {
    final pin = LocalDb.prefsBox.get('asha_pin') as String?;
    setState(() {
      if (pin != null && pin.isNotEmpty) {
        _savedPin = pin;
        _isSettingUp = false;
      } else {
        _isSettingUp = true;
      }
    });
  }

  void _submit() {
    final input = _pinController.text;
    if (input.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be 4 digits')),
      );
      return;
    }

    if (_isSettingUp) {
      LocalDb.prefsBox.put('asha_pin', input);
      Navigator.pushReplacementNamed(context, '/asha_home');
    } else {
      if (input == _savedPin) {
        Navigator.pushReplacementNamed(context, '/asha_home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(state.translate('ASHA Login (Offline)', 'आशा लॉग इन (ऑफ़लाइन)', 'आशा लॉगिन (ऑफलाइन)')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 24),
            Text(
              _isSettingUp 
                  ? state.translate('Set a 4-digit PIN for offline access', 'ऑफ़लाइन एक्सेस के लिए 4 अंकों का पिन सेट करें', 'ऑफलाइन प्रवेशासाठी ४ अंकी पिन सेट करा')
                  : state.translate('Enter your 4-digit PIN', 'अपना 4 अंकों का पिन दर्ज करें', 'तुमचा ४ अंकी पिन प्रविष्ट करा'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 12),
              decoration: const InputDecoration(
                counterText: '',
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submit,
              child: Text(
                _isSettingUp 
                    ? state.translate('Set PIN', 'पिन सेट करें', 'पिन सेट करा') 
                    : state.translate('Login', 'लॉग इन करें', 'लॉगिन करा')
              ),
            ),
          ],
        ),
      ),
    );
  }
}
