import 'package:flutter/material.dart';

/// Widget for the WHOIS lookup input form
class WhoisForm extends StatelessWidget {
  final TextEditingController domainController;
  final bool isLoading;
  final Function() onLookup;

  const WhoisForm({
    Key? key,
    required this.domainController,
    required this.isLoading,
    required this.onLookup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Domain input field
        TextField(
          controller: domainController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter domain',
            hintText: 'example.com',
            prefixIcon: Icon(Icons.language),
          ),
          onSubmitted: (_) => onLookup(),
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),
        
        // Lookup button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: isLoading ? null : onLookup,
              icon: const Icon(Icons.person_search),
              label: const Text('WHOIS Lookup'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }
}