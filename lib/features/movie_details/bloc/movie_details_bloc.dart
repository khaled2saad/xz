import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/repositories/movies_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import 'movie_details_event.dart';
import 'movie_details_state.dart';

class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final MoviesRepository _moviesRepository;
  final ProfileRepository _profileRepository;

  MovieDetailsBloc({
    MoviesRepository? moviesRepository,
    ProfileRepository? profileRepository,
  })  : _moviesRepository = moviesRepository ?? MoviesRepository(),
        _profileRepository = profileRepository ?? ProfileRepository(),
        super(const MovieDetailsLoading()) {
    on<LoadMovieDetailsAndSuggestions>(_onLoadMovieDetails);
    on<ToggleFavoriteMovieEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadMovieDetails(
    LoadMovieDetailsAndSuggestions event,
    Emitter<MovieDetailsState> emit,
  ) async {
    final movieId = event.movieId;
    final initialMovie = event.initialMovie;
    debugPrint('[MovieDetailsBloc] بنبدأ نجهز تفاصيل ومقترحات الفيلم للـ ID: $movieId');

    emit(MovieDetailsLoading(currentMovie: initialMovie));

    try {
      // ١. بنبعت الطلبات للـ API في نفس الوقت (Parallel) بالـ Movie ID عشان الأداء يكون سريع جداً:
      // - طلب معرفة هل الفيلم متسجل في المفضلة (Watch List)
      // - طلب تفاصيل الفيلم الكاملة من API YTS
      // - طلب الأفلام المشابهة (Movie Suggestions)
      final inWatchListFuture = movieId > 0
          ? _profileRepository.isMovieInWatchList(movieId)
          : Future.value(false);

      final detailedMovieFuture = movieId > 0
          ? _moviesRepository.getMovieDetails(movieId)
          : Future<MovieModel?>.value(null);

      final suggestionsFuture = movieId > 0
          ? _moviesRepository.getMovieSuggestions(movieId)
          : Future<List<MovieModel>>.value([]);

      final results = await Future.wait([
        inWatchListFuture,
        detailedMovieFuture,
        suggestionsFuture,
      ]);

      final bool inWatchList = results[0] as bool;
      final MovieModel? fetchedMovie = results[1] as MovieModel?;
      final List<MovieModel> suggestions = results[2] as List<MovieModel>;

      final MovieModel finalMovie = fetchedMovie ??
          initialMovie ??
          MovieModel(
            id: movieId,
            title: 'Movie #$movieId',
            year: 0,
            rating: 0.0,
            runtime: 0,
            genres: const [],
            summary: '',
            descriptionFull: '',
            mediumCoverImage: '',
            largeCoverImage: '',
            backgroundImage: '',
            ytTrailerCode: '',
          );

      // 2. Save to History on Firebase with the full movie data
      if (finalMovie.id > 0) {
        _profileRepository.addToHistory(finalMovie);
      }

      debugPrint('[MovieDetailsBloc] Emitting MovieDetailsSuccess for ID: ${finalMovie.id} (${finalMovie.title}), suggestions count: ${suggestions.length}');

      emit(MovieDetailsSuccess(
        movie: finalMovie,
        suggestions: suggestions,
        isInWatchList: inWatchList,
      ));
    } catch (e) {
      debugPrint('[MovieDetailsBloc] Error loading movie details for ID $movieId: $e');
      if (initialMovie != null) {
        emit(MovieDetailsSuccess(
          movie: initialMovie,
          suggestions: const [],
          isInWatchList: false,
        ));
      } else {
        emit(MovieDetailsError(e.toString()));
      }
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteMovieEvent event,
    Emitter<MovieDetailsState> emit,
  ) async {
    if (state is MovieDetailsSuccess) {
      final current = state as MovieDetailsSuccess;
      final newStatus = await _profileRepository.toggleWatchList(event.movie);
      emit(current.copyWith(isInWatchList: newStatus));
    }
  }
}
