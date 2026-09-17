import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_state.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      appBar: AppBar(
        title: Text(state.translate('Caregiver Dashboard', 'देखभालकर्ता डैशबोर्ड', 'काळजी घेणारा डॅशबोर्ड')),
        backgroundColor: const Color(0xFFFFD700),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              const Icon(Icons.family_restroom, size: 40, color: Color(0xFFFFD700)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  state.translate('Supporting Mother', 'माता का समर्थन', 'मातेचे समर्थन'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          _buildInfoCard(
            context,
            state.translate('Next Checkup', 'अगली जांच', 'पुढील तपासणी'),
            state.translate('9th of this Month', 'इस महीने की 9 तारीख', 'या महिन्याची 9 तारीख'),
            Icons.calendar_month,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          
          _buildInfoCard(
            context,
            state.translate('Medicine Adherence', 'दवा का पालन', 'औषध पालन'),
            state.translate('All taken this week', 'इस सप्ताह सभी ली गईं', 'या आठवड्यात सर्व घेतल्या'),
            Icons.medication,
            Colors.green,
          ),
          const SizedBox(height: 16),
          
          _buildInfoCard(
            context,
            state.translate('Emergency Contact', 'आपातकालीन संपर्क', 'तातडीचा संपर्क'),
            'ASHA: 9876543210',
            Icons.call,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
