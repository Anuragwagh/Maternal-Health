import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_state.dart';

class SupervisorDashboardScreen extends StatelessWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: Text(state.translate('PHC Supervisor Dashboard', 'PHC पर्यवेक्षक डैशबोर्ड', 'PHC पर्यवेक्षक डॅशबोर्ड')),
        backgroundColor: const Color(0xFF98FB98),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildMetricCard(
            context,
            state.translate('Active Pregnancies', 'सक्रिय गर्भावस्था', 'सक्रिय गर्भधारणा'),
            '1,245',
            Icons.pregnant_woman,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            context,
            state.translate('System Adherence', 'प्रणाली पालन', 'प्रणाली पालन'),
            '87%',
            Icons.medication,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            context,
            state.translate('Total HRPs Flagged', 'कुल HRP चिह्नित', 'एकूण HRP चिन्हांकित'),
            '142',
            Icons.warning_rounded,
            Colors.red,
          ),
          const SizedBox(height: 32),
          Text(
            state.translate('Top Performing ASHAs', 'शीर्ष प्रदर्शन करने वाली आशा', 'सर्वोत्कृष्ट कामगिरी करणाऱ्या आशा'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildAshaListTile('Asha Worker 1', '45 Visits', Colors.orange),
          _buildAshaListTile('Asha Worker 2', '38 Visits', Colors.blue),
          _buildAshaListTile('Asha Worker 3', '32 Visits', Colors.green),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
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
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAshaListTile(String name, String subtitle, Color avatarColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarColor.withValues(alpha: 0.2),
          child: Icon(Icons.person, color: avatarColor),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
