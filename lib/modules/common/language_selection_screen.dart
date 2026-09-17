import 'package:flutter/material.dart';
import '../../app_state.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.tertiary],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.language, size: 100, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              const Text(
                'Choose Language',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text(
                'भाषा चुनें  •  भाषा निवडा',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              _buildLangButton(context, 'English', 'A', Theme.of(context).colorScheme.primary, AppLanguage.english),
              const SizedBox(height: 20),
              _buildLangButton(context, 'हिंदी (Hindi)', 'अ', Theme.of(context).colorScheme.secondary, AppLanguage.hindi),
              const SizedBox(height: 20),
              _buildLangButton(context, 'मराठी (Marathi)', 'म', Theme.of(context).colorScheme.tertiary, AppLanguage.marathi),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String label, String iconText, Color color, AppLanguage lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: color, width: 2),
          ),
          elevation: 5,
        ),
        onPressed: () {
          AppState.instance.setLanguage(lang);
          Navigator.pushReplacementNamed(context, '/consent');
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                iconText,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
