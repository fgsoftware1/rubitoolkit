import 'dart:async';
import 'dart:io';

/// Result of a ping operation
class PingResult {
  final bool isSuccess;
  final String message;
  final List<double> responseTimes;
  final int sentPackets;
  final int receivedPackets;
  final double packetLoss;
  final double averageTime;
  final double minTime;
  final double maxTime;

  PingResult({
    required this.isSuccess,
    required this.message,
    required this.responseTimes,
    required this.sentPackets,
    required this.receivedPackets,
    required this.packetLoss,
    required this.averageTime,
    required this.minTime,
    required this.maxTime,
  });

  /// Create an error result
  factory PingResult.error(String errorMessage) {
    return PingResult(
      isSuccess: false,
      message: errorMessage,
      responseTimes: [],
      sentPackets: 0,
      receivedPackets: 0,
      packetLoss: 100.0,
      averageTime: 0.0,
      minTime: 0.0,
      maxTime: 0.0,
    );
  }
}

/// Service for performing ping operations
class PingService {
  /// Ping a host with the specified number of packets
  Future<PingResult> pingHost(String host, {int packetCount = 4}) async {
    try {
      // Validate host
      if (host.isEmpty) {
        return PingResult.error('Host cannot be empty');
      }

      // Execute ping command
      final result = await _executePingCommand(host, packetCount);
      return result;
    } catch (e) {
      return PingResult.error('Error: $e');
    }
  }

  /// Execute the ping command and parse results
  Future<PingResult> _executePingCommand(String host, int packetCount) async {
    try {
      // Determine platform-specific ping command
      List<String> arguments;
      if (Platform.isWindows) {
        arguments = ['-n', packetCount.toString(), host];
      } else {
        // macOS, Linux, etc.
        arguments = ['-c', packetCount.toString(), host];
      }

      // Execute the ping command
      final process = await Process.run('ping', arguments);

      // Check if the command was successful
      if (process.exitCode != 0) {
        return PingResult.error('Host unreachable or invalid');
      }

      // Parse the output
      return _parsePingOutput(process.stdout.toString(), packetCount, host);
    } catch (e) {
      return PingResult.error('Failed to execute ping: $e');
    }
  }

  /// Parse the ping command output
  PingResult _parsePingOutput(String output, int packetCount, String host) {
    try {
      // Extract response times
      final List<double> responseTimes = [];
      final RegExp timeRegex = RegExp(r'time=(\d+\.?\d*) ms');
      final matches = timeRegex.allMatches(output);

      for (final match in matches) {
        if (match.group(1) != null) {
          responseTimes.add(double.parse(match.group(1)!));
        }
      }

      // Calculate statistics
      final int receivedPackets = responseTimes.length;
      final double packetLoss = 100 - (receivedPackets / packetCount * 100);

      double averageTime = 0;
      double minTime = responseTimes.isEmpty ? 0 : responseTimes[0];
      double maxTime = responseTimes.isEmpty ? 0 : responseTimes[0];

      if (responseTimes.isNotEmpty) {
        averageTime =
            responseTimes.reduce((a, b) => a + b) / responseTimes.length;
        minTime = responseTimes.reduce((a, b) => a < b ? a : b);
        maxTime = responseTimes.reduce((a, b) => a > b ? a : b);
      }

      // Create result
      return PingResult(
        isSuccess: receivedPackets > 0,
        message: receivedPackets > 0
            ? 'Successfully pinged $host'
            : 'Failed to ping $host',
        responseTimes: responseTimes,
        sentPackets: packetCount,
        receivedPackets: receivedPackets,
        packetLoss: packetLoss,
        averageTime: averageTime,
        minTime: minTime,
        maxTime: maxTime,
      );
    } catch (e) {
      return PingResult.error('Failed to parse ping results: $e');
    }
  }
}
