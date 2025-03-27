import 'package:dnsolve/dnsolve.dart';

/// Result of a DNS lookup operation
class DnsResult {
  final bool isSuccess;
  final String message;
  final List<DnsRecord> records;

  DnsResult({
    required this.isSuccess,
    required this.message,
    required this.records,
  });

  /// Create an error result
  factory DnsResult.error(String errorMessage) {
    return DnsResult(
      isSuccess: false,
      message: errorMessage,
      records: [],
    );
  }
}

/// Represents a DNS record
class DnsRecord {
  final String name;
  final String type;
  final String value;
  final int ttl;

  DnsRecord({
    required this.name,
    required this.type,
    required this.value,
    required this.ttl,
  });

  @override
  String toString() {
    return '$name $ttl IN $type $value';
  }
}

/// Service for performing DNS lookup operations
class DnsService {
  /// Perform a DNS lookup for the specified domain
  Future<DnsResult> lookup(String domain, {RecordType type = RecordType.any}) async {
    try {
      // Validate domain
      if (domain.isEmpty) {
        return DnsResult.error('Domain cannot be empty');
      }

      // Create DNS resolver
      final dnsolve = DNSolve();

      // Perform lookup
      final response = await dnsolve.lookup(domain, dnsSec: true, type: type);

      // Parse results
      final records = <DnsRecord>[];
      if (response.answer != null && response.answer!.records != null) {
        for (final record in response.answer!.records!) {
          final parts = record.toBind.split(RegExp(r'\s+'));
          if (parts.length >= 5) {
            records.add(DnsRecord(
              name: parts[0],
              ttl: int.tryParse(parts[1]) ?? 0,
              type: parts[3],
              value: parts.sublist(4).join(' '),
            ));
          }
        }
      }

      // Sort records by type
      records.sort((a, b) => a.type.compareTo(b.type));

      return DnsResult(
        isSuccess: records.isNotEmpty,
        message: records.isNotEmpty 
            ? 'Found ${records.length} DNS records for $domain' 
            : 'No DNS records found for $domain',
        records: records,
      );
    } catch (e) {
      return DnsResult.error('Error performing DNS lookup: $e');
    }
  }
}