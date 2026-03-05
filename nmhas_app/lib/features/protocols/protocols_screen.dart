import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ProtocolsScreen extends StatelessWidget {
  const ProtocolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protocols'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 64, color: AppColors.teal),
            SizedBox(height: 16),
            Text(
              'Protocol viewer coming soon',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'MN  |  WI  |  Air Medical',
              style: TextStyle(color: AppColors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
