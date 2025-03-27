import 'package:flutter/material.dart';

/// Widget for the ping input form
class PingForm extends StatelessWidget {
  final TextEditingController hostController;
  final bool isLoading;
  final Function() onPing;
  final int packetCount;
  final Function(int) onPacketCountChanged;

  const PingForm({
    Key? key,
    required this.hostController,
    required this.isLoading,
    required this.onPing,
    required this.packetCount,
    required this.onPacketCountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Host input field
        TextField(
          controller: hostController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter domain or IP',
            hintText: 'example.com or 8.8.8.8',
            prefixIcon: Icon(Icons.language),
          ),
          onSubmitted: (_) => onPing(),
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),

        // Options row
        Row(
          children: [
            // Packet count selector
            Expanded(
              child: Row(
                children: [
                  const Text('Packet Count:'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: packetCount,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              onPacketCountChanged(value);
                            }
                          },
                    items: [4, 8, 16, 32, 64].map((count) {
                      return DropdownMenuItem<int>(
                        value: count,
                        child: Text('$count'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Ping button
            ElevatedButton.icon(
              onPressed: isLoading ? null : onPing,
              icon: const Icon(Icons.network_ping),
              label: const Text('Ping'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
