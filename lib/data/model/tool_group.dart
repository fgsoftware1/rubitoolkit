import 'package:flutter/material.dart';

/// Represents a group of tools in the application
class ToolGroup {
  final String name;
  final IconData icon;
  final IconData selectedIcon;
  final List<Tool> tools;

  const ToolGroup({
    required this.name,
    required this.icon,
    required this.selectedIcon,
    required this.tools,
  });
}

/// Represents an individual tool in the application
class Tool {
  final String name;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;

  const Tool({
    required this.name,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });
}