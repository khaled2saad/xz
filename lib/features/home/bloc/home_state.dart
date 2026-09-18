import 'package:equatable/equatable.dart';
import '../../../data/models/movie_model.dart';

// الحالات الخاصة بـ HomeBloc لتنفيذ شرط الدكتور (Use Bloc State Management)
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

// حالة بداية التحميل
class HomeInitial extends HomeState {
  const HomeInitial();
}

// حالة جاري التحميل وظهور الـ Spinner
class HomeLoading extends HomeState {
  const HomeLoading();
}

// حالة نجاح جلب الأفلام من الـ API
class HomeLoaded extends HomeState {
  final List<MovieModel> availableMovies;
  final List<MovieModel> recommendedMovies;

  const HomeLoaded({
    required this.availableMovies,
    required this.recommendedMovies,
  });

  @override
  List<Object?> get props => [availableMovies, recommendedMovies];
}

// حالة حدوث خطأ أثناء الاتصال بالـ API
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
