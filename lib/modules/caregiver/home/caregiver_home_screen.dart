import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_state.dart';
import '../../../core/database/local_db.dart';
import '../../patient/home/medicine_store.dart';
import '../../../core/widgets/sync_status_badge.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final store = context.watch<MedicineStore>();
    final hasConsent = LocalDb.prefsBox.get('caregiver_consent', defaultValue: true) as bool;
    final missedDays = store.consecutiveMissedDaysBefore(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      appBar: AppBar(
        title: Text(state.translate('Caregiver Dashboard', 'देखभालकर्ता डैशबोर्ड', 'काळजी घेणारा डॅशबोर्ड')),
        backgroundColor: const Color(0xFFFFD700),
        actions: const [
          SyncStatusBadge(),
        ],
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
                  state.translate('Supporting Priyanka More', 'प्रियंका मोरे का समर्थन', 'प्रियंका मोरे यांना समर्थन'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          if (!hasConsent) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.translate(
                        'Mother has currently paused data sharing. Only emergency contacts are accessible.',
                        'माता ने डेटा साझाकरण रोका है। केवल आपातकालीन संपर्क उपलब्ध हैं।',
                        'मातेने डेटा शेअरिंग थांबवले आहे. फक्त आपत्कालीन संपर्क उपलब्ध आहेत.'
                      ),
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            _buildInfoCard(
              context,
              state.translate('Next Clinic Checkup', 'अगली क्लिनिक जांच', 'पुढील क्लिनिक तपासणी'),
              state.translate('9th of this Month (PMSMA Day)', 'महीने की 9 तारीख (PMSMA दिन)', 'महिन्याची ९ तारीख (PMSMA दिवस)'),
              Icons.calendar_month,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            
            _buildInfoCard(
              context,
              state.translate('Medicine Adherence (Past 7 Days)', 'दवा का पालन (पिछले 7 दिन)', 'औषध पालन (मागील ७ दिवस)'),
              missedDays >= 3
                  ? state.translate('⚠️ Mother has missed doses recently ($missedDays days missed)', '⚠️ हाल ही में खुराक छूटी है ($missedDays दिन छूटे)', '⚠️ मातेने औषधे चुकवली आहेत ($missedDays दिवस चुकले)')
                  : state.translate('✅ Daily doses taken regularly', '✅ दैनिक दवाएं नियमित रूप से ली गईं', '✅ नियमितपणे औषधे घेतली आहेत'),
              Icons.medication,
              missedDays >= 3 ? Colors.orange : Colors.green,
            ),
            const SizedBox(height: 16),
          ],
          
          _buildInfoCard(
            context,
            state.translate('Assigned ASHA Worker Contact', 'निर्धारित आशा कार्यकर्ता संपर्क', 'नियुक्त आशा कार्यकर्ता संपर्क'),
            'Savita Tai: +91 9800000021',
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
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
