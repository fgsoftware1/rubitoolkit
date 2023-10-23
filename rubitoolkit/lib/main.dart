import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'dns_page.dart';
import 'ping_page.dart';
import 'whois_page.dart';

void main() {
  setupWindow();
  runApp(
    const MaterialApp(
      home: HomePage(),
    ),
  );
}

const double windowWidth = 1024;
const double windowHeight = 800;

void setupWindow() {
  setWindowTitle('Rubitoolkit');

  WidgetsFlutterBinding.ensureInitialized();
  setWindowMinSize(const Size(windowWidth, windowHeight));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('RubiToolkit'),
            backgroundColor: Colors.blueAccent,
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.dns, color: Colors.pink),
                  text: 'DNSLookup',
                ),
                Tab(
                  icon: Icon(Icons.person_search, color: Colors.green),
                  text: 'Whois',
                ),
                Tab(
                  icon: Icon(Icons.network_ping, color: Colors.amber),
                  text: 'Ping',
                )
              ],
            ),
          ),
          body: const TabBarView(
            children: [DnsPage(), WhoisPage(), PingPage()],
          ),
        ),
      ),
    );
  }
}
