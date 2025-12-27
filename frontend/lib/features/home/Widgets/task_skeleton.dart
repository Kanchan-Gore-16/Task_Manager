import 'package:flutter/material.dart';

class TaskSkeleton extends StatelessWidget {
  const TaskSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(width: 180, height: 16),
            const SizedBox(height: 8),
            _bar(width: double.infinity, height: 12),
            const SizedBox(height: 6),
            _bar(width: double.infinity, height: 12),
            const SizedBox(height: 12),
            Row(
              children: [
                _bar(width: 70, height: 20, radius: 10),
                const SizedBox(width: 8),
                _bar(width: 60, height: 20, radius: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar({
    required double width,
    required double height,
    double radius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
