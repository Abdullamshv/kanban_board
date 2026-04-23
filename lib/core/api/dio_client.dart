import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/board/data/repositories/kanban_repo.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers['Authorization'] = 'Bearer 5c3964b8e3ee4755f2cc0febb851e2f8';
      return handler.next(options);
    },
  ));
  
  return dio;
});

final kanbanRepositoryProvider = Provider<KanbanRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return KanbanRepository(dio);
});
