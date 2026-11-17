import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_state.dart';
import '../../../core/models/alert_model.dart';
import '../../../core/models/patient_model.dart';
import '../../../core/repositories/alert_repository.dart';
import '../../../core/repositories/patient_repository.dart';
import '../../../core/repositories/visit_repository.dart';
import '../../../core/services/closed_loop_service.dart';
import '../../../core/widgets/sync_status_badge.dart';

class AnmHomeScreen extends StatefulWidget {
  const AnmHomeScreen({super.key});

  @override
  State<AnmHomeScreen> createState() => _AnmHomeScreenState();
}

class _AnmHomeScreenState extends State<AnmHomeScreen> {
  List<AlertModel> _alerts = [];
  List<PatientModel> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final alerts = await AlertRepository.instance.getAlertsForAsha('');
    final patients = await PatientRepository.instance.getAllPatients();
    setState(() {
      _alerts = alerts;
      _patients = patients;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(state.translate('ANM Clinical Inbox', 'एएनएम नैदानिक इनबॉक्स', 'एएनएम क्लिनिकल इनबॉक्स')),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
        actions: [
          const SyncStatusBadge(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(state),
                const SizedBox(height: 20),
                _buildMetricsRow(state),
                const SizedBox(height: 24),
                Text(
                  state.translate('Escalated Alerts (Action Required)', 'अग्रेषित अलर्ट (कार्रवाई आवश्यक)', 'फॉरवर्ड केलेले अलर्ट्स (कृती आवश्यक)'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 12),
                if (_alerts.isEmpty)
                  _buildEmptyState(state)
                else
                  ..._alerts.map((alert) => _buildEscalationCard(alert, state)),
                const SizedBox(height: 24),
                Text(
                  state.translate('Confirmed High-Risk Mothers', 'पुष्टि की गई उच्च जोखिम वाली माताएं', 'निश्चित केलेल्या हाय-रिस्क माता'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 12),
                ..._patients.where((p) => p.isConfirmedHrp).map((p) => _buildHrpCard(p, state)),
              ],
            ),
    );
  }

  Widget _buildHeader(AppState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF0077B6).withValues(alpha: 0.15),
            child: const Icon(Icons.medical_services_rounded, color: Color(0xFF0077B6), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ANM Sunita Gaikwad',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  state.translate('Trimbakeshwar Sub-Centre • 4 ASHAs Assigned', 'त्र्यंबकेश्वर उप-केंद्र • 4 आशा कार्यकर्ता', 'त्र्यंबकेश्वर उप-केंद्र • 4 आशा नियुक्त'),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(AppState state) {
    final hrpCount = _patients.where((p) => p.isConfirmedHrp).length;
    final urgentAlerts = _alerts.where((a) => a.isUrgent && a.status != AlertStatus.closed).length;

    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: state.translate('Pending Actions', 'लंबित कार्रवाई', 'प्रलंबित कृती'),
            value: '$urgentAlerts',
            color: Colors.red.shade700,
            bgColor: Colors.red.shade50,
            icon: Icons.notifications_active_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            title: state.translate('Confirmed HRPs', 'पुष्ट HRP', 'निश्चित HRP'),
            value: '$hrpCount',
            color: const Color(0xFF0077B6),
            bgColor: const Color(0xFFE8F4F8),
            icon: Icons.shield_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const Spacer(),
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationCard(AlertModel alert, AppState state) {
    final isClosed = alert.status == AlertStatus.closed;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isClosed ? Colors.grey.shade300 : Colors.red.shade200, width: 1.5),
      ),
      color: isClosed ? Colors.grey.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isClosed ? Colors.grey : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alert.severity.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    alert.patientName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  alert.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isClosed ? Colors.grey : Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              alert.message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 14),
            if (!isClosed)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _handleConfirmHrp(alert),
                    icon: const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.white),
                    label: Text(state.translate('Confirm HRP', 'HRP की पुष्टि करें', 'HRP निश्चित करा')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      minimumSize: const Size(120, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _handleReferToPhc(alert),
                    icon: const Icon(Icons.local_hospital_outlined, size: 16, color: Color(0xFF0077B6)),
                    label: Text(state.translate('Refer to PHC', 'PHC को रेफर करें', 'PHC कडे पाठवा')),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(110, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _handleClearAlert(alert),
                    icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                    label: Text(state.translate('Clear', 'बंद करें', 'मिटवा')),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHrpCard(PatientModel p, AppState state) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.red.shade200),
      ),
      color: Colors.red.shade50.withValues(alpha: 0.6),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.priority_high_rounded, color: Colors.white),
        ),
        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${state.translate("Category", "श्रेणी", "प्रवर्ग")}: ${p.hrpCategory ?? "High Risk"} • ${state.translate("Age", "उम्र", "वय")}: ${p.age} yrs',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _showVitalsDialog(p);
        },
      ),
    );
  }

  Widget _buildEmptyState(AppState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          state.translate('No pending alerts in inbox.', 'इनबॉक्स में कोई लंबित अलर्ट नहीं है।', 'इनबॉक्समध्ये कोणतेही प्रलंबित अलर्ट नाहीत.'),
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Future<void> _handleConfirmHrp(AlertModel alert) async {
    await ClosedLoopService.instance.anmConfirmHrp(
      alertId: alert.id,
      patientId: alert.patientId,
      notes: 'High-risk condition confirmed from alert: ${alert.type}',
    );
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('HRP Confirmed & added to PHC Supervisor registry.')),
      );
    }
  }

  Future<void> _handleReferToPhc(AlertModel alert) async {
    await AlertRepository.instance.closeAlert(alert.id, 'Referred to PHC Medical Officer');
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mother referred to PHC Medical Officer for specialized review.')),
      );
    }
  }

  Future<void> _handleClearAlert(AlertModel alert) async {
    await AlertRepository.instance.closeAlert(alert.id, 'Cleared after in-person clinical assessment');
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alert marked as resolved.')),
      );
    }
  }

  void _showVitalsDialog(PatientModel patient) {
    final systolicCtrl = TextEditingController(text: '120');
    final diastolicCtrl = TextEditingController(text: '80');
    final hbCtrl = TextEditingController(text: '11.0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Record Clinical Vitals: ${patient.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: systolicCtrl,
              decoration: const InputDecoration(labelText: 'Systolic BP (mmHg)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: diastolicCtrl,
              decoration: const InputDecoration(labelText: 'Diastolic BP (mmHg)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: hbCtrl,
              decoration: const InputDecoration(labelText: 'Hemoglobin (g/dL)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await VisitRepository.instance.logVisit(
                patientId: patient.id,
                recordedBy: 'anm-sunita',
                recordedByRole: 'anm',
                visitDate: DateTime.now(),
                systolic: int.tryParse(systolicCtrl.text),
                diastolic: int.tryParse(diastolicCtrl.text),
                hemoglobin: double.tryParse(hbCtrl.text),
                notes: 'Official clinical reading recorded by ANM.',
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clinical visit and vitals logged successfully!')),
                );
              }
            },
            child: const Text('Save Vitals'),
          ),
        ],
      ),
    );
  }
}
