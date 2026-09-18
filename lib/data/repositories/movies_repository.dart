import '../models/movie_model.dart';
import '../services/api_service.dart';

class MoviesRepository {
  final ApiService _apiService;

  MoviesRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Search movies by title
  Future<List<MovieModel>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    return await _apiService.getMovies(queryTerm: query, limit: 30);
  }

  // تطبيق شرط التوثيق بالحرف:
  // بنلف على لستة الأفلام ونسحب كل الـ genres ونحطها في Set عشان الـ Set بيمنع أي تكرار تلقائياً
  // وبعد كده بنستخدم الـ Set دي عشان نبني بيها الـ Category Tabs للشاشة
  Future<Map<String, dynamic>> getBrowseInitialData() async {
    final movies = await _apiService.getMovies(limit: 50, sortBy: 'rating');
    final Set<String> genreSet = {'All'};

    for (final movie in movies) {
      for (final g in movie.genres) {
        if (g.trim().isNotEmpty) {
          genreSet.add(g.trim()); // الـ Set هيهتم إنه ميسمحش بأي تصنيف مكرر
        }
      }
    }

    // Default fallback genres if API returns sparse list
    if (genreSet.length <= 1) {
      genreSet.addAll([
        'Action',
        'Adventure',
        'Animation',
        'Comedy',
        'Crime',
        'Drama',
        'Fantasy',
        'Horror',
        'Sci-Fi',
        'Thriller'
      ]);
    }

    return {
      'genres': genreSet.toList(),
      'movies': movies,
    };
  }

  /// Browse: get movies by selected genre
  Future<List<MovieModel>> getMoviesByGenre(String genre) async {
    return await _apiService.getMovies(
      genre: genre == 'All' ? null : genre,
      limit: 30,
      sortBy: 'rating',
    );
  }

  /// Details: fetch single movie details
  Future<MovieModel?> getMovieDetails(int movieId) async {
    return await _apiService.getMovieDetails(movieId);
  }

  /// Suggestions: fetch similar/suggested movies
  Future<List<MovieModel>> getMovieSuggestions(int movieId) async {
    return await _apiService.getMovieSuggestions(movieId);
  }

  /// Home: featured movies
  Future<List<MovieModel>> getHomeMovies() async {
    return await _apiService.getMovies(limit: 20, sortBy: 'like_count');
  }
}
