import 'package:equatable/equatable.dart';

abstract class BrowseEvent extends Equatable {
  const BrowseEvent();

  @override
  List<Object?> get props => [];
}

class LoadBrowseData extends BrowseEvent {}

class SelectGenreEvent extends BrowseEvent {
  final String genre;

  const SelectGenreEvent(this.genre);

  @override
  List<Object?> get props => [genre];
}
