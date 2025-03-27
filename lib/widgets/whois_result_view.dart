import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/whois_service.dart';

/// Widget to display WHOIS lookup results
class WhoisResultView extends StatelessWidget {
  final WhoisResult? result;
  final bool isLoading;

  const WhoisResultView({
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
            Text('Looking up WHOIS information...'),
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
              Icons.person_search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Enter a domain to lookup WHOIS information',
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
                  const Spacer(),
                  // Copy button
                  if (result!.isSuccess)
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy raw data',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: result!.rawData));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Raw WHOIS data copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
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
              
              // WHOIS information
              if (result!.isSuccess) ...[
                // Tab view for parsed and raw data
                DefaultTabController(
                  length: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Parsed Data'),
                          Tab(text: 'Raw Data'),
                        ],
                        labelColor: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400, // Fixed height for the tab content
                        child: TabBarView(
                          children: [
                            // Parsed data view
                            _buildParsedDataView(result!.parsedData),
                            
                            // Raw data view
                            _buildRawDataView(result!.rawData),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build the parsed data view
  Widget _buildParsedDataView(Map<String, String> parsedData) {
    if (parsedData.isEmpty) {
      return const Center(
        child: Text('No parsed data available'),
      );
    }

    // Group data into categories
    final registrationData = <String, String>{};
    final contactData = <String, String>{};
    final serverData = <String, String>{};
    final otherData = <String, String>{};

    parsedData.forEach((key, value) {
      final lowerKey = key.toLowerCase();
      if (lowerKey.contains('date') || 
          lowerKey.contains('expir') || 
          lowerKey.contains('creat') || 
          lowerKey.contains('regist')) {
        registrationData[key] = value;
      } else if (lowerKey.contains('name') || 
                lowerKey.contains('contact') || 
                lowerKey.contains('email') || 
                lowerKey.contains('phone') || 
                lowerKey.contains('admin') || 
                lowerKey.contains('tech')) {
        contactData[key] = value;
      } else if (lowerKey.contains('server') || 
                lowerKey.contains('ns') || 
                lowerKey.contains('name server')) {
        serverData[key] = value;
      } else {
        otherData[key] = value;
      }
    });

    return ListView(
      children: [
        if (registrationData.isNotEmpty) ...[
          _buildDataSection('Registration Information', registrationData),
          const Divider(),
        ],
        if (serverData.isNotEmpty) ...[
          _buildDataSection('Name Servers', serverData),
          const Divider(),
        ],
        if (contactData.isNotEmpty) ...[
          _buildDataSection('Contact Information', contactData),
          const Divider(),
        ],
        if (otherData.isNotEmpty)
          _buildDataSection('Other Information', otherData),
      ],
    );
  }

  /// Build a section of parsed data
  Widget _buildDataSection(String title, Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...data.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(entry.value),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  /// Build the raw data view
  Widget _buildRawDataView(String rawData) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: SelectableText(
        rawData,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      ),
    );
  }
}