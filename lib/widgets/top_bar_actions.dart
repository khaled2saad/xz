import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/localization/language_cubit.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';

class TopBarActions extends StatelessWidget {
  const TopBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Language Toggle Button (عربي / English)
        BlocBuilder<LanguageCubit, Locale>(
          builder: (context, locale) {
            final isArabic = locale.languageCode == 'ar';
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                context.read<LanguageCubit>().toggleLanguage();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryYellow,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language,
                      size: 16,
                      color: AppTheme.primaryYellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isArabic ? 'English' : 'عربي',
                      style: const TextStyle(
                        color: AppTheme.primaryYellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),

        // Theme Toggle Button (Dark / Light)
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final isDark = themeMode == ThemeMode.dark;
            return IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: AppTheme.primaryYellow,
                size: 22,
              ),
              tooltip: isDark ? 'Light Theme' : 'Dark Theme',
              onPressed: () {
                context.read<ThemeCubit>().toggleTheme();
              },
            );
          },
        ),
      ],
    );
  }
}
