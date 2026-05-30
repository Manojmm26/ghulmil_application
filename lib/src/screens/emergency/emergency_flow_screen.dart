import 'package:flutter/material.dart';

class EmergencyFlowScreen extends StatelessWidget {
  final String serviceType;
  const EmergencyFlowScreen({super.key, required this.serviceType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency')),
      body: Center(
        child: Text('EmergencyFlowScreen for $serviceType'),
      ),
    );
  }
}
