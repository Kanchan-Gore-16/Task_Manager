import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cors/connectivity_provider.dart';
import '../cors/offline_banner.dart';
import 'Widgets/bottom_section.dart';
import 'Widgets/middle_section.dart';
import 'Widgets/top_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<bool>(isOfflineProvider, (prev, next) {
      if (prev == false && next == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You're offline"),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (prev == true && next == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Back online"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

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
            OfflineBanner(),
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
