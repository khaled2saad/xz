import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'data/models/movie_model.dart';
import 'features/movie_details/bloc/movie_details_bloc.dart';
import 'features/movie_details/bloc/movie_details_event.dart';
import 'features/movie_details/bloc/movie_details_state.dart';
import 'widgets/movie_card.dart';
import 'widgets/top_bar_actions.dart';

class MovieDetailsScreen extends StatelessWidget {
  static const String routeName = '/movie-details';

  final MovieModel? movie;
  final int? movieId;

  const MovieDetailsScreen({
    super.key,
    this.movie,
    this.movieId,
  });

  @override
  Widget build(BuildContext context) {
    // ١. هنا بنسحب الـ ID والفيلم من الـ Navigation بمرونة كاملة
    // عشان لو المبرمج بعت كائن الفيلم، أو بعت الـ ID كرقم int، أو حتى كـ String أو Map نلقطه في كل الحالات
    final Object? args = ModalRoute.of(context)?.settings.arguments;

    int resolvedId = movieId ?? 0;
    MovieModel? resolvedMovie = movie;

    if (args is MovieModel) {
      resolvedMovie = args;
      resolvedId = args.id; // سحبنا الـ ID من كائن MovieModel
    } else if (args is int) {
      resolvedId = args; // سحبنا الـ ID كرقم مباشر
    } else if (args is String) {
      resolvedId = int.tryParse(args) ?? resolvedId; // حولنا النص لرقم ID
    } else if (args is Map) {
      if (args['movie'] is MovieModel) {
        resolvedMovie = args['movie'] as MovieModel;
        resolvedId = resolvedMovie.id;
      } else if (args['id'] != null) {
        resolvedId = int.tryParse('${args['id']}') ?? resolvedId;
      }
    }

    if (resolvedId == 0 && resolvedMovie != null) {
      resolvedId = resolvedMovie.id;
    }

    debugPrint('[MovieDetailsScreen] الـ ID اللي استلمناه: $resolvedId واسم الفيلم: ${resolvedMovie?.title}');

    // ٢. بنشغل الـ MovieDetailsBloc ونبعتله الـ ID عشان يكلم الـ API ويجيب التفاصيل والمقترحات
    return BlocProvider(
      create: (context) => MovieDetailsBloc()
        ..add(LoadMovieDetailsAndSuggestions(
          movieId: resolvedId,
          initialMovie: resolvedMovie,
        )),
      child: Scaffold(
        body: BlocConsumer<MovieDetailsBloc, MovieDetailsState>(
          listener: (context, state) {
            // Optional state notifications
          },
          builder: (context, state) {
            final loc = AppLocalizations.of(context);

            if (state is MovieDetailsLoading && state.currentMovie == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryYellow,
                ),
              );
            }

            MovieModel displayMovie = resolvedMovie ??
                MovieModel(
                  id: resolvedId,
                  title: 'Loading...',
                  year: 0,
                  rating: 0.0,
                  runtime: 0,
                  genres: const [],
                  summary: '',
                  descriptionFull: '',
                  mediumCoverImage: '',
                  largeCoverImage: '',
                  backgroundImage: '',
                  ytTrailerCode: '',
                );

            List<MovieModel> suggestions = [];
            bool isInWatchList = false;

            if (state is MovieDetailsSuccess) {
              displayMovie = state.movie;
              suggestions = state.suggestions;
              isInWatchList = state.isInWatchList;
            } else if (state is MovieDetailsLoading && state.currentMovie != null) {
              displayMovie = state.currentMovie!;
            }

            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHero(context, displayMovie, isInWatchList),
                  ),
                  SliverToBoxAdapter(
                    child: _buildInfo(context, displayMovie),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSummary(context, loc, displayMovie),
                  ),
                  if (suggestions.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildSuggestions(context, loc, suggestions),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 40),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    MovieModel movie,
    bool isInWatchList,
  ) {
    final hasBg = movie.backgroundImage.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 420,
      child: Stack(
        children: [
          // Background Backdrop
          Positioned.fill(
            child: hasBg && movie.backgroundImage.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: movie.backgroundImage,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.black26),
                    errorWidget: (_, __, ___) => Container(color: Colors.black45),
                  )
                : Image.asset(
                    'assets/images/doctor_strange_background.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.black54),
                  ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    (isDark ? AppTheme.darkBg : AppTheme.lightBg).withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),

          // Top App Bar Controls
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Row(
                  children: [
                    // زرار المفضلة وقائمة المشاهدة (Watch List): بيحفظ ويحذف الفيلم في الـ Firebase Firestore مباشرة
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: Icon(
                          isInWatchList ? Icons.bookmark : Icons.bookmark_border,
                          color: isInWatchList
                              ? AppTheme.primaryYellow
                              : Colors.white,
                        ),
                        onPressed: () {
                          // بنبعت إيفينت للـ Bloc يغير حالة الفيلم في الفايربيس
                          context
                              .read<MovieDetailsBloc>()
                              .add(ToggleFavoriteMovieEvent(movie));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isInWatchList
                                    ? AppLocalizations.of(context)
                                        .translate('removed_from_watchlist')
                                    : AppLocalizations.of(context)
                                        .translate('added_to_watchlist'),
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppTheme.darkSurface,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const TopBarActions(),
                  ],
                ),
              ],
            ),
          ),

          // Poster Image
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 150,
                  height: 220,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: movie.largeCoverImage.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: movie.largeCoverImage,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey.withValues(alpha: 0.3),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryYellow,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        )
                      : Image.asset(
                          movie.largeCoverImage.isNotEmpty
                              ? movie.largeCoverImage
                              : 'assets/images/doctor_strange.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.movie,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
            ),
          ),

          // Play button & Title
          Positioned(
            left: 16,
            right: 16,
            bottom: 15,
            child: Column(
              children: [
                // خلينا زرار التشغيل يفتح ويشغل فيديو التريلر علطول على يوتيوب بدل ما يعرض رسالة بس
                GestureDetector(
                  onTap: () async {
                    final trailerCode = movie.ytTrailerCode;
                    if (trailerCode.isNotEmpty) {
                      final Uri youtubeAppUri = Uri.parse('vnd.youtube:$trailerCode');
                      final Uri youtubeWebUri = Uri.parse('https://www.youtube.com/watch?v=$trailerCode');

                      try {
                        // بنجرب نفتح في تطبيق يوتيوب الأول لو موجود على الجهاز
                        final bool launchedApp = await launchUrl(
                          youtubeAppUri,
                          mode: LaunchMode.externalApplication,
                        );
                        if (!launchedApp) {
                          // لو تطبيق يوتيوب مش نازل، بنفتحه في المتصفح الخارجي
                          await launchUrl(
                            youtubeWebUri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      } catch (e) {
                        // كحل احتياطي لو حصل أي استثناء، بنفتحه في المتصفح الداخلي أو الخارجي
                        try {
                          await launchUrl(
                            youtubeWebUri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (err) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تعذر فتح رابط يوتيوب'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('مفيش تريلر متاح للفيلم ده حالياً'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  movie.year > 0 ? '${movie.year}' : '',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(BuildContext context, MovieModel movie) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.darkCard : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoChip(
            movie.year > 0 ? '${movie.year}' : 'N/A',
            cardColor,
            textColor,
          ),
          _buildInfoChip(
            movie.runtime > 0 ? '${movie.runtime} min' : '120 min',
            cardColor,
            textColor,
          ),
          _buildInfoChip(
            '★ ${movie.rating.toStringAsFixed(1)}',
            cardColor,
            AppTheme.primaryYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    AppLocalizations loc,
    MovieModel movie,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('summary'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.descriptionFull.isNotEmpty
                ? movie.descriptionFull
                : (movie.summary.isNotEmpty
                    ? movie.summary
                    : 'No summary available for this title.'),
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          if (movie.genres.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              loc.translate('genres'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: movie.genres.map((genre) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryYellow.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    genre,
                    style: const TextStyle(
                      color: AppTheme.primaryYellow,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestions(
    BuildContext context,
    AppLocalizations loc,
    List<MovieModel> suggestions,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('similar'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestedMovie = suggestions[index];
                return MovieCardItem(
                  movie: suggestedMovie,
                  isSmall: true,
                  onTap: () {
                    // صلحنا النافيجيشن هنا وخليناه pushNamed بدل pushReplacementNamed
                    // عشان المستخدم لما يفتح فيلم مقترح يقدر يرجع للفيلم الأصلي بزرار الرجوع من غير ما الصفحة الحالية تضيع
                    Navigator.pushNamed(
                      context,
                      MovieDetailsScreen.routeName,
                      arguments: suggestedMovie,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
