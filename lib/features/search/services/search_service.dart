import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';

import '../models/live_search_model.dart';
import '../models/recent_search_model.dart';
import '../models/search_chat_model.dart';
import '../models/search_message_model.dart';
import '../models/search_user_model.dart';
import '../models/suggested_contact_model.dart';

class SearchService {
  SearchService._();

  static final SearchService instance =
      SearchService._();

  String get _baseUrl =>
      ApiConstants.baseUrl;

  Future<Map<String, String>> _headers() async {
    final token =
        await StorageService.getToken();

    return {
      "Content-Type":
          "application/json",
      "Accept":
          "application/json",
      if (token != null)
        "Authorization":
            "Bearer $token",
    };
  }

  //====================================
  // SEARCH CHATS
  //====================================

  Future<List<SearchChatModel>>
      searchChats({
    required String query,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/api/search/chats?query=${Uri.encodeComponent(query)}",
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to search chats",
      );
    }

    final json =
        jsonDecode(response.body);

    final List data =
        json["chats"] ?? [];

    return data
        .map(
          (e) =>
              SearchChatModel.fromJson(e),
        )
        .toList();
  }

  //====================================
  // SEARCH USERS
  //====================================

  Future<List<SearchUserModel>>
      searchUsers({
    required String query,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/api/search/users?query=${Uri.encodeComponent(query)}",
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to search users",
      );
    }

    final json =
        jsonDecode(response.body);

    final List data =
        json["users"] ?? [];

    return data
        .map(
          (e) =>
              SearchUserModel.fromJson(e),
        )
        .toList();
  }

  //====================================
  // SEARCH MESSAGES
  //====================================

  Future<List<SearchMessageModel>>
      searchMessages({
    required String query,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/api/search/messages?query=${Uri.encodeComponent(query)}",
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to search messages",
      );
    }

    final json =
        jsonDecode(response.body);

    final List data =
        json["messages"] ?? [];

    return data
        .map(
          (e) =>
              SearchMessageModel.fromJson(e),
        )
        .toList();
  }

  //====================================
  // SEARCH MEDIA
  //====================================

  Future<List<SearchMessageModel>>
      searchMedia({
    required String query,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/api/search/media?query=${Uri.encodeComponent(query)}",
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to search media",
      );
    }

    final json =
        jsonDecode(response.body);

    final List data =
        json["media"] ?? [];

    return data
        .map(
          (e) =>
              SearchMessageModel.fromJson(e),
        )
        .toList();
  }

  //====================================
  // SEARCH DOCUMENTS
  //====================================

  Future<List<SearchMessageModel>>
      searchDocuments({
    required String query,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/api/search/documents?query=${Uri.encodeComponent(query)}",
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to search documents",
      );
    }

    final json =
        jsonDecode(response.body);

    final List data =
        json["documents"] ?? [];

    return data
        .map(
          (e) =>
              SearchMessageModel.fromJson(e),
        )
        .toList();
  }

  //====================================
  // SEARCH LINKS
  //====================================

  Future<List<SearchMessageModel>>
      searchLinks({
    required String query,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/api/search/links?query=${Uri.encodeComponent(query)}",
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to search links",
      );
    }

    final json =
        jsonDecode(response.body);

    final List data =
        json["links"] ?? [];

    return data
        .map(
          (e) =>
              SearchMessageModel.fromJson(e),
        )
        .toList();
  }

  //====================================
  // SEARCH BY DATE
  //====================================

  Future<List<SearchMessageModel>>
      searchByDate({
    required String date,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/api/search/date?date=$date",
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to search by date",
      );
    }

    final json =
        jsonDecode(response.body);

    final List data =
        json["messages"] ?? [];

    return data
        .map(
          (e) =>
              SearchMessageModel.fromJson(e),
        )
        .toList();
  }

  //====================================
  // RECENT SEARCHES
  //====================================

  Future<List<RecentSearchModel>>
      getRecentSearches() async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/api/search/recent",
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load recent searches",
      );
    }

    final json =
        jsonDecode(response.body);

    final List data =
        json["recentSearches"] ?? [];

    return data
        .map(
          (e) => RecentSearchModel.fromJson(e),
        )
        .toList();
  }

  Future<void> saveRecentSearch({
    required String searchText,
  }) async {
    final response = await http.post(
      Uri.parse(
        "$_baseUrl/api/search/recent",
      ),
      headers: await _headers(),
      body: jsonEncode({
        "searchText": searchText,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        "Failed to save recent search",
      );
    }
  }

  Future<void> deleteRecentSearch({
    required String id,
  }) async {
    final response = await http.delete(
      Uri.parse(
        "$_baseUrl/api/search/recent/$id",
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to delete recent search",
      );
    }
  }

  Future<void>
      clearRecentSearches() async {
    final response = await http.delete(
      Uri.parse(
        "$_baseUrl/api/search/recent",
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to clear recent searches",
      );
    }
  }

  //====================================
  // SUGGESTED CONTACTS
  //====================================

  Future<List<SuggestedContactModel>>
      getSuggestedContacts() async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/api/search/suggested-contacts",
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load suggested contacts",
      );
    }

    final json =
        jsonDecode(response.body);

    final List data =
        json["contacts"] ?? [];

    return data
        .map(
          (e) =>
              SuggestedContactModel.fromJson(
                  e),
        )
        .toList();
  }

  //====================================
  // LIVE SEARCH
  //====================================

  Future<LiveSearchModel> liveSearch({
    required String query,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/api/search/live?query=${Uri.encodeComponent(query)}",
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to perform live search",
      );
    }

    return LiveSearchModel.fromJson(
      jsonDecode(response.body),
    );
  }
}