import 'package:equatable/equatable.dart';

class VffPendingState extends Equatable {
  final bool hasPending;

  const VffPendingState({this.hasPending = false});

  VffPendingState copyWith({bool? hasPending}) =>
      VffPendingState(hasPending: hasPending ?? this.hasPending);

  @override
  List<Object?> get props => [hasPending];
}
