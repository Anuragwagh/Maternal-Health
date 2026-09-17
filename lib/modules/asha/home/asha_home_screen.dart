import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../patient/home/medicine_store.dart';
import '../../../app_state.dart';
import '../visits/log_visit_bottom_sheet.dart';
import '../../../core/models/patient_risk_profile.dart';

class AshaHomeScreen extends StatefulWidget {
  const AshaHomeScreen({super.key});

  @override
  State<AshaHomeScreen> createState() => _AshaHomeScreenState();
}

class _AshaHomeScreenState extends State<AshaHomeScreen> {
  final MedicineStore _store = MedicineStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChange);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChange);
    super.dispose();
  }

  void _onStoreChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final store = context.watch<MedicineStore>();
    final medicineAlert = store.ashaAlertActive;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: Text(state.translate('ASHA Management', 'आशा प्रबंधन', 'आशा व्यवस्थापन')),
        backgroundColor: const Color(0xFFAEC6CF),
      ),
        body: _buildBody(context, state, medicineAlert),
      );
    }
  
    Widget _buildBody(BuildContext context, AppState state, bool medicineAlert) {
      // Dynamic list of patients
      final profiles = [
        if (medicineAlert)
          const PatientRiskProfile(
            patientId: 'Me',
            age: 26,
            systolicBpHistory: [120],
            diastolicBpHistory: [80],
            hemoglobinLevel: 11.5,
            hasPreviousComplications: false,
            missedMedications3PlusDays: true,
          ),
        const PatientRiskProfile(
            patientId: 'Sita Devi',
            age: 17,
            systolicBpHistory: [145],
            diastolicBpHistory: [95],
            hemoglobinLevel: 10.5,
            hasPreviousComplications: false,
            missedMedications3PlusDays: false,
        ),
        const PatientRiskProfile(
            patientId: 'Meena Rao',
            age: 28,
            systolicBpHistory: [110],
            diastolicBpHistory: [70],
            hemoglobinLevel: 8.5,
            hasPreviousComplications: false,
            missedMedications3PlusDays: false,
        ),
        const PatientRiskProfile(
            patientId: 'Pooja Singh',
            age: 25,
            systolicBpHistory: [115],
            diastolicBpHistory: [75],
            hemoglobinLevel: 12.0,
            hasPreviousComplications: false,
            missedMedications3PlusDays: false,
        ),
      ];
  
      // Sort patients by priority
      profiles.sort((a, b) => a.triagePriority.compareTo(b.triagePriority));

      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Medicine missed alert banner ────────────────────────────────────
          if (medicineAlert) ...[
            _buildMedicineMissedAlert(state),
            const SizedBox(height: 16),
          ],
  
          _buildSummaryCard(medicineAlert, state),
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
                          state.translate('Tap to view progress', 'प्रगति देखने के लिए टैप करें', 'प्रगती पाहण्यासाठी टॅप करा'),
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
            state.translate('Your Patients', 'आपके मरीज', 'तुमचे रुग्ण'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
  
          // Render sorted patient list
          ...profiles.map((p) {
            Color color;
            if (p.missedMedications3PlusDays || p.isHighRiskPregnancy) {
              color = Colors.red.shade50;
            } else if (p.hasModerateAnemia) {
              color = Colors.orange.shade50;
            } else {
              color = Colors.green.shade50;
            }
            
            return _buildPatientTile(
              context,
              p.patientId == 'Me' ? state.translate('Patient (You)', 'मरीज (आप)', 'रुग्ण (तुम्ही)') : p.patientId,
              state.translate('Current', 'वर्तमान', 'चालू'),
              p.primaryRiskLabel,
              color,
              hasMedicineAlert: p.missedMedications3PlusDays,
              isRedSticker: p.isHighRiskPregnancy,
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
                      state.translate('🚨 Medicine Alert!', '🚨 दवा अलर्ट!', '🚨 औषध अलर्ट!'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      state.translate('Patient has missed medicines for 3+ days', 'मरीज ने 3+ दिनों से दवाएं नहीं ली हैं', 'रुग्णाने ३+ दिवस औषधे घेतली नाहीत'),
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
              'Action Required: Please contact the patient immediately and check whether they have been taking their prescribed medicines (Calcium, Iron, Folic Acid).',
              'कार्रवाई आवश्यक: कृपया रोगी से तुरंत संपर्क करें और जांचें कि क्या वे अपनी निर्धारित दवाएं (कैल्शियम, आयरन, फोलिक एसिड) ले रहे हैं।',
              'कृती आवश्यक: कृपया रुग्णाशी त्वरित संपर्क साधा आणि ते त्यांची विहित औषधे (कॅल्शियम, लोह, फोलिक ऍसिड) घेत आहेत का ते तपासा.'
            ),
            style: const TextStyle(fontSize: 13, color: Color(0xFF7B1A1A), height: 1.5),
          ),
          const SizedBox(height: 10),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 16, color: Colors.red),
                  label: Text(state.translate('Call Patient', 'रोगी को कॉल करें', 'रुग्णाला कॉल करा'), style: const TextStyle(color: Colors.red, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.home_repair_service, size: 16, color: Colors.white),
                  label: Text(state.translate('Schedule Visit', 'विजिट तय करें', 'भेट ठरवा'), style: const TextStyle(fontSize: 13, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool medicineAlert, AppState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem('12', state.translate('Patients', 'मरीज', 'रुग्ण'), Icons.people, const Color(0xFFAEC6CF)),
          _SummaryItem(
            medicineAlert ? '4' : '3',
            state.translate('Alerts', 'अलर्ट', 'सूचना'),
            Icons.notifications_active,
            medicineAlert ? Colors.red : Colors.orange,
          ),
          _SummaryItem('5', state.translate('Visits Today', 'आज की विजिट', 'आजच्या भेटी'), Icons.calendar_today, Colors.green),
        ],
      ),
    );
  }

  Widget _buildPatientTile(
    BuildContext context,
    String name,
    String month,
    String status,
    Color color, {
    bool hasMedicineAlert = false,
    bool isRedSticker = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: (hasMedicineAlert || isRedSticker) ? Colors.red.shade200 : Colors.transparent, width: 1.5),
      ),
      child: ListTile(
        onTap: () {
          LogVisitBottomSheet.show(context, name);
        },
        contentPadding: const EdgeInsets.all(16),
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
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (hasMedicineAlert) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '! ALERT',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text('$month – $status'),
        trailing: const Icon(Icons.chevron_right),
        tileColor: color,
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
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
