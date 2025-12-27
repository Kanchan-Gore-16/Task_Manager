import 'package:flutter/material.dart';

import 'Widgets/bottom_section.dart';
import 'Widgets/middle_section.dart';
import 'Widgets/top_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Color(0xFF0096c7),
        title: const Text(
          "Task Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TopSection(),
            const Expanded(child: MiddleSection()),

            // _buildButtomSection(),
            // Middle & Bottom sections will come later
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF0096c7),
          child: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => const TaskFormBottomSheet(),
            );
          },
        ),
      ),
    );
  }
}
