import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'diet_plan_screen.dart';
import 'vaccine_screen.dart';
import 'medicine_screen.dart';
import 'patient_history_screen.dart';
import 'chatbot_widget.dart';
import 'nearest_clinic_screen.dart';
import '../../../app_state.dart';
import '../emergency/sos_bottom_sheet.dart';
import 'symptom_logger_sheet.dart';
import '../../../core/services/closed_loop_service.dart';
import '../../../core/widgets/sync_status_badge.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    // Calculate days to next 9th of the month (PMSMA date)
    final now = DateTime.now();
    var next9th = DateTime(now.year, now.month, 9);
    if (now.day > 9) {
      next9th = DateTime(now.year, now.month + 1, 9);
    }
    final daysToCheckup = next9th.difference(now).inDays;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      appBar: AppBar(
        title: Text(state.translate('Maternal Care', 'मातृत्व देखभाल', 'मातृत्व काळजी')),
        centerTitle: false,
        actions: [
          const SyncStatusBadge(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Demo Controls',
            onSelected: (val) async {
              if (val == 'simulate') {
                await ClosedLoopService.instance.simulateConsecutiveMissedDays();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Simulated 4 missed medicine days! ASHA Alert triggered.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } else if (val == 'reset') {
                await ClosedLoopService.instance.resetDemoLoop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo scenario reset to baseline.')),
                  );
                }
              } else if (val == 'lang_en') {
                AppState.instance.setLanguage(AppLanguage.english);
              } else if (val == 'lang_mr') {
                AppState.instance.setLanguage(AppLanguage.marathi);
              } else if (val == 'lang_hi') {
                AppState.instance.setLanguage(AppLanguage.hindi);
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                value: 'simulate',
                child: Text('⚡ Simulate 4 Missed Days (Demo)'),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Text('🔄 Reset Demo Scenario'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'lang_mr',
                child: Row(
                  children: [
                    Icon(Icons.translate, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('मराठी (Marathi)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'lang_hi',
                child: Row(
                  children: [
                    Icon(Icons.translate, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('हिंदी (Hindi)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'lang_en',
                child: Row(
                  children: [
                    Icon(Icons.translate, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('English'),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PatientHistoryScreen()),
                );
              },
              child: const CircleAvatar(
                backgroundColor: Color(0xFFFF8B94),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  state.translate('Hello, Mother! 👋', 'नमस्ते माताजी! 👋', 'नमस्कार माताजी! 👋'),
                  style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.volume_up_outlined, color: Colors.blue, size: 32),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.translate('Audio playback started', 'ऑडियो प्लेबैक शुरू हुआ', 'ऑडिओ प्लेबॅक सुरू झाले'))),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                   Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 48),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           state.translate('Next Checkup', 'अगली जांच', 'पुढील तपासणी'),
                           style: const TextStyle(fontSize: 16, color: Colors.grey),
                         ),
                         Text(
                           state.translate('In $daysToCheckup days (9th of Month)', '$daysToCheckup दिनों में (महीने की 9 तारीख)', '$daysToCheckup दिवसात (महिन्याची ९ तारीख)'),
                           style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                         ),
                       ],
                     ),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildActionCard(
              context,
              state.translate('Diet Plans', 'भोजन योजना', 'आहार योजना'),
              state.translate('What to eat', 'क्या खाएं', 'काय खावे'),
              Icons.restaurant_menu,
              Theme.of(context).colorScheme.tertiary,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DietPlanScreen())),
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              context,
              state.translate('Vaccines', 'टीकाकरण', 'लसीकरण'),
              state.translate('Your health shots', 'आपके टीके', 'तुमची लस'),
              Icons.vaccines_outlined,
              Theme.of(context).colorScheme.secondary,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VaccineScreen())),
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              context,
              state.translate('Medicines', 'दवाइयॉं', 'औषधे'),
              state.translate('Daily pills', 'दैनिक दवाएं', 'रोजची औषधे'),
              Icons.medication_outlined,
              const Color(0xFF90E0EF),
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicineScreen())),
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              context,
              state.translate('Find Nearest Clinic', 'निकटतम क्लिनिक खोजें', 'जवळचे क्लिनिक शोधा'),
              state.translate('Locate PHC/Hospital', 'PHC/अस्पताल खोजें', 'PHC/रुग्णालय शोधा'),
              Icons.local_hospital_outlined,
              Theme.of(context).colorScheme.tertiary,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NearestClinicScreen())),
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              context,
              state.translate('Report Symptoms', 'लक्षण रिपोर्ट करें', 'लक्षणे नोंदवा'),
              state.translate('Track health & danger signs', 'स्वास्थ्य और खतरे के लक्षण ट्रैक करें', 'आरोग्य आणि धोक्याची लक्षणे नोंदवा'),
              Icons.healing_outlined,
              const Color(0xFFFFC6FF),
              () => SymptomLoggerSheet.show(context),
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () => SosBottomSheet.show(context),
            backgroundColor: Colors.red,
            icon: const Icon(Icons.emergency, color: Colors.white),
            label: Text(
              state.translate('SOS', 'आपातकाल', 'तातडीचे'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: ChatbotWidget(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildActionCard(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData icon, 
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(50),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 52, color: Colors.black87),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 24, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
