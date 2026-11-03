class ApiException implements Exception {
  final String message;
  final int? statusCode;

  final String? code;

  final Map<String, List<String>> errors;

  ApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.errors = const {},
  });

  factory ApiException.fromResponse(int statusCode, dynamic body) {
    final Map<String, dynamic>? error =
        body is Map<String, dynamic> && body['error'] is Map<String, dynamic>
        ? body['error']
        : null;

    final Map<String, List<String>> errors = {};
    final details = error?['details'];
    if (details is Map) {
      details.forEach((field, messages) {
        if (messages is List && messages.isNotEmpty) {
          errors[field.toString()] = messages.map((m) => m.toString()).toList();
        }
      });
    }

    return ApiException(
      error?['message']?.toString() ?? 'حدث خطأ غير متوقع ($statusCode)',
      statusCode: statusCode,
      code: error?['code']?.toString(),
      errors: errors,
    );
  }

  String get displayMessage => errors.isEmpty
      ? message
      : errors.values.map((messages) => messages.first).join('\n');

  @override
  String toString() => displayMessage;
}
