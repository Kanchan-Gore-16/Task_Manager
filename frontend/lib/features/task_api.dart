import 'package:dio/dio.dart';

// Handles all task-related API requests
class TaskApi {
  final Dio dio;

  TaskApi(this.dio);

  // Fetch tasks with filters, pagination, and optional summary
  Future<Map<String, dynamic>> fetchTasks({
    String? status,
    String? category,
    String? priority,
    String? search,
    bool includeSummary = true,
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await dio.get(
      '/api/tasks',
      queryParameters: {
        'status': status,
        'category': category,
        'priority': priority,
        'search': search,
        'includeSummary': includeSummary,
        'limit': limit,
        'offset': offset,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  Future<void> createTask({
    required String title,
    required String description,
    String? assignedTo,
    String? dueDate,
  }) async {
    final payload = {
      "title": title,
      "description": description,
      if (assignedTo != null && assignedTo.isNotEmpty)
        "assigned_to": assignedTo,
      if (dueDate != null) "due_date": dueDate,
    };

    await dio.post('/api/tasks', data: payload);
  }

  Future<void> updateTask({required String id, required payload}) async {
    await dio.patch('/api/tasks/$id', data: payload);
  }

  Future<void> deleteTask(String id) async {
    await dio.delete('/api/tasks/$id');
  }
}
