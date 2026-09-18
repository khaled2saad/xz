import 'package:equatable/equatable.dart';

class MovieModel extends Equatable {
  final int id;
  final String title;
  final int year;
  final double rating;
  final int runtime;
  final List<String> genres;
  final String summary;
  final String descriptionFull;
  final String mediumCoverImage;
  final String largeCoverImage;
  final String backgroundImage;
  final String ytTrailerCode;

  const MovieModel({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.genres,
    required this.summary,
    required this.descriptionFull,
    required this.mediumCoverImage,
    required this.largeCoverImage,
    required this.backgroundImage,
    required this.ytTrailerCode,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedGenres = [];
    if (json['genres'] != null) {
      parsedGenres = List<String>.from(
        (json['genres'] as List).map((e) => e.toString()),
      );
    }

    return MovieModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? '',
      year: json['year'] is int ? json['year'] : int.tryParse('${json['year']}') ?? 0,
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse('${json['rating']}') ?? 0.0,
      runtime: json['runtime'] is int ? json['runtime'] : int.tryParse('${json['runtime']}') ?? 0,
      genres: parsedGenres,
      summary: json['summary']?.toString() ?? '',
      descriptionFull: json['description_full']?.toString() ?? json['summary']?.toString() ?? '',
      mediumCoverImage: json['medium_cover_image']?.toString() ?? '',
      largeCoverImage: json['large_cover_image']?.toString() ?? json['medium_cover_image']?.toString() ?? '',
      backgroundImage: json['background_image_original']?.toString() ?? json['background_image']?.toString() ?? '',
      ytTrailerCode: json['yt_trailer_code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'rating': rating,
      'runtime': runtime,
      'genres': genres,
      'summary': summary,
      'descriptionFull': descriptionFull,
      'mediumCoverImage': mediumCoverImage,
      'largeCoverImage': largeCoverImage,
      'backgroundImage': backgroundImage,
      'ytTrailerCode': ytTrailerCode,
      'savedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id'] is int ? map['id'] : int.tryParse('${map['id']}') ?? 0,
      title: map['title']?.toString() ?? '',
      year: map['year'] is int ? map['year'] : int.tryParse('${map['year']}') ?? 0,
      rating: (map['rating'] is num)
          ? (map['rating'] as num).toDouble()
          : double.tryParse('${map['rating']}') ?? 0.0,
      runtime: map['runtime'] is int ? map['runtime'] : int.tryParse('${map['runtime']}') ?? 0,
      genres: map['genres'] != null ? List<String>.from(map['genres']) : [],
      summary: map['summary']?.toString() ?? '',
      descriptionFull: map['descriptionFull']?.toString() ?? map['summary']?.toString() ?? '',
      mediumCoverImage: map['mediumCoverImage']?.toString() ?? '',
      largeCoverImage: map['largeCoverImage']?.toString() ?? '',
      backgroundImage: map['backgroundImage']?.toString() ?? '',
      ytTrailerCode: map['ytTrailerCode']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, year, rating];
}
