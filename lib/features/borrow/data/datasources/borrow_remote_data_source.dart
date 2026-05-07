import '../models/borrow_request_model.dart';

class CreateBorrowRequestBody {
  final double requestedAmount;
  final String reason;

  const CreateBorrowRequestBody({
    required this.requestedAmount,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'requestedAmount': requestedAmount,
        'reason': reason,
      };
}

abstract class BorrowRemoteDataSource {
  Future<BorrowRequestModel> createBorrowRequest({
    required String projectId,
    required CreateBorrowRequestBody body,
  });
}

