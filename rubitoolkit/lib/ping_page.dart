import 'dart:io';

import 'package:flutter/material.dart';

class PingPage extends StatefulWidget {
  const PingPage({super.key});

  @override
  PingStatePage createState() => PingStatePage();
}

class PingStatePage extends State<PingPage> {
  final _hostController = TextEditingController();
  final _hostPing = TextEditingController();
  List<String> pingOutput = [];

  Future<void> _ping() async {
    final host = _hostController.text;
    final results = <String>[];

    _hostPing.text = "Pinging $host";
    var result = await Process.run('ping', ['-n', '5', host]);

    results.addAll(result.stdout.split('\n'));
    setState(() {
      pingOutput = results;
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
                    controller: _hostController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter domain',
                      hintText: '"domain.tld"',
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    _ping();
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
          Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: _hostPing,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pingOutput.length,
                      itemBuilder: (context, index) {
                        return Text(pingOutput[index]);
                      },
                    ),
                  ),
                ]
              )
          ),
        ],
      ),
    );
  }
}
