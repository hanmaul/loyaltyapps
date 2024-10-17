part of 'content_bloc.dart';

@immutable
sealed class ContentEvent {}

class LoadEvent extends ContentEvent {}

class RefreshEvent extends ContentEvent {}
