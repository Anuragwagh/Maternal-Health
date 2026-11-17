import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_state.dart';
import '../../../core/models/patient_model.dart';
import '../../../core/repositories/patient_repository.dart';
import '../../../core/services/closed_loop_service.dart';
import '../../../core/widgets/sync_status_badge.dart';

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  State<SupervisorDashboardScreen> createState() => _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen> {
  List<PatientModel> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
    ClosedLoopService.instance.addListener(_onLoopChanged);
  }

  @override
  void dispose() {
    ClosedLoopService.instance.removeListener(_onLoopChanged);
    super.dispose();
  }

  void _onLoopChanged() {
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final list = await PatientRepository.instance.getAllPatients();
    setState(() {
      _patients = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final confirmedHrpCount = _patients.where((p) => p.isConfirmedHrp).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: Text(state.translate('PHC Supervisor Dashboard', 'PHC पर्यवेक्षक डैशबोर्ड', 'PHC पर्यवेक्षक डॅशबोर्ड')),
        backgroundColor: const Color(0xFF98FB98),
        actions: [
          const SyncStatusBadge(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildMetricCard(
                  context,
                  state.translate('Active Pregnancies in PHC', 'सक्रिय गर्भावस्था', 'सक्रिय गर्भधारणा'),
                  '${_patients.length + 28}', // Combined demo total
                  Icons.pregnant_woman,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildMetricCard(
                  context,
                  state.translate('System Adherence', 'प्रणाली पालन', 'प्रणाली पालन'),
                  '89%',
                  Icons.medication,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildMetricCard(
                  context,
                  state.translate('Confirmed HRPs (Live ANM Count)', 'कुल HRP चिह्नित (लाइव)', 'एकूण HRP चिन्हांकित (थेट)'),
                  '$confirmedHrpCount',
                  Icons.warning_rounded,
                  Colors.red,
                ),
                const SizedBox(height: 32),
                Text(
                  state.translate('Top Performing ASHAs (Visits Completed)', 'शीर्ष प्रदर्शन करने वाली आशा', 'सर्वोत्कृष्ट कामगिरी करणाऱ्या आशा'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildAshaListTile('Savita Tai (Trimbakeshwar)', '48 Visits Completed • 94% Adherence', Colors.orange),
                _buildAshaListTile('Mangala Kadam (Velunje)', '42 Visits Completed • 91% Adherence', Colors.blue),
                _buildAshaListTile('Pushpa Pawar (Anjaneri)', '39 Visits Completed • 88% Adherence', Colors.green),
                _buildAshaListTile('Usha Jadhav (Pahine)', '35 Visits Completed • 86% Adherence', Colors.purple),
                
                const SizedBox(height: 24),
                Text(
                  state.translate('Confirmed High-Risk Roster', 'पुष्ट उच्च-जोखिम सूची', 'निश्चित हाय-रिस्क यादी'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._patients.where((p) => p.isConfirmedHrp).map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 18,
                      child: Icon(Icons.shield, color: Colors.white, size: 18),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${p.hrpCategory ?? "High Risk"} • ${p.age} yrs'),
                    trailing: const Chip(
                      label: Text('ANM Confirmed', style: TextStyle(color: Colors.red, fontSize: 11)),
                      backgroundColor: Color(0xFFFFEBEE),
                    ),
                  ),
                )),
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
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
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
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarColor.withValues(alpha: 0.2),
          child: Icon(Icons.person, color: avatarColor),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.verified, color: Colors.green, size: 20),
      ),
    );
  }
}
