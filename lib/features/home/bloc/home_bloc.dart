import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/repositories/movies_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

// هنا عملنا HomeBloc مخصوص لتبويب الرئيسية عشان نطبق شرط الدوكيومنت بحذافيره:
// "Home Tab (Logic)" & "You must use Bloc State Management"
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final MoviesRepository _moviesRepository;

  HomeBloc({MoviesRepository? moviesRepository})
      : _moviesRepository = moviesRepository ?? MoviesRepository(),
        super(const HomeInitial()) {
    on<LoadHomeMoviesEvent>(_onLoadHomeMovies);
    on<RefreshHomeMoviesEvent>(_onRefreshHomeMovies);
  }

  Future<void> _onLoadHomeMovies(
    LoadHomeMoviesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _fetchMovies(emit);
  }

  Future<void> _onRefreshHomeMovies(
    RefreshHomeMoviesEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _fetchMovies(emit);
  }

  Future<void> _fetchMovies(Emitter<HomeState> emit) async {
    try {
      // بنجلب لستة الأفلام باستخدام Dio من الـ Repository
      final List<MovieModel> movies = await _moviesRepository.getHomeMovies();

      if (movies.isEmpty) {
        emit(const HomeError('لم يتم العثور على أفلام حالياً'));
        return;
      }

      // بنقسم الأفلام لجزئين: متاح الآن (أول 6 أفلام) وأفلام موصى بها (باقي اللستة)
      final availableMovies = movies.take(6).toList();
      final recommendedMovies = movies.length > 6 ? movies.skip(6).toList() : movies;

      emit(HomeLoaded(
        availableMovies: availableMovies,
        recommendedMovies: recommendedMovies,
      ));
    } catch (e) {
      emit(HomeError('حصل خطأ أثناء تحميل الأفلام: $e'));
    }
  }
}
