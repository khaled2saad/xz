import 'package:equatable/equatable.dart';
import '../../../data/models/movie_model.dart';

abstract class MovieDetailsState extends Equatable {
  const MovieDetailsState();

  @override
  List<Object?> get props => [];
}

class MovieDetailsLoading extends MovieDetailsState {
  final MovieModel? currentMovie;

  const MovieDetailsLoading({this.currentMovie});

  @override
  List<Object?> get props => [currentMovie];
}

class MovieDetailsSuccess extends MovieDetailsState {
  final MovieModel movie;
  final List<MovieModel> suggestions;
  final bool isInWatchList;

  const MovieDetailsSuccess({
    required this.movie,
    required this.suggestions,
    required this.isInWatchList,
  });

  MovieDetailsSuccess copyWith({
    MovieModel? movie,
    List<MovieModel>? suggestions,
    bool? isInWatchList,
  }) {
    return MovieDetailsSuccess(
      movie: movie ?? this.movie,
      suggestions: suggestions ?? this.suggestions,
      isInWatchList: isInWatchList ?? this.isInWatchList,
    );
  }

  @override
  List<Object?> get props => [movie, suggestions, isInWatchList];
}

class MovieDetailsError extends MovieDetailsState {
  final String message;

  const MovieDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
