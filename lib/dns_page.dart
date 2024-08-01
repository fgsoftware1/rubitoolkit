import 'package:dnsolve/dnsolve.dart';
import 'package:flutter/foundation.dart';
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

    if (response.answer != null && response.answer!.records != null) {
      results.addAll(response.answer!.records!.map((record) => record.toBind));
      if (kDebugMode) {
        print(results);
      }
    } else {
      print('No records found in the response');
    }

    results.sort((a, b) {
      final aParts = a.split(RegExp(r'\s+'));
      final bParts = b.split(RegExp(r'\s+'));
      return aParts[3].compareTo(bParts[3]);
    });

    setState(() {
      lookupResults = results;
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
                  },
                  icon: const Icon(Icons.search),
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Colors.red,
                      ),
                      padding: const WidgetStatePropertyAll(
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
