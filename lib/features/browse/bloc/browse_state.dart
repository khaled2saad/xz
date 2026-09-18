import 'package:equatable/equatable.dart';
import '../../../data/models/movie_model.dart';

abstract class BrowseState extends Equatable {
  const BrowseState();

  @override
  List<Object?> get props => [];
}

class BrowseLoading extends BrowseState {}

class BrowseSuccess extends BrowseState {
  final List<String> genres;
  final String selectedGenre;
  final List<MovieModel> movies;
  final bool isFiltering;

  const BrowseSuccess({
    required this.genres,
    required this.selectedGenre,
    required this.movies,
    this.isFiltering = false,
  });

  BrowseSuccess copyWith({
    List<String>? genres,
    String? selectedGenre,
    List<MovieModel>? movies,
    bool? isFiltering,
  }) {
    return BrowseSuccess(
      genres: genres ?? this.genres,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      movies: movies ?? this.movies,
      isFiltering: isFiltering ?? this.isFiltering,
    );
  }

  @override
  List<Object?> get props => [genres, selectedGenre, movies, isFiltering];
}

class BrowseError extends BrowseState {
  final String message;

  const BrowseError(this.message);

  @override
  List<Object?> get props => [message];
}
