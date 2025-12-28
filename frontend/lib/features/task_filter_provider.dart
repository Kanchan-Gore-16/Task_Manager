import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

const List<String> categoryList = [
  'All',
  'Scheduling',
  'Finance',
  'Technical',
  'Safety',
  'General',
];

const List<String> priorityList = ['All', 'High', 'Medium', 'Low'];

const List<String> statusList = ['All', 'pending', 'in_progress', 'completed'];

class TaskFilterState {
  final String category;
  final String priority;
  final String status;
  final String? search;

  const TaskFilterState({
    this.category = 'All',
    this.priority = 'All',
    this.status = 'All',
    this.search,
  });

  TaskFilterState copyWith({
    String? category,
    String? priority,
    String? status,
    String? search,
  }) {
    return TaskFilterState(
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      search: search,
    );
  }
}

// Provider managing task filter state
final taskFilterProvider =
    StateNotifierProvider<TaskFilterNotifier, TaskFilterState>((ref) {
      return TaskFilterNotifier();
    });

class TaskFilterNotifier extends StateNotifier<TaskFilterState> {
  TaskFilterNotifier() : super(const TaskFilterState());

  void setCategory(String value) {
    state = state.copyWith(category: value);
  }

  void setPriority(String value) {
    state = state.copyWith(priority: value);
  }

  void setStatus(String value) {
    state = state.copyWith(status: value);
  }

  void setSearch(String? value) {
    state = state.copyWith(search: value);
  }

  void reset() {
    state = const TaskFilterState();
  }
}

// Providers exposing filter options to UI
final categoryProvider = Provider<List<String>>((ref) => categoryList);
final priorityProvider = Provider<List<String>>((ref) => priorityList);
final statusProvider = Provider<List<String>>((ref) => statusList);
