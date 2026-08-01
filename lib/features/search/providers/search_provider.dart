import 'dart:async';

import 'package:flutter/material.dart';

import '../models/live_search_model.dart';
import '../models/recent_search_model.dart';
import '../models/search_chat_model.dart';
import '../models/search_message_model.dart';
import '../models/search_user_model.dart';
import '../models/suggested_contact_model.dart';

import '../services/search_service.dart';

class SearchProvider extends ChangeNotifier {
  final SearchService _service =
      SearchService.instance;

  bool _loading = false;

  String? _error;

  bool get loading => _loading;

  String? get error => _error;

  Timer? _debounce;

  //====================================
  // SEARCH RESULTS
  //====================================

  List<SearchChatModel> chats = [];

  List<SearchUserModel> users = [];

  List<SearchMessageModel> messages = [];

  List<SearchMessageModel> media = [];

  List<SearchMessageModel> documents = [];

  List<SearchMessageModel> links = [];

  List<SearchMessageModel> dateResults = [];

  List<RecentSearchModel> recentSearches = [];

  List<SuggestedContactModel>
      suggestedContacts = [];

  LiveSearchModel? liveResults;

  //====================================
  // SIMPLE CACHE
  //====================================

  final Map<String, LiveSearchModel>
      _liveCache = {};

  //====================================
  // HELPERS
  //====================================

  void _startLoading() {
    _loading = true;
    _error = null;
    notifyListeners();
  }

  void _stopLoading() {
    _loading = false;
    notifyListeners();
  }

  void _setError(Object e) {
    _loading = false;
    _error = e.toString();
    notifyListeners();
  }

  //====================================
  // SEARCH CHATS
  //====================================

  Future<void> searchChats(
    String query,
  ) async {
    try {
      _startLoading();

      chats =
          await _service.searchChats(
        query: query,
      );

      _stopLoading();
    } catch (e) {
      _setError(e);
    }
  }

  //====================================
  // SEARCH USERS
  //====================================

  Future<void> searchUsers(
    String query,
  ) async {
    try {
      _startLoading();

      users =
          await _service.searchUsers(
        query: query,
      );

      _stopLoading();
    } catch (e) {
      _setError(e);
    }
  }

  //====================================
  // SEARCH MESSAGES
  //====================================

  Future<void> searchMessages(
    String query,
  ) async {
    try {
      _startLoading();

      messages =
          await _service.searchMessages(
        query: query,
      );

      _stopLoading();
    } catch (e) {
      _setError(e);
    }
  }

  //====================================
  // SEARCH MEDIA
  //====================================

  Future<void> searchMedia(
    String query,
  ) async {
    try {
      _startLoading();

      media =
          await _service.searchMedia(
        query: query,
      );

      _stopLoading();
    } catch (e) {
      _setError(e);
    }
  }

  //====================================
  // SEARCH DOCUMENTS
  //====================================

  Future<void> searchDocuments(
    String query,
  ) async {
    try {
      _startLoading();

      documents =
          await _service.searchDocuments(
        query: query,
      );

      _stopLoading();
    } catch (e) {
      _setError(e);
    }
  }

  //====================================
  // SEARCH LINKS
  //====================================

  Future<void> searchLinks(
    String query,
  ) async {
    try {
      _startLoading();

      links =
          await _service.searchLinks(
        query: query,
      );

      _stopLoading();
    } catch (e) {
      _setError(e);
    }
  }

  //====================================
  // SEARCH DATE
  //====================================

  Future<void> searchByDate(
    String date,
  ) async {
    try {
      _startLoading();

      dateResults =
          await _service.searchByDate(
        date: date,
      );

      _stopLoading();
    } catch (e) {
      _setError(e);
    }
  }

  //====================================
  // RECENT SEARCHES
  //====================================

  Future<void> loadRecentSearches() async {
    try {
      recentSearches =
          await _service
              .getRecentSearches();

      notifyListeners();
    } catch (_) {}
  }

  Future<void> addRecentSearch(
    String query,
  ) async {
    await _service.saveRecentSearch(
      searchText: query,
    );

    await loadRecentSearches();
  }

  Future<void> deleteRecentSearch(
    String id,
  ) async {
    await _service
        .deleteRecentSearch(id: id);

    await loadRecentSearches();
  }

  Future<void>
      clearRecentSearches() async {
    await _service
        .clearRecentSearches();

    recentSearches.clear();

    notifyListeners();
  }

  //====================================
  // SUGGESTED CONTACTS
  //====================================

  Future<void>
      loadSuggestedContacts() async {
    try {
      suggestedContacts =
          await _service
              .getSuggestedContacts();

      notifyListeners();
    } catch (_) {}
  }

  //====================================
  // LIVE SEARCH
  //====================================

  Future<void> liveSearch(
    String query,
  ) async {
    if (query.trim().isEmpty) {
      liveResults = null;
      notifyListeners();
      return;
    }

    if (_liveCache.containsKey(query)) {
      liveResults =
          _liveCache[query];

      notifyListeners();
      return;
    }

    try {
      final result =
          await _service.liveSearch(
        query: query,
      );

      _liveCache[query] = result;

      liveResults = result;

      notifyListeners();
    } catch (_) {}
  }

  //====================================
  // DEBOUNCED SEARCH
  //====================================

  void debouncedSearch(
    String query,
  ) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(
        milliseconds: 300,
      ),
      () {
        liveSearch(query);
      },
    );
  }

  //====================================
  // CLEAR RESULTS
  //====================================

  void clear() {
    chats.clear();

    users.clear();

    messages.clear();

    media.clear();

    documents.clear();

    links.clear();

    dateResults.clear();

    liveResults = null;

    _error = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}