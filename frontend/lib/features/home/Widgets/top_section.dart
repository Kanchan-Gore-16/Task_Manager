import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../task_provider.dart';
import '../task_filter_provider.dart';

class TopSection extends ConsumerWidget {
  const TopSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final filters = ref.watch(taskFilterProvider);

    if (taskState.loading && taskState.summary.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final summary = taskState.summary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // 🔹 STATUS CARDS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatusCard(
                status: "Pending",
                count: summary['pending'] ?? 0,
                color: const Color(0xFFe76f51),
                isSelected: filters.status == 'pending',
                onTap: () {
                  ref
                      .read(taskFilterProvider.notifier)
                      .setStatus(
                        filters.status == 'pending' ? 'All' : 'pending',
                      );
                  ref
                      .read(taskProvider.notifier)
                      .fetchTasks(includeSummary: true);
                  ref.read(taskProvider.notifier).resetPagination();
                },
              ),
              StatusCard(
                status: "In Progress",
                count: summary['in_progress'] ?? 0,
                color: const Color(0xFFe9c46a),
                isSelected: filters.status == 'in_progress',
                onTap: () {
                  ref
                      .read(taskFilterProvider.notifier)
                      .setStatus(
                        filters.status == 'in_progress' ? 'All' : 'in_progress',
                      );
                  ref
                      .read(taskProvider.notifier)
                      .fetchTasks(includeSummary: true);
                  ref.read(taskProvider.notifier).resetPagination();
                },
              ),
              StatusCard(
                status: "Completed",
                count: summary['completed'] ?? 0,
                color: const Color(0xFF76c893),
                isSelected: filters.status == 'completed',
                onTap: () {
                  ref
                      .read(taskFilterProvider.notifier)
                      .setStatus(
                        filters.status == 'completed' ? 'All' : 'completed',
                      );
                  ref
                      .read(taskProvider.notifier)
                      .fetchTasks(includeSummary: true);
                  ref.read(taskProvider.notifier).resetPagination();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              SizedBox(width: 160, child: CategoryDropdown()),
              SizedBox(width: 160, child: PriorityDropdown()),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryDropdown extends ConsumerWidget {
  const CategoryDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);
    final filters = ref.watch(taskFilterProvider);

    return DropdownMenu<String>(
      label: Text("Category", style: TextStyle(color: Colors.grey.shade700)),
      initialSelection: filters.category,
      onSelected: (value) {
        if (value == null) return;
        ref.read(taskFilterProvider.notifier).setCategory(value);
        ref.read(taskProvider.notifier).fetchTasks(includeSummary: true);
        ref.read(taskProvider.notifier).resetPagination();
      },
      dropdownMenuEntries: categories
          .map((c) => DropdownMenuEntry(value: c, label: c))
          .toList(),
    );
  }
}

class PriorityDropdown extends ConsumerWidget {
  const PriorityDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorities = ref.watch(priorityProvider);
    final filters = ref.watch(taskFilterProvider);

    return DropdownMenu<String>(
      label: Text("Priority", style: TextStyle(color: Colors.grey.shade700)),
      initialSelection: filters.priority,
      onSelected: (value) {
        if (value == null) return;
        ref.read(taskFilterProvider.notifier).setPriority(value);
        ref.read(taskProvider.notifier).fetchTasks(includeSummary: true);
      },
      dropdownMenuEntries: priorities
          .map((p) => DropdownMenuEntry(value: p, label: p))
          .toList(),
    );
  }
}

class StatusCard extends StatelessWidget {
  final String status;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const StatusCard({
    super.key,
    required this.status,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 90,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Card(
          color: isSelected ? color : color.withOpacity(0.6),
          elevation: isSelected ? 6 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                status,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
