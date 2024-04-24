part of 'content_bloc.dart';

@immutable
sealed class ContentEvent {}

class LoadEvent extends ContentEvent {}

class LoadAkun extends ContentEvent {}

class PullToRefreshEvent extends ContentEvent {}
