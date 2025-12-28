import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_task_manager/features/task_api.dart';
import 'package:smart_task_manager/features/task_api_provider.dart';
import 'package:smart_task_manager/features/task_model.dart';

import 'cors/connectivity_provider.dart';
import 'task_filter_provider.dart';

// Holds task list data, pagination info, loading & error states
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

// Global provider managing task list, filters, pagination and API calls
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
  // Next page
  void nextPage() {
    if (state.loading || !state.hasMore) return;

    fetchTasks(
      includeSummary: false,
      offsetOverride: state.offset + state.limit,
    );
  }

  // Previous page
  void previousPage() {
    if (state.loading || state.offset == 0) return;

    fetchTasks(
      includeSummary: false,
      offsetOverride: (state.offset - state.limit).clamp(0, state.offset),
    );
  }

  // Reset pagination
  void resetPagination() {
    fetchTasks(includeSummary: true, offsetOverride: 0);
  }

  // Fetch tasks from API with filters, pagination and optional summary
  Future<void> fetchTasks({
    bool includeSummary = true,
    int? offsetOverride,
  }) async {
    // Slip API call when device is offline
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      state = state.copyWith(loading: false, error: null);
      return;
    }

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
    } on DioException catch (_) {
      state = state.copyWith(loading: false, error: null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // Create a new task and refresh list
  Future<void> createTask({
    required String title,
    required String description,
    String? assignedTo,
    String? dueDate,
  }) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) return;

    await api.createTask(
      title: title,
      description: description,
      assignedTo: assignedTo,
      dueDate: dueDate,
    );

    await fetchTasks();
  }

  // Update existing task details
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

  // Delete task and reset pagination
  Future<void> deleteTask(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) return;
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
