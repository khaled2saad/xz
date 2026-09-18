import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  StreamSubscription<List<MovieModel>>? _watchListSub;
  StreamSubscription<List<MovieModel>>? _historySub;

  ProfileBloc({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? ProfileRepository(),
        super(ProfileLoading()) {
    on<LoadProfileData>(_onLoadProfileData);
    on<SwitchProfileTab>(_onSwitchProfileTab);
    on<WatchListUpdated>(_onWatchListUpdated);
    on<HistoryUpdated>(_onHistoryUpdated);
  }

  void _onLoadProfileData(
    LoadProfileData event,
    Emitter<ProfileState> emit,
  ) {
    _watchListSub?.cancel();
    _historySub?.cancel();

    _watchListSub = _profileRepository.getWatchListStream().listen(
      (list) => add(WatchListUpdated(list)),
      onError: (err) => emit(ProfileError(err.toString())),
    );

    _historySub = _profileRepository.getHistoryStream().listen(
      (list) => add(HistoryUpdated(list)),
      onError: (err) => emit(ProfileError(err.toString())),
    );
  }

  void _onSwitchProfileTab(
    SwitchProfileTab event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(selectedTab: event.tabIndex));
    }
  }

  void _onWatchListUpdated(
    WatchListUpdated event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(watchList: event.watchList));
    } else {
      emit(ProfileLoaded(
        watchList: event.watchList,
        history: const [],
        selectedTab: 0,
      ));
    }
  }

  void _onHistoryUpdated(
    HistoryUpdated event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(history: event.history));
    } else {
      emit(ProfileLoaded(
        watchList: const [],
        history: event.history,
        selectedTab: 0,
      ));
    }
  }

  @override
  Future<void> close() {
    _watchListSub?.cancel();
    _historySub?.cancel();
    return super.close();
  }
}
