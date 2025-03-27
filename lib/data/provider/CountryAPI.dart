import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/country.dart';

/// Service for retrieving country information from IP addresses
class CountryAPI {
  // API configuration
  static const String _ipApiUrl = 'https://ipapi.co/';
  static const Duration _timeout = Duration(seconds: 5);

  // Simple in-memory cache
  final Map<String, Country> _cache = {};

  /// Fetches country information for the given IP address
  /// Returns a Country object with name, code, and flag information
  Future<Country> getCountryFromIP(String ip) async {
    // Return cached result if available
    if (_cache.containsKey(ip)) {
      return _cache[ip]!;
    }

    try {
      final client = http.Client();
      final uri = Uri.parse('$_ipApiUrl$ip/json/');

      final response = await client.get(uri).timeout(_timeout, onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if we have valid country data
        if (data['country_name'] != null && data['country_code'] != null) {
          final country = Country.fromJson({
            'name': data['country_name'],
            'country_code': data['country_code'],
          });

          // Cache the result
          _cache[ip] = country;
          return country;
        }
      }

      // Fallback to unknown country
      return Country.unknown();
    } catch (e) {
      print('Error fetching country data: $e');
      return Country.unknown();
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
