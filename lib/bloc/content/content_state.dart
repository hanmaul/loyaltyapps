part of 'content_bloc.dart';

@immutable
sealed class ContentState {}

final class ContentInitial extends ContentState {}

final class LoadingState extends ContentState {}

final class LoadedState extends ContentState {
  final List<Banner> banner;
  final List<Highlight> highlight;
  final List<Service> service;
  final List<Promo> promo;
  final String? messageError;

  LoadedState({
    required this.banner,
    required this.highlight,
    required this.service,
    required this.promo,
    this.messageError,
  });
}

final class FailureLoadState extends ContentState {
  final String message;

  FailureLoadState({
    required this.message,
  });
}
