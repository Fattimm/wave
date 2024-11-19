import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final List<Widget> drawerItems;

  CustomDrawer({required this.drawerItems});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: drawerItems,
      ),
    );
  }
}
