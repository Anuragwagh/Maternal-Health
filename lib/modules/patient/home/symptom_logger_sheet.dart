import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_state.dart';
import '../../../core/database/local_db.dart';
import '../../../core/models/alert_model.dart';

class SymptomLoggerSheet extends StatefulWidget {
  const SymptomLoggerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SymptomLoggerSheet(),
    );
  }

  @override
  State<SymptomLoggerSheet> createState() => _SymptomLoggerSheetState();
}

class _SymptomLoggerSheetState extends State<SymptomLoggerSheet> {
  final Map<String, bool> _symptoms = {
    'vaginal_bleeding': false,
    'severe_headache': false,
    'reduced_fetal_movement': false,
    'high_fever': false,
    'swelling_hands_face': false,
    'nausea_vomiting': false,
  };

  bool _caregiverConsent = true;

  @override
  void initState() {
    super.initState();
    _loadConsent();
  }

  void _loadConsent() {
    final consent = LocalDb.prefsBox.get('caregiver_consent', defaultValue: true) as bool;
    setState(() => _caregiverConsent = consent);
  }

  Future<void> _submitSymptoms(AppState state) async {
    final selected = _symptoms.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selected.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final hasCriticalDangerSigns = _symptoms['vaginal_bleeding'] == true ||
        _symptoms['severe_headache'] == true ||
        _symptoms['reduced_fetal_movement'] == true;

    if (hasCriticalDangerSigns) {
      final alert = AlertModel(
        id: 'alert-${DateTime.now().millisecondsSinceEpoch}',
        patientId: '55555555-5555-5555-5555-555555555501',
        patientName: 'Priyanka More',
        type: 'danger_sign_reported',
        severity: 'urgent',
        status: AlertStatus.open,
        assignedTo: '22222222-2222-2222-2222-222222222241',
        message: '🚨 Danger Signs reported by Mother: ${selected.join(', ')}',
        createdAt: DateTime.now(),
      );

      await LocalDb.alertsBox.put(alert.id, alert.toMap());
      await LocalDb.enqueueSync(
        table: 'alerts',
        action: 'insert',
        payload: alert.toMap(),
      );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hasCriticalDangerSigns
              ? state.translate('🚨 Urgent: Danger signs logged! ASHA alerted.', '🚨 तत्काल: खतरे के लक्षण दर्ज! आशा को सतर्क किया गया।', '🚨 तातडीचे: धोक्याची लक्षणे नोंदवली! आशा कार्यकर्त्याला अलर्ट पाठवला.')
              : state.translate('Symptoms logged successfully.', 'लक्षण सफलतापूर्वक दर्ज किए गए।', 'लक्षणे यशस्वीरित्या नोंदवली गेली.')),
          backgroundColor: hasCriticalDangerSigns ? Colors.red : Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.translate('Report Symptoms & Health', 'लक्षण और स्वास्थ्य रिपोर्ट करें', 'लक्षणे आणि आरोग्य नोंदवा'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              state.translate(
                'Check any symptoms you are feeling today. Critical signs immediately notify your ASHA.',
                'आज आप जो भी लक्षण महसूस कर रही हैं, उन्हें चुनें। गंभीर लक्षण तुरंत आपकी आशा को सूचित करते हैं।',
                'आज तुम्हाला जाणवणारी लक्षणे निवडा. गंभीर लक्षणे ताबडतोब तुमच्या आशा कार्यकर्त्याला कळवली जातात.',
              ),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildCheckbox('vaginal_bleeding', state.translate('Vaginal Bleeding / Spotting', 'योनि से रक्तस्राव', 'रक्तस्त्राव / डाग'), isDanger: true),
            _buildCheckbox('severe_headache', state.translate('Severe Headache or Blurred Vision', 'गंभीर सिरदर्द या धुंधला दिखना', 'तीव्र डोकेदुखी किंवा अंधुक दिसणे'), isDanger: true),
            _buildCheckbox('reduced_fetal_movement', state.translate('Reduced / Absent Fetal Movement', 'शिशु की हलचल में कमी', 'बाळाची हालचाल कमी होणे'), isDanger: true),
            _buildCheckbox('high_fever', state.translate('High Fever / Chills', 'तेज बुखार / ठंड लगना', 'तीव्र ताप / थंडी वाजणे')),
            _buildCheckbox('swelling_hands_face', state.translate('Severe Swelling in Face / Hands', 'चेहरे या हाथों में गंभीर सूजन', 'चेहऱ्यावर किंवा हातांवर तीव्र सूज')),
            _buildCheckbox('nausea_vomiting', state.translate('Excessive Nausea / Vomiting', 'अत्यधिक मतली / उल्टी', 'अति मळमळ किंवा उलट्या')),
            const Divider(height: 32),
            // Caregiver Sharing Consent Toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                state.translate('Share Health Status with Family Caregiver', 'परिवार के देखभालकर्ता के साथ स्वास्थ्य साझा करें', 'कुटुंबातील काळजीवाहू व्यक्तीसोबत आरोग्य माहिती शेअर करा'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                state.translate('Allows linked husband/family to view checkup reminders and medicine adherence.', 'पति/परिवार को जांच और दवा पालन देखने की अनुमति देता है।', 'पती/कुटुंबाला तपासणी आणि औषध पालन पाहण्याची परवानगी देते.'),
                style: const TextStyle(fontSize: 12),
              ),
              value: _caregiverConsent,
              onChanged: (val) {
                setState(() => _caregiverConsent = val);
                LocalDb.prefsBox.put('caregiver_consent', val);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitSymptoms(state),
              child: Text(state.translate('Save & Submit', 'सहेजें और सबमिट करें', 'जतन करा आणि सबमिट करा')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String key, String label, {bool isDanger = false}) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          if (isDanger) ...[
            const Icon(Icons.warning_rounded, color: Colors.red, size: 18),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isDanger ? FontWeight.bold : FontWeight.normal,
                color: isDanger && (_symptoms[key] == true) ? Colors.red.shade800 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
      value: _symptoms[key] ?? false,
      activeColor: isDanger ? Colors.red : Theme.of(context).primaryColor,
      onChanged: (val) {
        setState(() => _symptoms[key] = val ?? false);
      },
    );
  }
}
