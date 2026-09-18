import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../login_scanner.dart';
import '../core/app_assets.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/profile/bloc/profile_bloc.dart';
import '../features/profile/bloc/profile_event.dart';
import '../features/profile/bloc/profile_state.dart';
import '../movie_details_screen.dart';
import '../up_date_profile/up_date_profile_screen.dart';
import '../widgets/movie_card.dart';
import '../widgets/top_bar_actions.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // هنا بنشغل الـ ProfileBloc عشان يراقب التغييرات اللي بتحصل في الفايربيس لايف (Streams)
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfileData()),
      child: Builder(
        builder: (context) {
          final loc = AppLocalizations.of(context);
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            appBar: AppBar(
              title: Text(loc.translate('profile')),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: TopBarActions(),
                ),
              ],
            ),
            body: SafeArea(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryYellow,
                      ),
                    );
                  } else if (state is ProfileLoaded) {
                    // watchList: الأفلام اللي ضفناها في المفضلة من شاشة التفاصيل ومحفوظة في فايربيس
                    // history: آخر الأفلام اللي المستخدم فتحها واتسجلت تلقائي في السجل
                    final watchList = state.watchList;
                    final history = state.history;
                    final selectedTab = state.selectedTab;
                    final currentList = state.currentList;

                    return CustomScrollView(
                      slivers: [
                        // User Header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 34,
                                      backgroundColor: isDark
                                          ? AppTheme.darkCard
                                          : Colors.grey[300],
                                      backgroundImage: const AssetImage(
                                        AppAssets.profileImage,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // بنعرض اسم المستخدم الفعلي المسجل في الفايربيس بدل ما يكون نص ثابت
                                          Text(
                                            (FirebaseAuth.instance.currentUser?.displayName?.isNotEmpty == true)
                                                ? FirebaseAuth.instance.currentUser!.displayName!
                                                : (FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'User'),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _buildStatItem(
                                                '${watchList.length}',
                                                loc.translate('watch_list'),
                                                isDark,
                                              ),
                                              const SizedBox(width: 20),
                                              _buildStatItem(
                                                '${history.length}',
                                                loc.translate('history'),
                                                isDark,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Action Buttons (Edit Profile, Exit)
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            UpDateProfileScreen.routeName,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.primaryYellow,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          loc.translate('edit_profile'),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    OutlinedButton(
                                      onPressed: () async {
                                        // بنسجل خروج فعلي من الفايربيس ونمسح كل الصفحات القديمة من الـ Stack
                                        // عشان المستخدم يرجع لشاشة الـ Login من الصفر وميعرفش يرجع بزرار Back
                                        await FirebaseAuth.instance.signOut();
                                        if (context.mounted) {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            LoginScaner.routeName,
                                            (route) => false,
                                          );
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
                                        side: const BorderSide(
                                          color: Colors.redAccent,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(loc.translate('exit')),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Tab Selector (Watch List / History)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTabButton(
                                        label:
                                            '${loc.translate('watch_list')} (${watchList.length})',
                                        isSelected: selectedTab == 0,
                                        onTap: () {
                                          context
                                              .read<ProfileBloc>()
                                              .add(const SwitchProfileTab(0));
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTabButton(
                                        label:
                                            '${loc.translate('history')} (${history.length})',
                                        isSelected: selectedTab == 1,
                                        onTap: () {
                                          context
                                              .read<ProfileBloc>()
                                              .add(const SwitchProfileTab(1));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Movie Grid for WatchList / History
                        currentList.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        selectedTab == 0
                                            ? Icons.bookmark_border
                                            : Icons.history,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        selectedTab == 0
                                            ? loc.translate('empty_watchlist')
                                            : loc.translate('empty_history'),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.65,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final movie = currentList[index];
                                      return MovieCardItem(
                                        movie: movie,
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            MovieDetailsScreen.routeName,
                                            arguments: movie,
                                          );
                                        },
                                      );
                                    },
                                    childCount: currentList.length,
                                  ),
                                ),
                              ),
                      ],
                    );
                  } else if (state is ProfileError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String count, String label, bool isDark) {
    return Row(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppTheme.primaryYellow : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryYellow : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
