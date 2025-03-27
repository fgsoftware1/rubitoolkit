import 'package:dnsolve/dnsolve.dart';
import 'package:flutter/material.dart';
import 'services/dns_service.dart';
import 'widgets/dns_form.dart';
import 'widgets/dns_result_view.dart';

class DnsPage extends StatefulWidget {
  const DnsPage({super.key});

  @override
  DnsPageState createState() => DnsPageState();
}

class DnsPageState extends State<DnsPage> {
  // Controllers and services
  final _domainController = TextEditingController();
  final _dnsService = DnsService();

  // State variables
  bool _isLoading = false;
  DnsResult? _dnsResult;
  RecordType _selectedRecordType = RecordType.any;

  // History of DNS lookup operations
  final List<Map<String, dynamic>> _lookupHistory = [];

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  /// Perform a DNS lookup operation
  Future<void> _lookup() async {
    final domain = _domainController.text.trim();

    // Skip if already loading or no domain entered
    if (_isLoading || domain.isEmpty) return;

    setState(() {
      _isLoading = true;
      _dnsResult = null;
    });

    try {
      // Perform the DNS lookup
      final result = await _dnsService.lookup(domain, type: _selectedRecordType);

      // Add to history
      _addToHistory(domain, result);

      // Update state
      setState(() {
        _dnsResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _dnsResult = DnsResult.error('Unexpected error: $e');
        _isLoading = false;
      });
    }
  }

  /// Add a lookup operation to history
  void _addToHistory(String domain, DnsResult result) {
    _lookupHistory.add({
      'domain': domain,
      'timestamp': DateTime.now(),
      'result': result,
      'recordType': _selectedRecordType,
    });

    // Limit history to last 10 items
    if (_lookupHistory.length > 10) {
      _lookupHistory.removeAt(0);
    }
  }

  /// Update the record type
  void _updateRecordType(RecordType type) {
    setState(() {
      _selectedRecordType = type;
    });
  }

  /// Show lookup history dialog
  void _showHistory() {
    if (_lookupHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No DNS lookup history available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DNS Lookup History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _lookupHistory.length,
            itemBuilder: (context, index) {
              final item = _lookupHistory[_lookupHistory.length - 1 - index];
              final result = item['result'] as DnsResult;
              final timestamp = item['timestamp'] as DateTime;
              final formattedTime =
                  '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
              final recordType = item['recordType'] as RecordType;

              return ListTile(
                title: Text(item['domain']),
                subtitle: Text(
                    '${result.isSuccess ? 'Success' : 'Failed'} • $formattedTime • ${recordType.name.toUpperCase()} records'),
                leading: Icon(
                  result.isSuccess ? Icons.check_circle : Icons.error,
                  color: result.isSuccess ? Colors.green : Colors.red,
                ),
                onTap: () {
                  // Reuse this domain
                  _domainController.text = item['domain'];
                  _selectedRecordType = recordType;
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with title and actions
            Row(
              children: [
                // Title
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DNS Lookup',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Query DNS records for a domain',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // History button
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'View History',
                  onPressed: _showHistory,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // DNS lookup form
            DnsForm(
              domainController: _domainController,
              isLoading: _isLoading,
              onLookup: _lookup,
              selectedRecordType: _selectedRecordType,
              onRecordTypeChanged: _updateRecordType,
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: DnsResultView(
                result: _dnsResult,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}