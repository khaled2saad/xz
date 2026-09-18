import 'package:equatable/equatable.dart';
import '../../../data/models/movie_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileData extends ProfileEvent {}

class SwitchProfileTab extends ProfileEvent {
  final int tabIndex; // 0: Watchlist, 1: History

  const SwitchProfileTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class WatchListUpdated extends ProfileEvent {
  final List<MovieModel> watchList;

  const WatchListUpdated(this.watchList);

  @override
  List<Object?> get props => [watchList];
}

class HistoryUpdated extends ProfileEvent {
  final List<MovieModel> history;

  const HistoryUpdated(this.history);

  @override
  List<Object?> get props => [history];
}
