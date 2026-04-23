import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../models/task_model.dart';

class KanbanRepository {
  final Dio _dio;

  KanbanRepository(this._dio);

  Future<Either<String, List<TaskModel>>> fetchTasks() async {
    try {
      final formData = FormData.fromMap({
        'period_start': '2026-04-01',
        'period_end': '2026-04-30',
        'period_key': 'month',
        'requested_mo_id': '42',
        'behaviour_key': 'task,kpi_task',
        'with_result': 'false',
        'response_fields': 'name,indicator_to_mo_id,parent_id,parent_name,order',
        'auth_user_id': '40',
      });

      final response = await _dio.post(
        'https://api.dev.kpi-drive.ru/_api/indicators/get_mo_indicators',
        data: formData,
      );

      final responseData = response.data;
      if (responseData == null || responseData['STATUS'] != 'OK') {
        return Left(
          responseData?['MESSAGES']?['error'] ?? 'Unknown network error',
        );
      }

      final rows = responseData['DATA']?['rows'] as List?;
      if (rows == null) return const Right([]);

      final tasks = rows
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();

      tasks.sort((a, b) => a.order.compareTo(b.order));

      return Right(tasks);
    } catch (e) {
      return Left('Failed to fetch tasks: $e');
    }
  }

  Future<Either<String, bool>> updateTaskField({
    required int taskId,
    required String fieldName,
    required int fieldValue,
  }) async {
    try {
      final formData = FormData.fromMap({
        'period_start': '2026-04-01', 
        'period_end': '2026-04-30',  
        'period_key': 'month',
        'indicator_to_mo_id': taskId.toString(),
        'field_name': fieldName,
        'field_value': fieldValue.toString(),
        'auth_user_id': '40',
      });

      final response = await _dio.post(
        'https://api.dev.kpi-drive.ru/_api/indicators/save_indicator_instance_field',
        data: formData,
      );

      final responseData = response.data;
      debugPrint('UPDATE RESPONSE [$fieldName=$fieldValue]: $responseData'); 
      
      if (responseData == null || responseData['STATUS'] != 'OK') {
        return Left(
          responseData?['MESSAGES']?['error'] ?? 'Unknown error updating server',
        );
      }

      return const Right(true);
    } catch (e) {
      debugPrint('UPDATE ERROR: $e');
      return Left('Network Error: Failed to update task');
    }
  }
}