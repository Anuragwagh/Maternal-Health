import 'package:flutter/material.dart';
import '../../../app_state.dart';

class NearestClinicScreen extends StatelessWidget {
  const NearestClinicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(
          state.translate('Nearest Clinics', 'निकटतम क्लीनिक', 'जवळचे क्लिनिक'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Simulated Map Area
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              image: const DecorationImage(
                image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=20.5937,78.9629&zoom=14&size=600x300&maptype=roadmap&markers=color:red%7Clabel:H%7C20.5937,78.9629&key=YOUR_API_KEY'), // Simulated static map visual (if fails to load, background color is visible)
                fit: BoxFit.cover,
                // We'll use a placeholder if network fails
              ),
            ),
            child: Stack(
              children: [
                // Fallback map pattern if image fails
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.5,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                      ),
                      itemBuilder: (context, index) => Icon(Icons.add, color: Colors.blue.shade200, size: 20),
                    ),
                  ),
                ),
                // Center pin
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('You are here', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ],
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 60,
                  child: _buildMapPin('Rural PHC'),
                ),
                Positioned(
                  bottom: 50,
                  right: 80,
                  child: _buildMapPin('District Hospital'),
                ),
              ],
            ),
          ),
          
          // Clinic List
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4F8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    state.translate('Nearby Facilities', 'आसपास की सुविधाएं', 'जवळपासच्या सुविधा'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  _buildClinicCard(
                    context, 
                    state.translate('Primary Health Centre (PHC)', 'प्राथमिक स्वास्थ्य केंद्र', 'प्राथमिक आरोग्य केंद्र'), 
                    '1.2 km', 
                    true
                  ),
                  const SizedBox(height: 12),
                  _buildClinicCard(
                    context, 
                    state.translate('District Civil Hospital', 'जिला सिविल अस्पताल', 'जिल्हा सामान्य रुग्णालय'), 
                    '4.5 km', 
                    false
                  ),
                  const SizedBox(height: 12),
                  _buildClinicCard(
                    context, 
                    state.translate('Maternity Clinic', 'मातृत्व क्लिनिक', 'प्रसूतिगृह'), 
                    '5.8 km', 
                    false
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin(String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
          child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const Icon(Icons.local_hospital, color: Colors.green, size: 24),
      ],
    );
  }

  Widget _buildClinicCard(BuildContext context, String title, String distance, bool isOpen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_hospital, color: Colors.blue, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(distance, style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 14, color: isOpen ? Colors.green : Colors.orange),
                    const SizedBox(width: 4),
                    Text(isOpen ? 'Open Now' : 'Closes 5 PM', style: TextStyle(color: isOpen ? Colors.green : Colors.orange, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting navigation... (Demo Mode)')),
              );
            },
            icon: const Icon(Icons.directions, color: Colors.blue),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
            ),
          )
        ],
      ),
    );
  }
}
