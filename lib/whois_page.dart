import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:whois/whois.dart';

class WhoisPage extends StatefulWidget {
  const WhoisPage({super.key});

  @override
  WhoisStatePage createState() => WhoisStatePage();
}

class WhoisStatePage extends State<WhoisPage> {
  final TextEditingController queryController = TextEditingController();
  String lookupResult = '';

  Future<void> search() async {
    var options = const LookupOptions(
      // Set timeout to 10 seconds
      timeout: Duration(milliseconds: 10000),

      // Set the whois port, default is 43
      port: 43,
    );

    final response = await Whois.lookup(
      queryController.text,
      options,
    );

    if (kDebugMode) {
      print(response.toString());
    }

    setState(() {
      lookupResult = response.toString();
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
                    search();
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
          Expanded(
            child: Text(
              lookupResult,
            ),
          ),
        ],
      ),
    );
  }
}
