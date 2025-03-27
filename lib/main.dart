import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'data/model/tool_group.dart';
import 'data/provider/ShodanAPI_new.dart';
import 'dns_page.dart';
import 'ping_page_new.dart';
import 'social_username_page.dart';
import 'whois_page.dart';
import 'widgets/ip_info_display.dart';
import 'widgets/welcome_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupWindow();
  runApp(const RubiToolkitApp());
}

class RubiToolkitApp extends StatelessWidget {
  const RubiToolkitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RubiToolkit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blueAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: Colors.grey.shade50,
          selectedIconTheme: const IconThemeData(color: Colors.blueAccent),
          selectedLabelTextStyle: const TextStyle(color: Colors.blueAccent),
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

const double windowWidth = 1024;
const double windowHeight = 800;

void setupWindow() {
  setWindowTitle('Rubitoolkit');
  setWindowMinSize(const Size(windowWidth, windowHeight));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Selected indices for navigation
  // Start with -1 to show welcome page
  int selectedGroupIndex = -1;
  int selectedToolIndex = 0;

  // Define all tool groups with their tools
  final List<ToolGroup> toolGroups = [
    // Network Utilities Group
    ToolGroup(
      name: 'Network Utilities',
      icon: Icons.lan_outlined,
      selectedIcon: Icons.lan,
      tools: [
        Tool(
          name: 'My IP',
          icon: Symbols.bring_your_own_ip,
          selectedIcon: Symbols.bring_your_own_ip,
          page: IPInfoWidget(shodanAPI: ShodanAPI()),
        ),
        const Tool(
          name: 'DNS Lookup',
          icon: Icons.dns_outlined,
          selectedIcon: Icons.dns,
          page: DnsPage(),
        ),
        const Tool(
          name: 'Ping',
          icon: Icons.network_ping_outlined,
          selectedIcon: Icons.network_ping,
          page: PingPage(),
        ),
      ],
    ),

    // OSINT Tools Group
    const ToolGroup(
      name: 'OSINT Tools',
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
      tools: [
        Tool(
          name: 'Whois Lookup',
          icon: Icons.person_search_outlined,
          selectedIcon: Icons.person_search,
          page: WhoisPage(),
        ),
        Tool(
          name: 'Social Username Lookup',
          icon: Icons.people_outlined,
          selectedIcon: Icons.people,
          page: SocialUsernamePage(),
        ),
        Tool(
          name: 'Domain Info',
          icon: Icons.domain_outlined,
          selectedIcon: Icons.domain,
          page: Center(child: Text('Domain Information Tool')),
        ),
      ],
    ),

    // Security Tools Group
    const ToolGroup(
      name: 'Security Tools',
      icon: Icons.security_outlined,
      selectedIcon: Icons.security,
      tools: [
        Tool(
          name: 'Port Scanner',
          icon: Icons.radar_outlined,
          selectedIcon: Icons.radar,
          page: Center(child: Text('Port Scanner Tool')),
        ),
        Tool(
          name: 'Hash Calculator',
          icon: Icons.tag_outlined,
          selectedIcon: Icons.tag,
          page: Center(child: Text('Hash Calculator Tool')),
        ),
      ],
    ),

    // Utilities Group
    const ToolGroup(
      name: 'Utilities',
      icon: Icons.build_outlined,
      selectedIcon: Icons.build,
      tools: [
        Tool(
          name: 'Text Encoder/Decoder',
          icon: Icons.code_outlined,
          selectedIcon: Icons.code,
          page: Center(child: Text('Text Encoder/Decoder Tool')),
        ),
        Tool(
          name: 'JSON Formatter',
          icon: Icons.data_object_outlined,
          selectedIcon: Icons.data_object,
          page: Center(child: Text('JSON Formatter Tool')),
        ),
      ],
    ),
  ];

  // Generate navigation destinations for groups
  List<NavigationRailDestination> get groupDestinations {
    return toolGroups
        .map((group) => NavigationRailDestination(
              icon: Icon(group.icon),
              selectedIcon: Icon(group.selectedIcon),
              label: Text(group.name),
            ))
        .toList();
  }

  // Generate navigation destinations for tools in the selected group
  List<NavigationRailDestination> get toolDestinations {
    if (selectedGroupIndex >= 0 && selectedGroupIndex < toolGroups.length) {
      return toolGroups[selectedGroupIndex]
          .tools
          .map((tool) => NavigationRailDestination(
                icon: Icon(tool.icon),
                selectedIcon: Icon(tool.selectedIcon),
                label: Text(tool.name),
              ))
          .toList();
    }
    return [];
  }

  // Get the currently selected tool's page
  Widget get currentPage {
    // Show welcome page if no tool is selected yet
    if (selectedGroupIndex == -1) {
      return const WelcomePage();
    }

    // Show the selected tool
    if (selectedGroupIndex >= 0 && selectedGroupIndex < toolGroups.length) {
      final tools = toolGroups[selectedGroupIndex].tools;
      if (selectedToolIndex >= 0 && selectedToolIndex < tools.length) {
        return tools[selectedToolIndex].page;
      }
    }

    // Fallback
    return const WelcomePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RubiToolkit'),
        actions: [
          // Add a refresh button for tools that might need it
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              // Force a rebuild of the current page
              setState(() {});
            },
          ),
          // Add a settings button for future implementation
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              // Show a simple dialog for now
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Settings'),
                  content: const Text(
                      'Settings will be implemented in a future update.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // First level navigation - Tool Groups
          NavigationRail(
            selectedIndex: selectedGroupIndex >= 0 ? selectedGroupIndex : null,
            onDestinationSelected: (int index) {
              setState(() {
                selectedGroupIndex = index;
                selectedToolIndex =
                    0; // Reset tool selection when changing groups
              });
            },
            leading: IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Home',
              onPressed: () {
                setState(() {
                  selectedGroupIndex = -1; // Show welcome page
                });
              },
            ),
            labelType: NavigationRailLabelType.selected,
            destinations: groupDestinations,
          ),

          // Only show second navigation and divider when a group is selected
          if (selectedGroupIndex >= 0) ...[
            // Divider between navigation levels
            const VerticalDivider(thickness: 1, width: 1),

            // Second level navigation - Tools within the selected group
            NavigationRail(
              selectedIndex: selectedToolIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  selectedToolIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: toolDestinations,
            ),
          ],

          // Divider between navigation and content
          const VerticalDivider(thickness: 1, width: 1),

          // Content area - Display the selected tool
          Expanded(
            child: currentPage,
          ),
        ],
      ),
    );
  }
}
