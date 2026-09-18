import 'package:equatable/equatable.dart';
import '../../../data/models/movie_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final List<MovieModel> watchList;
  final List<MovieModel> history;
  final int selectedTab; // 0 for Watch List, 1 for History

  const ProfileLoaded({
    required this.watchList,
    required this.history,
    this.selectedTab = 0,
  });

  List<MovieModel> get currentList => selectedTab == 0 ? watchList : history;

  ProfileLoaded copyWith({
    List<MovieModel>? watchList,
    List<MovieModel>? history,
    int? selectedTab,
  }) {
    return ProfileLoaded(
      watchList: watchList ?? this.watchList,
      history: history ?? this.history,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  @override
  List<Object?> get props => [watchList, history, selectedTab];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
