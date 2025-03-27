import 'package:flutter/material.dart';
import '../services/ping_service.dart';

/// Widget to display ping results
class PingResultView extends StatelessWidget {
  final PingResult? result;
  final bool isLoading;

  const PingResultView({
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
            Text('Pinging...'),
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
              Icons.network_check,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Enter a host to ping',
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

              // Statistics
              if (result!.isSuccess) ...[
                _buildStatRow('Packets',
                    '${result!.receivedPackets}/${result!.sentPackets} received'),
                _buildStatRow(
                    'Packet Loss', '${result!.packetLoss.toStringAsFixed(1)}%'),
                _buildStatRow('Average Time',
                    '${result!.averageTime.toStringAsFixed(2)} ms'),
                _buildStatRow(
                    'Min Time', '${result!.minTime.toStringAsFixed(2)} ms'),
                _buildStatRow(
                    'Max Time', '${result!.maxTime.toStringAsFixed(2)} ms'),

                // Response times chart
                if (result!.responseTimes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Response Times',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: _buildResponseTimesChart(result!.responseTimes),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build a statistic row with label and value
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Build a simple chart of response times
  Widget _buildResponseTimesChart(List<double> times) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Y-axis labels
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${times.reduce((a, b) => a > b ? a : b).ceil()} ms'),
            const Text('0 ms'),
          ],
        ),
        const SizedBox(width: 8),

        // Chart bars
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: times.map((time) {
              final maxTime = times.reduce((a, b) => a > b ? a : b);
              final height = maxTime > 0 ? (time / maxTime) * 80 : 0.0;

              return Tooltip(
                message: '${time.toStringAsFixed(2)} ms',
                child: Container(
                  width: 20,
                  height: height.clamp(4, 80),
                  color: _getColorForTime(time, times),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Get color for time bar based on relative value
  Color _getColorForTime(double time, List<double> allTimes) {
    final maxTime = allTimes.reduce((a, b) => a > b ? a : b);
    final minTime = allTimes.reduce((a, b) => a < b ? a : b);

    if (maxTime == minTime) return Colors.green;

    final normalized = (time - minTime) / (maxTime - minTime);

    if (normalized < 0.33) return Colors.green;
    if (normalized < 0.66) return Colors.orange;
    return Colors.red;
  }
}
