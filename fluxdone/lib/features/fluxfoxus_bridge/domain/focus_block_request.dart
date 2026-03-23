import 'package:freezed_annotation/freezed_annotation.dart';

part 'focus_block_request.freezed.dart';
part 'focus_block_request.g.dart';

@freezed
class FocusBlockRequest with _$FocusBlockRequest {
  const factory FocusBlockRequest({
    required String taskId,
    required String taskName,
    @JsonKey(name: 'startTime') required DateTime? startTime,
    @JsonKey(name: 'endTime') required DateTime? endTime,
    required int duration,
    required String listId,
    required String? sectionId,
    required String action, // 'create', 'update', 'delete'
  }) = _FocusBlockRequest;

  factory FocusBlockRequest.fromJson(Map<String, dynamic> json) =>
      _$FocusBlockRequestFromJson(json);
}
