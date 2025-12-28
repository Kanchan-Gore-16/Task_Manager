import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/task_api.dart';

import 'cors/dio_provider.dart';

// Provides TaskApi instance with injected Dio client
final taskApiProvider = Provider<TaskApi>((ref) {
  final dio = ref.watch(dioProvider);
  return TaskApi(dio);
});
