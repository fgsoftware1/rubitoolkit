import 'package:flutter/material.dart';
import '../data/model/country.dart';
import '../data/provider/ShodanAPI_new.dart';

/// A widget that displays IP information with country details
class IPInfoDisplay extends StatelessWidget {
  final IPInfo ipInfo;

  const IPInfoDisplay({
    Key? key,
    required this.ipInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // IP Address
        Text(
          ipInfo.ip,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        
        // Country Information
        _buildCountryInfo(ipInfo.country),
      ],
    );
  }
  
  Widget _buildCountryInfo(Country country) {
    return Column(
      children: [
        // Country name with flag emoji
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              country.flagEmoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Text(
              country.name,
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Flag image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            country.flagUrl,
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return const Text('Flag image not available');
            },
          ),
        ),
        const SizedBox(height: 12),
        
        // Country code
        Text(
          'Country Code: ${country.code}',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}

/// A widget that fetches and displays IP information
class IPInfoWidget extends StatelessWidget {
  final ShodanAPI shodanAPI;

  const IPInfoWidget({
    Key? key,
    required this.shodanAPI,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<IPInfo>(
      future: shodanAPI.getMyIP(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Fetching IP information...'),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          return Center(
            child: IPInfoDisplay(ipInfo: snapshot.data!),
          );
        } else {
          return const Center(
            child: Text('No IP information found', style: TextStyle(fontSize: 24)),
          );
        }
      },
    );
  }
}