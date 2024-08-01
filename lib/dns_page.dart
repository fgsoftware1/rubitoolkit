import 'package:dnsolve/dnsolve.dart';
import 'package:flutter/material.dart';

class DnsPage extends StatefulWidget {
  const DnsPage({super.key});

  @override
  DnsPageState createState() => DnsPageState();
}

class DnsPageState extends State<DnsPage> {
  final _dnsController = TextEditingController();
  final _queryController = TextEditingController();
  List<String> lookupResults = [];

  Future<void> performDNSLookup() async {
    final dnsolve = DNSolve();
    final host = _queryController.text;
    final results = <String>[];

    final response =
        await dnsolve.lookup(host, dnsSec: true, type: RecordType.any);

    if (response.answer!.records != null) {
      results.addAll(response.answer!.records!.map((record) => record.toBind));
    }

    setState(() {
      lookupResults = results;
    });
  }

  void sortRecordsByType() {
    final recordGroups = <String, List<String>>{};
    final sortedRecords = <String>[];
    const sortedTypes = RecordType.values;

    for (final record in lookupResults) {
      final parts = record.split(RegExp(r'^\\s+$'));
      if (parts.length >= 4) {
        final type = parts[3];
        recordGroups.putIfAbsent(type, () => []).add(record);
      }
    }

    for (final type in sortedTypes) {
      if (recordGroups.containsKey(type)) {
        sortedRecords.addAll(recordGroups[type]!);
      }
    }

    setState(() {
      lookupResults = sortedRecords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _queryController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter domain',
                      hintText: 'domain.tld',
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    performDNSLookup();
                    sortRecordsByType();
                  },
                  icon: const Icon(Icons.search),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.red,
                      ),
                      padding: const MaterialStatePropertyAll(
                        EdgeInsets.all(16.0),
                      )),
                ),
              ),
            ],
          ),
          if (lookupResults.isNotEmpty)
            Expanded(
                child: Column(children: [
              TextField(
                controller: _dnsController,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: lookupResults.length,
                  itemBuilder: (context, index) {
                    return Text(lookupResults[index]);
                  },
                ),
              ),
            ])),
        ],
      ),
    );
  }
}
