/// Reusable model for simple message-based responses.
class MessageResponseModel {
  final String message;

  const MessageResponseModel({required this.message});

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) {
    return MessageResponseModel(
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'message': message};
}
