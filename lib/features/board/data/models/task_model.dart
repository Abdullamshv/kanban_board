import 'package:flutter/foundation.dart';

@immutable
class TaskModel {
  final int indicatorToMoId;
  final int parentId;
  final String name;
  final String parentName;
  final int order;

  const TaskModel({
    required this.indicatorToMoId,
    required this.parentId,
    required this.name,
    this.parentName = '',
    required this.order,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      indicatorToMoId: (json['indicator_to_mo_id'] ?? 0) as int,
      parentId: (json['parent_id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      parentName: (json['parent_name'] ?? '') as String,
      order: (json['order'] ?? 0) as int,
    );
  }

  TaskModel copyWith({
    int? indicatorToMoId,
    int? parentId,
    String? name,
    String? parentName,
    int? order,
  }) {
    return TaskModel(
      indicatorToMoId: indicatorToMoId ?? this.indicatorToMoId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      parentName: parentName ?? this.parentName,
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.indicatorToMoId == indicatorToMoId &&
        other.parentId == parentId &&
        other.name == name &&
        other.parentName == parentName &&
        other.order == order;
  }

  @override
  int get hashCode {
    return indicatorToMoId.hashCode ^
        parentId.hashCode ^
        name.hashCode ^
        parentName.hashCode ^
        order.hashCode;
  }
}
