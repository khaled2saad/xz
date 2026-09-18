import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/movies_repository.dart';
import 'browse_event.dart';
import 'browse_state.dart';

class BrowseBloc extends Bloc<BrowseEvent, BrowseState> {
  final MoviesRepository _moviesRepository;

  BrowseBloc({MoviesRepository? moviesRepository})
      : _moviesRepository = moviesRepository ?? MoviesRepository(),
        super(BrowseLoading()) {
    on<LoadBrowseData>(_onLoadBrowseData);
    on<SelectGenreEvent>(_onSelectGenreEvent);
  }

  Future<void> _onLoadBrowseData(
    LoadBrowseData event,
    Emitter<BrowseState> emit,
  ) async {
    emit(BrowseLoading());
    try {
      final data = await _moviesRepository.getBrowseInitialData();
      final List<String> genres = List<String>.from(data['genres']);
      final movies = data['movies'];
      emit(BrowseSuccess(
        genres: genres,
        selectedGenre: genres.isNotEmpty ? genres.first : 'All',
        movies: movies,
      ));
    } catch (e) {
      emit(BrowseError(e.toString()));
    }
  }

  Future<void> _onSelectGenreEvent(
    SelectGenreEvent event,
    Emitter<BrowseState> emit,
  ) async {
    if (state is BrowseSuccess) {
      final current = state as BrowseSuccess;
      emit(current.copyWith(
        selectedGenre: event.genre,
        isFiltering: true,
      ));

      try {
        final filteredMovies = await _moviesRepository.getMoviesByGenre(event.genre);
        emit(current.copyWith(
          selectedGenre: event.genre,
          movies: filteredMovies,
          isFiltering: false,
        ));
      } catch (e) {
        emit(BrowseError(e.toString()));
      }
    }
  }
}
