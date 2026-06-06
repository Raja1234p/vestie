import 'package:equatable/equatable.dart';

/// Inbox row kinds that share accept / decline actions.
enum UserVffInboxItemKind { vffRequest, projectInvite }

/// Which inbox row button is in flight (per-card loader).
final class UserVffInboxRowAction extends Equatable {
  final String itemId;
  final UserVffInboxItemKind kind;
  final bool isAccept;

  const UserVffInboxRowAction({
    required this.itemId,
    required this.kind,
    required this.isAccept,
  });

  @override
  List<Object?> get props => [itemId, kind, isAccept];
}

extension UserVffInboxRowActionX on UserVffInboxRowAction? {
  bool primaryLoading(String itemId, UserVffInboxItemKind kind) =>
      this != null &&
      this!.itemId == itemId &&
      this!.kind == kind &&
      this!.isAccept;

  bool declineLoading(String itemId, UserVffInboxItemKind kind) =>
      this != null &&
      this!.itemId == itemId &&
      this!.kind == kind &&
      !this!.isAccept;

  bool blocksRow(String itemId, UserVffInboxItemKind kind) =>
      this != null && this!.itemId == itemId && this!.kind == kind;
}
