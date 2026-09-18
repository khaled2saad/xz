import 'package:equatable/equatable.dart';
import '../../../data/models/movie_model.dart';

abstract class MovieDetailsEvent extends Equatable {
  const MovieDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMovieDetailsAndSuggestions extends MovieDetailsEvent {
  final int movieId;
  final MovieModel? initialMovie;

  const LoadMovieDetailsAndSuggestions({
    required this.movieId,
    this.initialMovie,
  });

  @override
  List<Object?> get props => [movieId, initialMovie];
}

class ToggleFavoriteMovieEvent extends MovieDetailsEvent {
  final MovieModel movie;

  const ToggleFavoriteMovieEvent(this.movie);

  @override
  List<Object?> get props => [movie];
}
