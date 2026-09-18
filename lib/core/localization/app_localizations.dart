import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_title': 'Movies App',
      'home': 'Home',
      'search': 'Search',
      'browse': 'Browse',
      'profile': 'Profile',
      'available_now': 'Available Now',
      'recommended_movies': 'Recommended Movies',
      'similar': 'Similar Movies',
      'summary': 'Summary',
      'genres': 'Genres',
      'screen_shots': 'Screen Shots',
      'watch_list': 'Watch List',
      'history': 'History',
      'edit_profile': 'Edit Profile',
      'exit': 'Exit',
      'delete_account': 'Delete Account',
      'update_data': 'Update Data',
      'name': 'Name',
      'phone': 'Phone',
      'forgot_password': 'Forgot Password',
      'search_hint': 'Search for movies...',
      'no_movies_found': 'No movies found',
      'empty_watchlist': 'Your Watch List is empty',
      'empty_history': 'No history yet',
      'added_to_watchlist': 'Added to Watch List',
      'removed_from_watchlist': 'Removed from Watch List',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'language': 'Language',
      'arabic': 'العربية',
      'english': 'English',
      'all': 'All',
      'login': 'Login',
      'register': 'Register',
      'loading': 'Loading...',
      'error_occurred': 'An error occurred. Please try again.',
      'retry': 'Retry',
    },
    'ar': {
      'app_title': 'تطبيق الأفلام',
      'home': 'الرئيسية',
      'search': 'بحث',
      'browse': 'تصفح',
      'profile': 'الملف الشخصي',
      'available_now': 'متاح الآن',
      'recommended_movies': 'أفلام موصى بها',
      'similar': 'أفلام مشابهة',
      'summary': 'الملخص',
      'genres': 'التصنيفات',
      'screen_shots': 'لقطات من الفيلم',
      'watch_list': 'قائمة المشاهدة',
      'history': 'السجل',
      'edit_profile': 'تعديل الملف',
      'exit': 'خروج',
      'delete_account': 'حذف الحساب',
      'update_data': 'تحديث البيانات',
      'name': 'الاسم',
      'phone': 'رقم الهاتف',
      'forgot_password': 'نسيت كلمة السر',
      'search_hint': 'ابحث عن فيلم...',
      'no_movies_found': 'لم يتم العثور على أفلام',
      'empty_watchlist': 'قائمة المشاهدة فارغة',
      'empty_history': 'لا يوجد سجل مشاهدات بعد',
      'added_to_watchlist': 'تمت الإضافة لقائمة المشاهدة',
      'removed_from_watchlist': 'تم الحذف من قائمة المشاهدة',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'language': 'اللغة',
      'arabic': 'العربية',
      'english': 'English',
      'all': 'الكل',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'loading': 'جاري التحميل...',
      'error_occurred': 'حدث خطأ، يرجى المحاولة لاحقاً',
      'retry': 'إعادة المحاولة',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  bool get isArabic => locale.languageCode == 'ar';
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
