import 'package:flutter/material.dart';
import 'services/whois_service.dart';
import 'widgets/whois_form.dart';
import 'widgets/whois_result_view.dart';

class WhoisPage extends StatefulWidget {
  const WhoisPage({super.key});

  @override
  WhoisStatePage createState() => WhoisStatePage();
}

class WhoisStatePage extends State<WhoisPage> {
  // Controllers and services
  final _domainController = TextEditingController();
  final _whoisService = WhoisService();

  // State variables
  bool _isLoading = false;
  WhoisResult? _whoisResult;

  // History of WHOIS lookup operations
  final List<Map<String, dynamic>> _lookupHistory = [];

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  /// Perform a WHOIS lookup operation
  Future<void> _lookup() async {
    final domain = _domainController.text.trim();

    // Skip if already loading or no domain entered
    if (_isLoading || domain.isEmpty) return;

    setState(() {
      _isLoading = true;
      _whoisResult = null;
    });

    try {
      // Perform the WHOIS lookup
      final result = await _whoisService.lookup(domain);

      // Add to history
      _addToHistory(domain, result);

      // Update state
      setState(() {
        _whoisResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _whoisResult = WhoisResult.error('Unexpected error: $e');
        _isLoading = false;
      });
    }
  }

  /// Add a lookup operation to history
  void _addToHistory(String domain, WhoisResult result) {
    _lookupHistory.add({
      'domain': domain,
      'timestamp': DateTime.now(),
      'result': result,
    });

    // Limit history to last 10 items
    if (_lookupHistory.length > 10) {
      _lookupHistory.removeAt(0);
    }
  }

  /// Show lookup history dialog
  void _showHistory() {
    if (_lookupHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No WHOIS lookup history available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WHOIS Lookup History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _lookupHistory.length,
            itemBuilder: (context, index) {
              final item = _lookupHistory[_lookupHistory.length - 1 - index];
              final result = item['result'] as WhoisResult;
              final timestamp = item['timestamp'] as DateTime;
              final formattedTime =
                  '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

              return ListTile(
                title: Text(item['domain']),
                subtitle: Text(
                    '${result.isSuccess ? 'Success' : 'Failed'} • $formattedTime'),
                leading: Icon(
                  result.isSuccess ? Icons.check_circle : Icons.error,
                  color: result.isSuccess ? Colors.green : Colors.red,
                ),
                onTap: () {
                  // Reuse this domain
                  _domainController.text = item['domain'];
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
                        'WHOIS Lookup',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Query domain registration information',
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

            // WHOIS lookup form
            WhoisForm(
              domainController: _domainController,
              isLoading: _isLoading,
              onLookup: _lookup,
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: WhoisResultView(
                result: _whoisResult,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}