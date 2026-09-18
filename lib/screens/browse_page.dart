import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/browse/bloc/browse_bloc.dart';
import '../features/browse/bloc/browse_event.dart';
import '../features/browse/bloc/browse_state.dart';
import '../movie_details_screen.dart';
import '../widgets/movie_card.dart';
import '../widgets/top_bar_actions.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BrowseBloc()..add(LoadBrowseData()),
      child: Builder(
        builder: (context) {
          final loc = AppLocalizations.of(context);
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            appBar: AppBar(
              title: Text(loc.translate('browse')),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: TopBarActions(),
                ),
              ],
            ),
            body: SafeArea(
              child: BlocBuilder<BrowseBloc, BrowseState>(
                builder: (context, state) {
                  if (state is BrowseLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryYellow,
                      ),
                    );
                  } else if (state is BrowseSuccess) {
                    final genres = state.genres;
                    final selectedGenre = state.selectedGenre;
                    final movies = state.movies;

                    return Column(
                      children: [
                        // Categories horizontal list from deduplicated Set
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            itemCount: genres.length,
                            itemBuilder: (context, index) {
                              final genre = genres[index];
                              final isSelected = genre == selectedGenre;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    genre == 'All' ? loc.translate('all') : genre,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : (isDark ? Colors.white70 : Colors.black87),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppTheme.primaryYellow,
                                  backgroundColor:
                                      isDark ? AppTheme.darkCard : Colors.grey[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppTheme.primaryYellow
                                          : Colors.transparent,
                                    ),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      context
                                          .read<BrowseBloc>()
                                          .add(SelectGenreEvent(genre));
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        // Filter progress or movies grid
                        Expanded(
                          child: state.isFiltering
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryYellow,
                                  ),
                                )
                              : movies.isEmpty
                                  ? Center(
                                      child: Text(
                                        loc.translate('no_movies_found'),
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : LayoutBuilder(
                                      builder: (context, constraints) {
                                        final crossAxisCount =
                                            constraints.maxWidth > 600 ? 4 : 2;
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
                                    ),
                        ),
                      ],
                    );
                  } else if (state is BrowseError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 48),
                          const SizedBox(height: 10),
                          Text(state.message, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.read<BrowseBloc>().add(LoadBrowseData());
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

                  return const SizedBox();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
