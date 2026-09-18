import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/search/bloc/search_bloc.dart';
import 'features/search/bloc/search_event.dart';
import 'features/search/bloc/search_state.dart';
import 'movie_details_screen.dart';
import 'widgets/movie_card.dart';
import 'widgets/top_bar_actions.dart';

class SearchScreen extends StatefulWidget {
  static const String routeName = '/search';

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // هنا عملنا مؤقت (Debounce) نص ثانية عشان ميبعتش ريكويست للنت مع كل حرف
  // يستنى المستخدم يخلص كتابة وبعدين يبعت يبحث في API YTS بالعنوان
  void _onSearchChanged(String query, BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        // بنبعت الإيفينت للـ SearchBloc يبحث في https://yts.mx/api/v2/list_movies.json
        context.read<SearchBloc>().add(SearchQueryChanged(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // بنوفر SearchBloc للشاشة لتنفيذ متطلبات المرحلة التالتة
    return BlocProvider(
      create: (context) => SearchBloc(),
      child: Builder(
        builder: (context) {
          final loc = AppLocalizations.of(context);

          return Scaffold(
            appBar: AppBar(
              title: Text(loc.translate('search')),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: TopBarActions(),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Search Input Field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => _onSearchChanged(val, context),
                      onSubmitted: (val) {
                        context.read<SearchBloc>().add(SearchQueryChanged(val));
                      },
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: loc.translate('search_hint'),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkCard : Colors.grey[200],
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.primaryYellow,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<SearchBloc>().add(ClearSearch());
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),

                  // Search Results Area
                  Expanded(
                    child: BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, state) {
                        if (state is SearchLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryYellow,
                            ),
                          );
                        } else if (state is SearchSuccess) {
                          final movies = state.movies;
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                              return GridView.builder(
                                padding: const EdgeInsets.all(14),
                                itemCount: movies.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.65,
                                ),
                                itemBuilder: (context, index) {
                                  final movie = movies[index];
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
                              );
                            },
                          );
                        } else if (state is SearchEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  loc.translate('no_movies_found'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is SearchError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.redAccent,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<SearchBloc>().add(
                                            SearchQueryChanged(
                                              _searchController.text,
                                            ),
                                          );
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
                            ),
                          );
                        }

                        // Initial State
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/empty.png',
                                width: 120,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.movie_filter_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                loc.translate('search_hint'),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}