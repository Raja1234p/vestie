import 'package:vestie/core/models/pagination_dto.dart';

import '../models/borrow_repay_models.dart';
import '../models/borrow_request_list_item_model.dart';
import '../models/borrow_request_model.dart';
import '../models/borrow_terms_model.dart';
import '../models/my_borrow_screen_model.dart';
import '../models/borrow_vote_result_model.dart';

class CreateBorrowRequestBody {
  final double requestedAmount;
  final String reason;
  final bool agreedToTerms;

  const CreateBorrowRequestBody({
    required this.requestedAmount,
    required this.reason,
    this.agreedToTerms = true,
  });

  Map<String, dynamic> toJson() => {
    'requestedAmount': requestedAmount,
    'reason': reason,
    'agreedToTerms': agreedToTerms,
  };
}

abstract class BorrowRemoteDataSource {
  Future<BorrowTermsModel> getBorrowTerms({
    required String projectId,
    required double amount,
  });

  Future<PaginatedListModel<BorrowRequestListItemModel>> listBorrowRequests({
    required String projectId,
    String? status,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });

  Future<BorrowVoteResultModel> voteBorrowRequest({
    required String projectId,
    required String borrowRequestId,
    required String vote,
  });

  Future<BorrowRequestModel> createBorrowRequest({
    required String projectId,
    required CreateBorrowRequestBody body,
    required String idempotencyKey,
  });

  Future<void> decideBorrowRequest({
    required String projectId,
    required String borrowRequestId,
    required String decision,
  });

  Future<MyBorrowScreenModel> getMyBorrowScreen({
    required String projectId,
    int historyPage = PaginationQuery.defaultPage,
    int? historyPageSize,
  });

  Future<void> cancelBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  });

  Future<PaginatedListModel<MyBorrowCurrentRequestModel>> listMyBorrowRequests({
    required String projectId,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });

  Future<BorrowRepaySummaryModel> getBorrowRepaySummary({
    required String projectId,
    required String borrowRequestId,
  });

  Future<BorrowRepayPaymentOptionsModel> getBorrowRepayPaymentOptions({
    required String projectId,
    required String borrowRequestId,
  });

  Future<BorrowRepayPreviewModel> getBorrowRepayPreview({
    required String projectId,
    required String borrowRequestId,
    required String paymentSourceType,
    String? paymentMethodId,
  });

  Future<BorrowRepaymentResultModel> submitBorrowRepayment({
    required String projectId,
    required String borrowRequestId,
    required String paymentSourceType,
    String? paymentMethodId,
    required String idempotencyKey,
  });
}

class SubmitBorrowRepaymentBody {
  final String paymentSourceType;
  final String? paymentMethodId;
  final String idempotencyKey;

  const SubmitBorrowRepaymentBody({
    required this.paymentSourceType,
    this.paymentMethodId,
    required this.idempotencyKey,
  });

  Map<String, dynamic> toJson() => {
    'paymentSourceType': paymentSourceType,
    if (paymentMethodId != null && paymentMethodId!.isNotEmpty)
      'paymentMethodId': paymentMethodId,
    'idempotencyKey': idempotencyKey,
  };
}
