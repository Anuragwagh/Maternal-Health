import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app_state.dart';

class SosBottomSheet extends StatelessWidget {
  const SosBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SosBottomSheet(),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.translate('Emergency Options', 'आपातकालीन विकल्प', 'तातडीचे पर्याय'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSosButton(
            context,
            state.translate('Call My ASHA', 'मेरी आशा को कॉल करें', 'माझ्या आशाला कॉल करा'),
            Icons.medical_services,
            Colors.orange,
            () => _makePhoneCall('9876543210'), // Mock ASHA Number
          ),
          const SizedBox(height: 16),
          
          _buildSosButton(
            context,
            state.translate('Call Ambulance (108)', 'एम्बुलेंस बुलाएं (108)', 'रुग्णवाहिका बोलवा (108)'),
            Icons.emergency,
            Colors.red,
            () => _makePhoneCall('108'),
          ),
          const SizedBox(height: 16),

          // Mock SMS Fallback
          ListTile(
            leading: const Icon(Icons.sms_failed, color: Colors.grey),
            title: Text(
              state.translate('No Network?', 'नेटवर्क नहीं है?', 'नेटवर्क नाही?'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              state.translate('Tap to send an offline SMS alert.', 'ऑफ़लाइन एसएमएस अलर्ट भेजने के लिए टैप करें।', 'ऑफलाइन एसएमएस अलर्ट पाठवण्यासाठी टॅप करा.'),
            ),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.translate('SMS Alert Queued. Will send when signal returns.', 'एसएमएस अलर्ट कतारबद्ध। सिग्नल आने पर भेजा जाएगा।', 'एसएमएस अलर्ट रांगेत आहे. सिग्नल आल्यावर पाठवले जाईल.')),
                  backgroundColor: Colors.blueGrey,
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSosButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
