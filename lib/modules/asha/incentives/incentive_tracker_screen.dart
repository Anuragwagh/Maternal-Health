import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_state.dart';

class IncentiveTrackerScreen extends StatelessWidget {
  const IncentiveTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(state.translate('Incentive Tracker', 'प्रोत्साहन ट्रैकर', 'प्रोत्साहन ट्रॅकर')),
        backgroundColor: const Color(0xFFAEC6CF),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildImpactCard(context, state),
          const SizedBox(height: 24),
          Text(
            state.translate('Scheme Eligibility (JSY / PMSMA)', 'योजना पात्रता', 'योजना पात्रता'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSchemeProgress(
            context,
            state.translate('ANC Checkups', 'एएनसी जांच', 'एएनसी तपासणी'),
            '12 / 15',
            0.8,
            Colors.green,
          ),
          _buildSchemeProgress(
            context,
            state.translate('HRP Follow-ups', 'हाई रिस्क फॉलो-अप', 'हाय रिस्क फॉलो-अप'),
            '4 / 5',
            0.8,
            Colors.orange,
          ),
          _buildSchemeProgress(
            context,
            state.translate('Institutional Deliveries', 'संस्थागत प्रसव', 'संस्थात्मक प्रसूती'),
            '2 / 2',
            1.0,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFAEC6CF), const Color(0xFFAEC6CF).withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFAEC6CF).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.translate('Your Impact This Month', 'इस महीने आपका प्रभाव', 'या महिन्यात तुमचा प्रभाव'),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(context, '15', state.translate('Visits', 'विजिट', 'भेटी')),
              _buildStat(context, '3', state.translate('HRP Found', 'हाई रिस्क', 'हाय रिस्क')),
              _buildStat(context, '₹450', state.translate('Est. Bonus', 'अनुमानित बोनस', 'अंदाजित बोनस')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSchemeProgress(BuildContext context, String title, String progressText, double progress, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(progressText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
