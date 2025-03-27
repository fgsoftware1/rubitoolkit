import 'package:whois/whois.dart';

/// Result of a WHOIS lookup operation
class WhoisResult {
  final bool isSuccess;
  final String message;
  final String rawData;
  final Map<String, String> parsedData;

  WhoisResult({
    required this.isSuccess,
    required this.message,
    required this.rawData,
    required this.parsedData,
  });

  /// Create an error result
  factory WhoisResult.error(String errorMessage) {
    return WhoisResult(
      isSuccess: false,
      message: errorMessage,
      rawData: '',
      parsedData: {},
    );
  }
}

/// Service for performing WHOIS lookup operations
class WhoisService {
  /// Perform a WHOIS lookup for the specified domain
  Future<WhoisResult> lookup(String domain) async {
    try {
      // Validate domain
      if (domain.isEmpty) {
        return WhoisResult.error('Domain cannot be empty');
      }

      // Set lookup options
      const options = LookupOptions(
        timeout: Duration(milliseconds: 10000),
        port: 43,
      );

      // Perform lookup
      final response = await Whois.lookup(domain, options);
      final rawData = response.toString();

      // Parse the raw WHOIS data into key-value pairs
      final parsedData = _parseWhoisData(rawData);

      return WhoisResult(
        isSuccess: rawData.isNotEmpty,
        message: rawData.isNotEmpty 
            ? 'WHOIS information for $domain' 
            : 'No WHOIS information found for $domain',
        rawData: rawData,
        parsedData: parsedData,
      );
    } catch (e) {
      return WhoisResult.error('Error performing WHOIS lookup: $e');
    }
  }

  /// Parse raw WHOIS data into key-value pairs
  Map<String, String> _parseWhoisData(String rawData) {
    final result = <String, String>{};
    
    // Split by lines and process each line
    final lines = rawData.split('\n');
    for (final line in lines) {
      // Skip empty lines and comments
      if (line.trim().isEmpty || line.trim().startsWith('%') || line.trim().startsWith('#')) {
        continue;
      }
      
      // Try to split by colon to get key-value pairs
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex).trim();
        final value = line.substring(colonIndex + 1).trim();
        
        // Only add if we have both key and value
        if (key.isNotEmpty && value.isNotEmpty) {
          // Merge values for duplicate keys
          if (result.containsKey(key)) {
            result[key] = '${result[key]}, $value';
          } else {
            result[key] = value;
          }
        }
      }
    }
    
    return result;
  }
}