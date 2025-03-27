import 'package:flutter/material.dart';

/// A welcome page that displays when the app first loads
class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo/icon
          const Icon(
            Icons.home_repair_service,
            size: 80,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 24),
          
          // App title
          const Text(
            'Welcome to RubiToolkit',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 16),
          
          // App description
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              'Your comprehensive toolkit for network diagnostics, OSINT research, and security tools',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 48),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                const Text(
                  'Getting Started',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInstructionStep(
                  icon: Icons.category,
                  text: 'Select a tool category from the left sidebar',
                ),
                const SizedBox(height: 12),
                _buildInstructionStep(
                  icon: Icons.build,
                  text: 'Choose a specific tool from the second sidebar',
                ),
                const SizedBox(height: 12),
                _buildInstructionStep(
                  icon: Icons.play_arrow,
                  text: 'Use the tool in the main content area',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstructionStep({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}