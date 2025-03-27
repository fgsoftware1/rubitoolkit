import 'package:flutter/material.dart';
import 'package:dnsolve/dnsolve.dart';

/// Widget for the DNS lookup input form
class DnsForm extends StatelessWidget {
  final TextEditingController domainController;
  final bool isLoading;
  final Function() onLookup;
  final RecordType selectedRecordType;
  final Function(RecordType) onRecordTypeChanged;

  const DnsForm({
    Key? key,
    required this.domainController,
    required this.isLoading,
    required this.onLookup,
    required this.selectedRecordType,
    required this.onRecordTypeChanged,
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

        // Options row
        Row(
          children: [
            // Record type selector
            Expanded(
              child: Row(
                children: [
                  const Text('Record Type:'),
                  const SizedBox(width: 8),
                  DropdownButton<RecordType>(
                    value: selectedRecordType,
                    onChanged: isLoading
                        ? null
                        : (RecordType? value) {
                            if (value != null) {
                              onRecordTypeChanged(value);
                            }
                          },
                    items: [
                      RecordType.A,
                      RecordType.aaaa,
                      RecordType.cname,
                      RecordType.mx,
                      RecordType.ns,
                      RecordType.txt,
                      RecordType.soa,
                      RecordType.srv,
                      RecordType.any,
                    ].map((type) {
                      return DropdownMenuItem<RecordType>(
                        value: type as RecordType?,
                        child: Text(type.name.toUpperCase()),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Lookup button
            ElevatedButton.icon(
              onPressed: isLoading ? null : onLookup,
              icon: const Icon(Icons.dns),
              label: const Text('Lookup'),
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
