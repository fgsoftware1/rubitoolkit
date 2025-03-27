import 'package:flutter/material.dart';
import '../services/dns_service.dart';

/// Widget to display DNS lookup results
class DnsResultView extends StatelessWidget {
  final DnsResult? result;
  final bool isLoading;

  const DnsResultView({
    Key? key,
    required this.result,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Looking up DNS records...'),
          ],
        ),
      );
    }

    if (result == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dns,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Enter a domain to lookup DNS records',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Result header
              Row(
                children: [
                  Icon(
                    result!.isSuccess ? Icons.check_circle : Icons.error,
                    color: result!.isSuccess ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    result!.isSuccess ? 'Success' : 'Failed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: result!.isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const Divider(),

              // Message
              Text(
                result!.message,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Records
              if (result!.isSuccess && result!.records.isNotEmpty) ...[
                const Text(
                  'DNS Records',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Group records by type
                ...groupRecordsByType(result!.records).entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Record type header
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Records of this type
                      ...entry.value.map((record) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  record.value,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'TTL: ${record.ttl}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Group records by their type
  Map<String, List<DnsRecord>> groupRecordsByType(List<DnsRecord> records) {
    final result = <String, List<DnsRecord>>{};

    for (final record in records) {
      if (!result.containsKey(record.type)) {
        result[record.type] = [];
      }
      result[record.type]!.add(record);
    }

    return result;
  }
}
