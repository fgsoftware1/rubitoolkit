import 'dart:developer';

import 'package:dnsolve/dnsolve.dart';
import 'package:flutter/material.dart';

String selectedSortOption = 'Default';

class DnsPage extends StatefulWidget {
  const DnsPage({super.key});

  @override
  DnsPageState createState() => DnsPageState();
}

class DnsPageState extends State<DnsPage> {
  final TextEditingController queryController = TextEditingController();
  List<String> lookupResults = [];
  List<String> domainList = [];

  Future<void> performDNSLookup() async {
    final dnsolve = DNSolve();
    final results = <String>[];

    for (final domain in domainList) {
      final response = await dnsolve.lookup(
        domain,
        dnsSec: true,
        type: RecordType.any,
      );

      if (response.answer!.records != null) {
        for (final record in response.answer!.records!) {
          log(record.toBind);
          results.add(record.toBind);
        }
      }
    }

    setState(() {
      lookupResults = results;
    });
  }

  void extractDomainsFromText() {
    final text = queryController.text;
    final domains = text.split(',');
    domainList = domains
        .map((domain) => domain.trim())
        .where((domain) => domain.isNotEmpty)
        .toList();
  }

  void sortRecordsByType() {
    final Map<String, List<String>> recordGroups = {};

    for (final record in lookupResults) {
      final parts = record.split(' ');
      if (parts.length >= 4) {
        final type = parts[3];
        recordGroups.putIfAbsent(type, () => []);
        recordGroups[type]!.add(record);
      }
    }

    final sortedRecords = <String>[];
    final sortedTypes = [RecordType.values];

    for (final type in sortedTypes) {
      final records = recordGroups[type];
      if (records != null) {
        records.sort();
        sortedRecords.addAll(records);
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
                    controller: queryController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter domain/domains',
                      hintText: '"domain.tld", "domain.tld, domain2.tld"',
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    extractDomainsFromText();
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
              child: Row(
                children: [
                  SizedBox(
                    width: 256,
                    child: ListView.builder(
                      itemCount: domainList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(domainList[index]),
                        );
                      },
                    ),
                  ),
                  const VerticalDivider(),
                  SizedBox(
                    width: 768,
                    child: Expanded(
                      child: ListView.builder(
                        itemCount: lookupResults.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(lookupResults[index]),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
