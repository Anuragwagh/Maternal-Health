import 'package:flutter/material.dart';
import '../../app_state.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  state.translate('Maternal Care', 'मातृत्व देखभाल', 'मातृत्व काळजी'),
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 60),
                _buildRoleCard(
                  context,
                  state.translate('I am a Patient', 'मैं मरीज हूँ', 'मी रुग्ण आहे'),
                  state.translate('Pregnant Mother', 'गर्भवती माता', 'गर्भवती माता'),
                  Icons.pregnant_woman,
                  Theme.of(context).colorScheme.primary,
                  () => Navigator.pushNamed(context, '/login'),
                ),
                const SizedBox(height: 20),
                _buildRoleCard(
                  context,
                  state.translate('I am an ASHA Worker', 'मैं आशा कार्यकर्ता हूँ', 'मी आशा कार्यकर्ता आहे'),
                  state.translate('Health Worker', 'स्वास्थ्य कार्यकर्ता', 'आरोग्य कार्यकर्ता'),
                  Icons.medical_services,
                  Theme.of(context).colorScheme.secondary,
                  () => Navigator.pushNamed(context, '/asha_pin_login'),
                ),
                const SizedBox(height: 20),
                _buildRoleCard(
                  context,
                  state.translate('I am a Supervisor', 'मैं पर्यवेक्षक हूँ', 'मी पर्यवेक्षक आहे'),
                  state.translate('PHC Official', 'PHC अधिकारी', 'PHC अधिकारी'),
                  Icons.admin_panel_settings,
                  const Color(0xFF005B96), // Darker medical blue
                  () => Navigator.pushNamed(context, '/supervisor_home'),
                ),
                const SizedBox(height: 20),
                _buildRoleCard(
                  context,
                  state.translate('I am a Caregiver', 'मैं देखभाल करने वाला हूँ', 'मी काळजी घेणारा आहे'),
                  state.translate('Family Member', 'परिवार के सदस्य', 'कुटुंबातील सदस्य'),
                  Icons.family_restroom,
                  const Color(0xFF48CAE4), // Soft cyan
                  () => Navigator.pushNamed(context, '/caregiver_home'),
                ),

                const SizedBox(height: 40),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.translate),
                  label: Text(state.translate('Change Language', 'भाषा बदलें', 'भाषा बदला')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
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
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, size: 48, color: color),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
