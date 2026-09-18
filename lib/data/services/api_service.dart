import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/movie_model.dart';

// هنا عملنا كلاس ApiService باستخدام مكتبة Dio عشان ننفذ شرط الدكتور (use Dio not Http)
class ApiService {
  // ضفنا السيرفرات الرسمية الجديدة والشغالة في الأول عشان نتجنب حجب yts.mx في مصر والتطبيق يفتح علطول من غير تأخير
  static const List<String> baseUrls = [
    'https://movies-api.accel.li/api/v2/',
    'https://yts.gg/api/v2/',
    'https://yts.mx/api/v2/',
    'https://yts.lt/api/v2/',
    'https://yts.am/api/v2/',
  ];

  final Dio _dio;

  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
                // خلينا الـ Dio يتبع أي Redirect (تحويل رابط 301/302) تلقائي عشان لو السيرفر حوله لرابط جديد يشتغل معاه
                followRedirects: true,
                maxRedirects: 5,
                validateStatus: (status) => status != null && status < 400,
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  // دالة ذكية بتجرب الروابط البديلة ورا بعض لو الأول وقع
  Future<Response?> _getWithMirrors(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    for (final base in baseUrls) {
      try {
        final url = '$base$endpoint';
        debugPrint('[ApiService] Requesting: $url with params: $queryParameters');
        final res = await _dio.get(url, queryParameters: queryParameters);
        if (res.statusCode == 200 && res.data != null) {
          return res;
        }
      } catch (e) {
        debugPrint('[ApiService] Mirror $base failed: $e, trying next...');
      }
    }
    return null;
  }

  // بنجيب لستة الأفلام للـ Home والـ Search والـ Browse
  Future<List<MovieModel>> getMovies({
    String? queryTerm,
    String? genre,
    int page = 1,
    int limit = 20,
    String? sortBy,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };

    if (queryTerm != null && queryTerm.trim().isNotEmpty) {
      queryParams['query_term'] = queryTerm.trim();
    }
    if (genre != null && genre.trim().isNotEmpty && genre.toLowerCase() != 'all') {
      queryParams['genre'] = genre.trim();
    }
    if (sortBy != null && sortBy.trim().isNotEmpty) {
      queryParams['sort_by'] = sortBy.trim();
    }

    try {
      final response = await _getWithMirrors('list_movies.json', queryParameters: queryParams);
      if (response != null && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['movies'] != null) {
          final List moviesJson = data['movies'];
          return moviesJson.map((json) => MovieModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] getMovies error: $e');
      return [];
    }
  }

  // بنسحب تفاصيل الفيلم بالـ ID بتاعه من الـ API مباشرة (movie_details.json)
  Future<MovieModel?> getMovieDetails(int movieId) async {
    try {
      debugPrint('[ApiService] بنسحب تفاصيل الفيلم بالـ ID: $movieId');
      final response = await _getWithMirrors(
        'movie_details.json',
        queryParameters: {
          'movie_id': movieId,
          'with_images': true,
          'with_cast': true,
        },
      );

      if (response != null && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['movie'] != null) {
          debugPrint('[ApiService] التفاصيل جت بنجاح للـ ID $movieId: ${data['movie']['title']}');
          return MovieModel.fromJson(data['movie']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[ApiService] حصل مشكلة في سحب التفاصيل للـ id $movieId: $e');
      return null;
    }
  }

  // بنسحب الأفلام المقترحة والمشابهة لنفس الفيلم بالـ ID بتاعه (movie_suggestions.json)
  Future<List<MovieModel>> getMovieSuggestions(int movieId) async {
    try {
      debugPrint('[ApiService] بنسحب المقترحات للفيلم بالـ ID: $movieId');
      final response = await _getWithMirrors(
        'movie_suggestions.json',
        queryParameters: {
          'movie_id': movieId,
        },
      );

      if (response != null && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['movies'] != null) {
          final List moviesJson = data['movies'];
          debugPrint('[ApiService] لقينا ${moviesJson.length} أفلام مقترحة للفيلم ده');
          return moviesJson.map((json) => MovieModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] مشكلة في جلب المقترحات للـ id $movieId: $e');
      return [];
    }
  }
}
