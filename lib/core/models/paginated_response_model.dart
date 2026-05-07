import 'package:equatable/equatable.dart';

class PaginatedResponseModel<T> extends Equatable {
  final List<T> data;
  final int totalRecords;
  final int totalPages;
  final int currentPage;

  const PaginatedResponseModel({
    required this.data,
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginatedResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginatedResponseModel(
      data: (json['data'] as List<dynamic>?)?.map(fromJsonT).toList() ?? [],
      totalRecords: json['totalRecords'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [data, totalRecords, totalPages, currentPage];
}
