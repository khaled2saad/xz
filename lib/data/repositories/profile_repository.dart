import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/movie_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // In-memory cache fallback in case of Firestore permissions / offline
  final Map<int, MovieModel> _localWatchList = {};
  final List<MovieModel> _localHistory = [];

  ProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'guest_user';

  CollectionReference<Map<String, dynamic>> get _watchlistRef =>
      _firestore.collection('users').doc(_userId).collection('watchlist');

  CollectionReference<Map<String, dynamic>> get _historyRef =>
      _firestore.collection('users').doc(_userId).collection('history');

  /// Add movie to watch list
  Future<void> addToWatchList(MovieModel movie) async {
    _localWatchList[movie.id] = movie;
    try {
      await _watchlistRef.doc('${movie.id}').set(movie.toMap());
    } catch (e) {
      debugPrint('Firestore addToWatchList error: $e');
    }
  }

  /// Remove movie from watch list
  Future<void> removeFromWatchList(int movieId) async {
    _localWatchList.remove(movieId);
    try {
      await _watchlistRef.doc('$movieId').delete();
    } catch (e) {
      debugPrint('Firestore removeFromWatchList error: $e');
    }
  }

  /// Toggle watch list
  Future<bool> toggleWatchList(MovieModel movie) async {
    final exists = await isMovieInWatchList(movie.id);
    if (exists) {
      await removeFromWatchList(movie.id);
      return false;
    } else {
      await addToWatchList(movie);
      return true;
    }
  }

  /// Check if movie is in watch list
  Future<bool> isMovieInWatchList(int movieId) async {
    if (_localWatchList.containsKey(movieId)) return true;
    try {
      final doc = await _watchlistRef.doc('$movieId').get();
      return doc.exists;
    } catch (e) {
      return _localWatchList.containsKey(movieId);
    }
  }

  /// Stream of Watchlist from Firestore
  Stream<List<MovieModel>> getWatchListStream() {
    try {
      return _watchlistRef.snapshots().map((snapshot) {
        final list = snapshot.docs
            .map((doc) => MovieModel.fromMap(doc.data()))
            .toList();
        for (final m in list) {
          _localWatchList[m.id] = m;
        }
        return list.isNotEmpty ? list : _localWatchList.values.toList();
      }).handleError((_) => _localWatchList.values.toList());
    } catch (e) {
      return Stream.value(_localWatchList.values.toList());
    }
  }

  /// Add movie to History (called when viewing MovieDetails)
  Future<void> addToHistory(MovieModel movie) async {
    _localHistory.removeWhere((m) => m.id == movie.id);
    _localHistory.insert(0, movie);
    try {
      await _historyRef.doc('${movie.id}').set(movie.toMap());
    } catch (e) {
      debugPrint('Firestore addToHistory error: $e');
    }
  }

  /// Stream of History from Firestore
  Stream<List<MovieModel>> getHistoryStream() {
    try {
      return _historyRef
          .orderBy('savedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs
            .map((doc) => MovieModel.fromMap(doc.data()))
            .toList();
        return list.isNotEmpty ? list : _localHistory;
      }).handleError((_) => _localHistory);
    } catch (e) {
      return Stream.value(_localHistory);
    }
  }
}
