import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_task_manager/features/task_api.dart';
import 'package:smart_task_manager/features/task_api_provider.dart';
import 'package:smart_task_manager/features/task_model.dart';

import 'home/task_filter_provider.dart';

class TaskState {
  final List<Task> tasks;
  final Map<String, int> summary;
  final bool loading;
  final String? error;

  final int limit;
  final int offset;
  final bool hasMore;

  const TaskState({
    this.tasks = const [],
    this.summary = const {},
    this.loading = false,
    this.error,
    this.limit = 10,
    this.offset = 0,
    this.hasMore = false,
  });

  TaskState copyWith({
    List<Task>? tasks,
    Map<String, int>? summary,
    bool? loading,
    String? error,
    int? limit,
    int? offset,
    bool? hasMore,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      summary: summary ?? this.summary,
      loading: loading ?? this.loading,
      error: error,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  final api = ref.watch(taskApiProvider);
  return TaskNotifier(ref, api);
});

class TaskNotifier extends StateNotifier<TaskState> {
  final Ref ref;
  final TaskApi api;

  TaskNotifier(this.ref, this.api) : super(const TaskState()) {
    fetchTasks();
  }

  void nextPage() {
    if (state.loading || !state.hasMore) return;

    fetchTasks(
      includeSummary: false,
      offsetOverride: state.offset + state.limit,
    );
  }

  // ---------------- PREVIOUS PAGE ----------------
  void previousPage() {
    if (state.loading || state.offset == 0) return;

    fetchTasks(
      includeSummary: false,
      offsetOverride: (state.offset - state.limit).clamp(0, state.offset),
    );
  }

  // ---------------- RESET PAGINATION ----------------
  void resetPagination() {
    fetchTasks(includeSummary: true, offsetOverride: 0);
  }

  Future<void> fetchTasks({
    bool includeSummary = true,
    int? offsetOverride,
  }) async {
    try {
      state = state.copyWith(loading: true, error: null);

      final filters = ref.read(taskFilterProvider);

      final offset = offsetOverride ?? state.offset;

      final response = await api.fetchTasks(
        status: filters.status == 'All' ? null : filters.status,
        category: filters.category == 'All' ? null : filters.category,
        priority: filters.priority == 'All' ? null : filters.priority,
        search: filters.search,
        includeSummary: includeSummary,
        limit: state.limit,
        offset: offset,
      );

      final tasks = (response['data'] as List)
          .map((e) => Task.fromJson(e))
          .toList();

      final meta = response['meta'] ?? {};
      final summary = Map<String, int>.from(response['summary'] ?? {});
      print(summary);

      state = state.copyWith(
        tasks: tasks,
        summary: summary,
        offset: offset,
        hasMore: meta['hasMore'] == true,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> createTask({
    required String title,
    required String description,
    String? assignedTo,
    String? dueDate,
  }) async {
    await api.createTask(
      title: title,
      description: description,
      assignedTo: assignedTo,
      dueDate: dueDate,
    );

    await fetchTasks();
  }

  Future<void> editTask({
    required String id,
    required String title,
    required String description,
    required String category,
    required String priority,
    required String status,
    String? assignedTo,
    String? dueDate,
  }) async {
    await api.updateTask(
      id: id,
      payload: {
        "title": title,
        "description": description,
        "category": category,
        "priority": priority,
        "status": status,
        if (assignedTo != null) "assigned_to": assignedTo,
        "due_date": dueDate,
      },
    );

    fetchTasks();
  }

  Future<void> deleteTask(String id) async {
    try {
      state = state.copyWith(loading: true);

      await api.deleteTask(id);

      resetPagination();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> refresh() async {
    await fetchTasks();
  }
}
