import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/home/bloc/home_bloc.dart';
import '../features/home/bloc/home_event.dart';
import '../features/home/bloc/home_state.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../movie_details_screen.dart';
import '../search_screen.dart';
import '../widgets/movie_card.dart';
import '../widgets/top_bar_actions.dart';
import 'browse_page.dart';
import 'profile_page.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeContent(),
    SearchScreen(),
    BrowsePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ضفنا PopScope عشان لما المستخدم يكون في صفحة البحث أو التصفح أو البروفايل ويدوس رجوع في الموبايل
    // يرجعه لصفحة الرئيسية الأولى بدل ما التطبيق يقفل فجأة في وشه
    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentIndex != 0) {
          setState(() {
            currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: isDark ? AppTheme.darkBg : Colors.white,
          selectedItemColor: AppTheme.primaryYellow,
          unselectedItemColor: Colors.grey,
          currentIndex: currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: loc.translate('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              activeIcon: const Icon(Icons.search),
              label: loc.translate('search'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_outlined),
              activeIcon: const Icon(Icons.grid_view),
              label: loc.translate('browse'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: loc.translate('profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// هنا وفرنا الـ HomeBloc لتبويب الرئيسية عشان نحقق شرط الدكتور:
// "Home Tab (Logic)" و "You must use Bloc State Management"
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(const LoadHomeMoviesEvent()),
      child: const _HomeContentView(),
    );
  }
}

class _HomeContentView extends StatelessWidget {
  const _HomeContentView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('app_title')),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: TopBarActions(),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryYellow),
            );
          }

          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    loc.translate('no_movies_found'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(const LoadHomeMoviesEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                    ),
                    child: Text(
                      loc.translate('retry'),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is HomeLoaded) {
            final availableMovies = state.availableMovies;
            final recommendedMovies = state.recommendedMovies;

            return RefreshIndicator(
              color: AppTheme.primaryYellow,
              onRefresh: () async {
                context.read<HomeBloc>().add(const RefreshHomeMoviesEvent());
              },
              child: CustomScrollView(
                slivers: [
                  // Available Now / Featured
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        loc.translate('available_now'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: availableMovies.length,
                        itemBuilder: (context, index) {
                          final m = availableMovies[index];
                          return MovieCardItem(
                            movie: m,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                MovieDetailsScreen.routeName,
                                arguments: m,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Recommended Movies
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Text(
                        loc.translate('recommended_movies'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
                          final m = recommendedMovies[index];
                          return MovieCardItem(
                            movie: m,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                MovieDetailsScreen.routeName,
                                arguments: m,
                              );
                            },
                          );
                        },
                        childCount: recommendedMovies.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}