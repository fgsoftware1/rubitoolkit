import 'package:flutter/material.dart';
import 'services/ping_service.dart';
import 'widgets/ping_form.dart';
import 'widgets/ping_result_view.dart';

class PingPage extends StatefulWidget {
  const PingPage({super.key});

  @override
  PingStatePage createState() => PingStatePage();
}

class PingStatePage extends State<PingPage> {
  // Controllers and services
  final _hostController = TextEditingController();
  final _pingService = PingService();
  
  // State variables
  bool _isLoading = false;
  PingResult? _pingResult;
  int _packetCount = 4;
  
  // History of ping operations
  final List<Map<String, dynamic>> _pingHistory = [];

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  /// Perform a ping operation
  Future<void> _ping() async {
    final host = _hostController.text.trim();
    
    // Skip if already pinging or no host entered
    if (_isLoading || host.isEmpty) return;

    setState(() {
      _isLoading = true;
      _pingResult = null;
    });

    try {
      // Perform the ping operation
      final result = await _pingService.pingHost(host, packetCount: _packetCount);
      
      // Add to history
      _addToHistory(host, result);
      
      // Update state
      setState(() {
        _pingResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _pingResult = PingResult.error('Unexpected error: $e');
        _isLoading = false;
      });
    }
  }
  
  /// Add a ping operation to history
  void _addToHistory(String host, PingResult result) {
    _pingHistory.add({
      'host': host,
      'timestamp': DateTime.now(),
      'result': result,
      'packetCount': _packetCount,
    });
    
    // Limit history to last 10 items
    if (_pingHistory.length > 10) {
      _pingHistory.removeAt(0);
    }
  }
  
  /// Update the packet count
  void _updatePacketCount(int count) {
    setState(() {
      _packetCount = count;
    });
  }
  
  /// Show ping history dialog
  void _showHistory() {
    if (_pingHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No ping history available')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ping History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _pingHistory.length,
            itemBuilder: (context, index) {
              final item = _pingHistory[_pingHistory.length - 1 - index];
              final result = item['result'] as PingResult;
              final timestamp = item['timestamp'] as DateTime;
              final formattedTime = '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
              
              return ListTile(
                title: Text(item['host']),
                subtitle: Text('${result.isSuccess ? 'Success' : 'Failed'} • $formattedTime • ${item['packetCount']} packets'),
                leading: Icon(
                  result.isSuccess ? Icons.check_circle : Icons.error,
                  color: result.isSuccess ? Colors.green : Colors.red,
                ),
                onTap: () {
                  // Reuse this host
                  _hostController.text = item['host'];
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
                        'Ping Tool',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Test connectivity to a host by sending ICMP echo requests',
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
            
            // Ping form
            PingForm(
              hostController: _hostController,
              isLoading: _isLoading,
              onPing: _ping,
              packetCount: _packetCount,
              onPacketCountChanged: _updatePacketCount,
            ),
            const SizedBox(height: 16),
            
            // Results
            Expanded(
              child: PingResultView(
                result: _pingResult,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}