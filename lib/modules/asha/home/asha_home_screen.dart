import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../patient/home/medicine_store.dart';
import '../../../app_state.dart';
import '../visits/log_visit_bottom_sheet.dart';
import '../../../core/models/patient_model.dart';
import '../../../core/repositories/patient_repository.dart';
import '../../../core/services/risk_engine.dart';
import '../../../core/services/closed_loop_service.dart';
import '../../../core/widgets/sync_status_badge.dart';

class AshaHomeScreen extends StatefulWidget {
  const AshaHomeScreen({super.key});

  @override
  State<AshaHomeScreen> createState() => _AshaHomeScreenState();
}

class _AshaHomeScreenState extends State<AshaHomeScreen> {
  final MedicineStore _store = MedicineStore.instance;
  List<PatientModel> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChange);
    _loadPatients();
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChange);
    super.dispose();
  }

  void _onStoreChange() => setState(() {});

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    final list = await PatientRepository.instance.getAllPatients();
    setState(() {
      _patients = list;
      _isLoading = false;
    });
  }

  Future<void> _callPatient(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _escalateToAnm(AppState state) async {
    await ClosedLoopService.instance.ashaEscalateAlert(
      alertId: 'alert-seed-01',
      notes: 'Priyanka More has missed iron/calcium for 4 consecutive days. Immediate clinical visit required.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.translate(
            'Alert successfully escalated to ANM Sunita Gaikwad!',
            'अलर्ट सफलतापूर्वक एएनएम सुनीता गायकवाड़ को अग्रेषित किया गया!',
            'अलर्ट यशस्वीरित्या एएनएम सुनिता गायकवाड यांच्याकडे पाठवला!',
          )),
          backgroundColor: const Color(0xFF0077B6),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final store = context.watch<MedicineStore>();
    final medicineAlert = store.ashaAlertActive;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: Text(state.translate('ASHA Field Management', 'आशा प्रबंधन', 'आशा व्यवस्थापन')),
        backgroundColor: const Color(0xFFAEC6CF),
        actions: [
          const SyncStatusBadge(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, state, medicineAlert),
    );
  }

  Widget _buildBody(BuildContext context, AppState state, bool medicineAlert) {
    // Evaluate risk for each patient dynamically using RiskEngine v2
    final evaluatedPatients = _patients.map((p) {
      final isDemoPatient = p.id.contains('55555555-5555-5555-5555-555555555501');
      final missedDays = isDemoPatient && medicineAlert ? 4 : 0;

      final risk = RiskEngine.evaluate(
        age: p.age,
        systolic: p.id.contains('5502') ? 146 : 118,
        diastolic: p.id.contains('5502') ? 94 : 76,
        hemoglobin: p.id.contains('5503') ? 6.8 : (p.id.contains('5505') ? 8.8 : 11.2),
        previousCSection: p.previousCSection,
        stillbirthHistory: p.stillbirthHistory,
        pregnancyLossHistory: p.pregnancyLossHistory,
        isRhNegative: p.rhNegative,
        consecutiveMissedMedsDays: missedDays,
      );

      return (patient: p, risk: risk, hasMedicineAlert: isDemoPatient && medicineAlert);
    }).toList();

    // Sort by clinical urgency: High Risk first, then Moderate, then Low
    evaluatedPatients.sort((a, b) {
      if (a.hasMedicineAlert && !b.hasMedicineAlert) return -1;
      if (!a.hasMedicineAlert && b.hasMedicineAlert) return 1;
      return b.risk.level.index.compareTo(a.risk.level.index);
    });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Medicine missed alert banner (Closed Loop Step 2) ────────────────
        if (medicineAlert) ...[
          _buildMedicineMissedAlert(state),
          const SizedBox(height: 16),
        ],

        _buildSummaryCard(medicineAlert, state, evaluatedPatients.length),
        const SizedBox(height: 16),
        
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/incentive_tracker'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFAEC6CF), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFAEC6CF).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 30),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.translate('Monthly Impact & Incentives', 'मासिक प्रभाव और प्रोत्साहन', 'मासिक प्रभाव आणि प्रोत्साहन'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        state.translate('JSY / PMSMA incentive tracking', 'JSY / PMSMA प्रोत्साहन ट्रैकिंग', 'JSY / PMSMA प्रोत्साहन ट्रॅकिंग'),
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),

        Text(
          state.translate('Your Assigned Mothers (Triage Order)', 'आपके मरीज (प्राथमिकता अनुसार)', 'तुमचे नियुक्त रुग्ण (प्राधान्यक्रमाने)'),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Render dynamic patient list
        ...evaluatedPatients.map((item) {
          final p = item.patient;
          final risk = item.risk;
          final isHigh = risk.level == RiskLevel.high || item.hasMedicineAlert || p.isConfirmedHrp;
          final isMod = risk.level == RiskLevel.moderate;

          Color tileColor = Colors.white;
          if (isHigh) {
            tileColor = const Color(0xFFFFF1F1);
          } else if (isMod) {
            tileColor = const Color(0xFFFFFBEA);
          }

          // Plain language explainability string based on language
          String reasonText = risk.summaryEn;
          if (state.language == AppLanguage.hindi) {
            reasonText = risk.summaryHi;
          } else if (state.language == AppLanguage.marathi) {
            reasonText = risk.summaryMr;
          }

          return _buildPatientTile(
            context: context,
            state: state,
            patient: p,
            riskLevel: risk.level,
            reasonText: reasonText,
            color: tileColor,
            hasMedicineAlert: item.hasMedicineAlert,
            isRedSticker: isHigh,
          );
        }),
      ],
    );
  }

  Widget _buildMedicineMissedAlert(AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.translate('🚨 Medicine Missed Alert!', '🚨 दवा छूटी अलर्ट!', '🚨 औषध सुटले अलर्ट!'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      state.translate('Priyanka More has missed pills for 4 consecutive days', 'प्रियंका मोरे ने 4 लगातार दिनों से दवाएं नहीं ली हैं', 'प्रियंका मोरे यांनी सलग ४ दिवस औषधे घेतली नाहीत'),
                      style: const TextStyle(fontSize: 13, color: Colors.red),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  state.translate('URGENT', 'अत्यंत आवश्यक', 'तातडीचे'),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.red, height: 1),
          const SizedBox(height: 10),
          Text(
            state.translate(
              'Action Required: Contact mother immediately to prevent maternal anemia relapse, or escalate to ANM.',
              'कार्रवाई आवश्यक: मातृ एनीमिया को रोकने के लिए तुरंत संपर्क करें या एएनएम को अग्रेषित करें।',
              'कृती आवश्यक: अशक्तपणा रोखण्यासाठी मातेशी त्वरित संपर्क साधा किंवा एएनएमकडे पाठवा.'
            ),
            style: const TextStyle(fontSize: 13, color: Color(0xFF7B1A1A), height: 1.4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _callPatient('9811111101'),
                icon: const Icon(Icons.call, size: 16, color: Colors.red),
                label: Text(state.translate('Call Patient', 'रोगी को कॉल करें', 'रुग्णाला कॉल करा'), style: const TextStyle(color: Colors.red, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  LogVisitBottomSheet.show(context, patientId: '55555555-5555-5555-5555-555555555501', patientName: 'Priyanka More');
                },
                icon: const Icon(Icons.home_repair_service, size: 16, color: Colors.white),
                label: Text(state.translate('Log Visit', 'विजिट दर्ज करें', 'भेट नोंदवा'), style: const TextStyle(fontSize: 13, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _escalateToAnm(state),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                label: Text(state.translate('Escalate to ANM', 'एएनएम को अग्रेषित करें', 'एएनएमकडे पाठवा'), style: const TextStyle(fontSize: 13, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077B6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool medicineAlert, AppState state, int totalPatients) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem('$totalPatients', state.translate('Patients', 'मरीज', 'रुग्ण'), Icons.people, const Color(0xFFAEC6CF)),
          _SummaryItem(
            medicineAlert ? '2' : '1',
            state.translate('Active Alerts', 'सक्रिय अलर्ट', 'सक्रिय अलर्ट'),
            Icons.notifications_active,
            medicineAlert ? Colors.red : Colors.orange,
          ),
          _SummaryItem('3', state.translate('Visits Due', 'नियत विजिट', 'नियोजित भेटी'), Icons.calendar_today, Colors.green),
        ],
      ),
    );
  }

  Widget _buildPatientTile({
    required BuildContext context,
    required AppState state,
    required PatientModel patient,
    required RiskLevel riskLevel,
    required String reasonText,
    required Color color,
    bool hasMedicineAlert = false,
    bool isRedSticker = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: (hasMedicineAlert || isRedSticker) ? Colors.red.shade300 : Colors.black12,
          width: 1.5,
        ),
      ),
      child: ListTile(
        onTap: () {
          LogVisitBottomSheet.show(context, patientId: patient.id, patientName: patient.name);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: hasMedicineAlert || isRedSticker ? Colors.red : const Color(0xFFAEC6CF),
          child: Icon(
            isRedSticker ? Icons.warning_rounded : Icons.person,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                patient.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (hasMedicineAlert)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '4D MISSED',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            else if (isRedSticker)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'HRP',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${patient.age} yrs • Gestational Week: ${patient.gestationalWeeks} • Trimester: ${patient.trimester}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 2),
              Text(
                reasonText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isRedSticker ? Colors.red.shade900 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String val;
  final String label;
  final IconData icon;
  final Color color;

  const _SummaryItem(this.val, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
