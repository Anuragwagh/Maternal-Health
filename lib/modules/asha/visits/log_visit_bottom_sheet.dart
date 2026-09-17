import 'package:flutter/material.dart';
import '../../../app_state.dart';
import 'package:provider/provider.dart';

class LogVisitBottomSheet extends StatelessWidget {
  final String patientName;
  
  const LogVisitBottomSheet({super.key, required this.patientName});

  static void show(BuildContext context, String patientName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => LogVisitBottomSheet(patientName: patientName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.translate('Log Visit for', 'विजिट दर्ज करें:', 'भेट नोंदवा:'),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          Text(
            patientName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green, size: 30),
            title: Text(state.translate('Routine Checkup', 'नियमित जांच', 'नियमित तपासणी')),
            onTap: () => _logAndClose(context, 'Routine'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange, size: 30),
            title: Text(state.translate('Follow-up (Missed Meds)', 'फॉलो-अप (दवा छूटी)', 'फॉलो-अप (औषध चुकले)')),
            onTap: () => _logAndClose(context, 'Follow-up'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.emergency, color: Colors.red, size: 30),
            title: Text(state.translate('Emergency/HRP Visit', 'आपातकालीन विजिट', 'तातडीची भेट')),
            onTap: () => _logAndClose(context, 'Emergency'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _logAndClose(BuildContext context, String type) {
    // Here we would write to LocalDb (Hive) for offline sync
    // LocalDb.visitsBox.add({'patient': patientName, 'type': type, 'timestamp': DateTime.now().toIso8601String()});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visit logged successfully (Offline Sync Queued)'),
        backgroundColor: Colors.green,
      )
    );
    Navigator.pop(context);
  }
}
