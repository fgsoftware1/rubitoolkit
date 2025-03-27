import 'dart:async';
import 'package:http/http.dart' as http;
import '../model/country.dart';
import 'CountryAPI.dart';

/// Model class to hold IP and country information
class IPInfo {
  final String ip;
  final Country country;

  IPInfo({
    required this.ip,
    required this.country
  });

  /// Create an unknown IP info object
  factory IPInfo.unknown() {
    return IPInfo(
      ip: 'Unknown',
      country: Country.unknown(),
    );
  }
}

/// Service for retrieving IP address information
class ShodanAPI {
  // API configuration
  static const String _shodanApiUrl = 'https://api.shodan.io/tools/myip';
  static const String _fallbackApiUrl = 'https://api.ipify.org';
  static const Duration _timeout = Duration(seconds: 5);

  // Dependencies
  final CountryAPI _countryAPI;

  // Cache
  IPInfo? _cachedIPInfo;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidity = Duration(minutes: 5);

  /// Constructor with dependency injection for testability
  ShodanAPI({CountryAPI? countryAPI}) : _countryAPI = countryAPI ?? CountryAPI();

  /// Get the current IP address and country information
  Future<IPInfo> getMyIP() async {
    // Return cached result if it's still valid
    if (_isCacheValid()) {
      return _cachedIPInfo!;
    }

    try {
      final ip = await _fetchIPAddress();
      if (ip == 'Unknown') {
        return IPInfo.unknown();
      }

      // Get country information for the IP
      final country = await _countryAPI.getCountryFromIP(ip);

      // Cache the result
      final ipInfo = IPInfo(ip: ip, country: country);
      _cacheResult(ipInfo);

      return ipInfo;
    } catch (e) {
      print('Error getting IP information: $e');
      return IPInfo.unknown();
    }
  }

  /// Check if the cached result is still valid
  bool _isCacheValid() {
    if (_cachedIPInfo == null || _lastFetchTime == null) {
      return false;
    }

    final now = DateTime.now();
    return now.difference(_lastFetchTime!) < _cacheValidity;
  }

  /// Cache the IP info result
  void _cacheResult(IPInfo ipInfo) {
    _cachedIPInfo = ipInfo;
    _lastFetchTime = DateTime.now();
  }

  /// Fetch the IP address from API services
  Future<String> _fetchIPAddress() async {
    final client = http.Client();

    // Try primary API first
    try {
      final response = await client.get(Uri.parse(_shodanApiUrl))
          .timeout(_timeout, onTimeout: () {
        throw TimeoutException('Shodan API request timed out');
      });

      if (response.statusCode == 200) {
        return response.body.trim();
      }
    } catch (e) {
      print('Primary IP API failed: $e');
      // Continue to fallback
    }

    // Try fallback API
    try {
      final response = await client.get(Uri.parse(_fallbackApiUrl))
          .timeout(_timeout, onTimeout: () {
        throw TimeoutException('Fallback API request timed out');
      });

      if (response.statusCode == 200) {
        return response.body.trim();
      }
    } catch (e) {
      print('Fallback IP API failed: $e');
    }

    return 'Unknown';
  }
}
