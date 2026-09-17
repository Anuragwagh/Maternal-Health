import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_state.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreedToTerms = false;
  bool _agreedToDataSharing = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/language'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Icon(
                  Icons.shield_outlined,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                state.translate('Data Privacy & Consent', 'डेटा गोपनीयता और सहमति', 'डेटा गोपनीयता आणि संमती'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                state.translate(
                  'Your health data is protected under the ABDM/DISHA guidelines. We need your consent to securely store and share this data with your designated ASHA worker and PHC supervisor to provide better care.',
                  'आपका स्वास्थ्य डेटा ABDM/DISHA दिशानिर्देशों के तहत सुरक्षित है। बेहतर देखभाल प्रदान करने के लिए हमें आपके निर्दिष्ट आशा कार्यकर्ता और PHC पर्यवेक्षक के साथ इस डेटा को सुरक्षित रूप से संग्रहीत और साझा करने के लिए आपकी सहमति की आवश्यकता है।',
                  'तुमचा आरोग्य डेटा ABDM/DISHA मार्गदर्शक तत्त्वांनुसार सुरक्षित आहे. उत्तम काळजी प्रदान करण्यासाठी आम्हाला तुमचा डेटा तुमच्या नियुक्त आशा कार्यकर्त्या आणि PHC पर्यवेक्षकासोबत सुरक्षितपणे संग्रहित आणि शेअर करण्यासाठी तुमच्या संमतीची आवश्यकता आहे.'
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 32),
              
              // Checkbox 1
              _buildCheckboxTile(
                value: _agreedToTerms,
                onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                text: state.translate(
                  'I agree to the Terms of Service and Privacy Policy.',
                  'मैं सेवा की शर्तों और गोपनीयता नीति से सहमत हूँ।',
                  'मी सेवा अटी आणि गोपनीयता धोरणाशी सहमत आहे.'
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Checkbox 2
              _buildCheckboxTile(
                value: _agreedToDataSharing,
                onChanged: (val) => setState(() => _agreedToDataSharing = val ?? false),
                text: state.translate(
                  'I consent to share my health records with my ASHA worker and local health clinic.',
                  'मैं अपने स्वास्थ्य रिकॉर्ड को अपनी आशा कार्यकर्ता और स्थानीय स्वास्थ्य क्लिनिक के साथ साझा करने की सहमति देता हूँ।',
                  'मी माझे आरोग्य रेकॉर्ड माझ्या आशा कार्यकर्त्या आणि स्थानिक आरोग्य क्लिनिकसोबत शेअर करण्यास संमती देतो.'
                ),
              ),
              
              const Spacer(),
              ElevatedButton(
                onPressed: (_agreedToTerms && _agreedToDataSharing)
                    ? () {
                        // Store consent logic would go here
                        Navigator.pushReplacementNamed(context, '/selection');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_agreedToTerms && _agreedToDataSharing)
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  state.translate('I Accept', 'मैं स्वीकार करता हूँ', 'मी स्वीकारतो'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({required bool value, required ValueChanged<bool?> onChanged, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
