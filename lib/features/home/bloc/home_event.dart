import 'package:equatable/equatable.dart';

// الأحداث الخاصة بـ HomeBloc
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

// إيفينت تحميل أفلام الصفحة الرئيسية (Available Now و Recommended)
class LoadHomeMoviesEvent extends HomeEvent {
  const LoadHomeMoviesEvent();
}

// إيفينت إعادة التحميل عند السحب (Pull to Refresh)
class RefreshHomeMoviesEvent extends HomeEvent {
  const RefreshHomeMoviesEvent();
}
