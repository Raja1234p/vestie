class ApiErrorResponseModel {
  final int status;
  final String title;
  final String? detail;
  final Map<String, List<String>>? errors;

  ApiErrorResponseModel({
    required this.status,
    required this.title,
    this.detail,
    this.errors,
  });

  factory ApiErrorResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>>? parsedErrors;
    if (json['errors'] != null && json['errors'] is Map) {
      parsedErrors = {};
      (json['errors'] as Map).forEach((key, value) {
        if (value is List) {
          parsedErrors![key.toString()] = value.map((e) => e.toString()).toList();
        }
      });
    }

    return ApiErrorResponseModel(
      status: json['status'] as int? ?? 400,
      title: json['title'] as String? ?? 'Error',
      detail: json['detail'] as String?,
      errors: parsedErrors,
    );
  }
}
