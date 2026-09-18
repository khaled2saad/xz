import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/movies_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final MoviesRepository _moviesRepository;

  SearchBloc({MoviesRepository? moviesRepository})
      : _moviesRepository = moviesRepository ?? MoviesRepository(),
        super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final movies = await _moviesRepository.searchMovies(query);
      if (movies.isEmpty) {
        emit(SearchEmpty(query: query));
      } else {
        emit(SearchSuccess(movies: movies, query: query));
      }
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
