import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class HomeFetchStarted extends HomeEvent {
  const HomeFetchStarted();
  @override List<Object> get props => [];
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
  @override List<Object> get props => [];
}
