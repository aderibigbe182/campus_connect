import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '/core/constants/api_constants.dart';
import '../../models/story/models.dart';
import 'storage_service.dart';

class StoryService {
  StoryService._();

  static final StoryService instance =
      StoryService._();

  String get _baseUrl =>
      ApiConstants.baseUrl;

  Future<String?> _getToken() async {
    return StorageService.getToken();
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null)
        'Authorization': 'Bearer $token',
    };
  }
Future<StoryModel> uploadStory({
  required File file,
  required String mediaType,
  String? caption,
}) async {
  final token = await _getToken();

  if (token == null) {
    throw Exception("User is not authenticated.");
  }

  final request = http.MultipartRequest(
    'POST',
    Uri.parse(
      '$_baseUrl/api/stories',
    ),
  );

  request.headers.addAll({
    'Authorization': 'Bearer $token',
  });

  request.fields['media_type'] =
      mediaType;

  if (caption != null &&
      caption.trim().isNotEmpty) {
    request.fields['caption'] =
        caption.trim();
  }

  request.files.add(
    await http.MultipartFile.fromPath(
      'media',
      file.path,
    ),
  );

  final streamedResponse =
      await request.send();

  final response =
      await http.Response.fromStream(
    streamedResponse,
  );

  if (response.statusCode == 201) {
    final json =
        jsonDecode(response.body);

    return StoryModel.fromJson(json);
  }

  throw Exception(
    'Failed to upload story: ${response.body}',
  );
}
Future<List<StoryModel>> fetchStories() async {
  final headers = await _headers();

  final response = await http.get(
    Uri.parse(
      '$_baseUrl/api/stories',
    ),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final List<dynamic> json =
        jsonDecode(response.body);

    return json
        .map(
          (story) => StoryModel.fromJson(
            story,
          ),
        )
        .toList();
  }

  throw Exception(
    'Failed to fetch stories.',
  );
}
Future<List<StoryModel>> fetchMyStories() async {
  final headers = await _headers();

  final response = await http.get(
    Uri.parse(
      '$_baseUrl/api/stories/me',
    ),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final List<dynamic> json =
        jsonDecode(response.body);

    return json
        .map(
          (story) => StoryModel.fromJson(
            story,
          ),
        )
        .toList();
  }

  throw Exception(
    'Failed to fetch your stories.',
  );
}
Future<void> deleteStory(
  int storyId,
) async {
  final headers = await _headers();

  final response = await http.delete(
    Uri.parse(
      '$_baseUrl/api/stories/$storyId',
    ),
    headers: headers,
  );

  if (response.statusCode == 200 ||
      response.statusCode == 204) {
    return;
  }

  throw Exception(
    'Failed to delete story: ${response.body}',
  );
}
Future<void> markStoryViewed(
  int storyId,
) async {
  final headers = await _headers();

  final response = await http.post(
    Uri.parse(
      '$_baseUrl/api/stories/$storyId/view',
    ),
    headers: headers,
  );

  if (response.statusCode == 200 ||
      response.statusCode == 201 ||
      response.statusCode == 204) {
    return;
  }

  throw Exception(
    'Failed to mark story as viewed: ${response.body}',
  );
}
Future<StoryReplyModel> replyToStory({
  required int storyId,
  required String message,
}) async {
  final headers = await _headers();

  final response = await http.post(
    Uri.parse(
      '$_baseUrl/api/stories/$storyId/reply',
    ),
    headers: headers,
    body: jsonEncode({
      'message': message.trim(),
    }),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 201) {
    final json =
        jsonDecode(response.body);

    return StoryReplyModel.fromJson(json);
  }

  throw Exception(
    'Failed to send reply: ${response.body}',
  );
}
Future<List<StoryReplyModel>>
    fetchStoryReplies(
  int storyId,
) async {
  final headers = await _headers();

  final response = await http.get(
    Uri.parse(
      '$_baseUrl/api/stories/$storyId/replies',
    ),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final List<dynamic> json =
        jsonDecode(response.body);

    return json
        .map(
          (reply) =>
              StoryReplyModel.fromJson(
            reply,
          ),
        )
        .toList();
  }

  throw Exception(
    'Failed to load replies.',
  );
}
Future<StoryReactionModel> reactToStory({
  required int storyId,
  required String reaction,
}) async {
  final headers = await _headers();

  final response = await http.post(
    Uri.parse(
      '$_baseUrl/api/stories/$storyId/react',
    ),
    headers: headers,
    body: jsonEncode({
      'reaction': reaction,
    }),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 201) {
    final json = jsonDecode(response.body);

    return StoryReactionModel.fromJson(json);
  }

  throw Exception(
    'Failed to send reaction: ${response.body}',
  );
}
Future<List<StoryReactionModel>>
    fetchStoryReactions(
  int storyId,
) async {
  final headers = await _headers();

  final response = await http.get(
    Uri.parse(
      '$_baseUrl/api/stories/$storyId/reactions',
    ),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final List<dynamic> json =
        jsonDecode(response.body);

    return json
        .map(
          (reaction) =>
              StoryReactionModel.fromJson(
            reaction,
          ),
        )
        .toList();
  }

  throw Exception(
    'Failed to load story reactions.',
  );
}
Future<List<StoryViewerModel>>
    fetchStoryViewers(
  int storyId,
) async {
  final headers = await _headers();

  final response = await http.get(
    Uri.parse(
      '$_baseUrl/api/stories/$storyId/viewers',
    ),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final List<dynamic> json =
        jsonDecode(response.body);

    return json
        .map(
          (viewer) =>
              StoryViewerModel.fromJson(
            viewer,
          ),
        )
        .toList();
  }

  throw Exception(
    'Failed to load story viewers: ${response.body}',
  );
}
Future<void> archiveStory(
  int storyId,
) async {
  final headers = await _headers();

  final response = await http.post(
    Uri.parse(
      '$_baseUrl/api/stories/$storyId/archive',
    ),
    headers: headers,
  );

  if (response.statusCode == 200 ||
      response.statusCode == 204) {
    return;
  }

  throw Exception(
    'Failed to archive story: ${response.body}',
  );
}
Future<void> restoreArchivedStory(
  int storyId,
) async {
  final headers = await _headers();

  final response = await http.post(
    Uri.parse(
      '$_baseUrl/api/stories/$storyId/restore',
    ),
    headers: headers,
  );

  if (response.statusCode == 200 ||
      response.statusCode == 204) {
    return;
  }

  throw Exception(
    'Failed to restore story: ${response.body}',
  );
}
Future<List<StoryModel>>
    fetchArchivedStories() async {
  final headers = await _headers();

  final response = await http.get(
    Uri.parse(
      '$_baseUrl/api/stories/archive',
    ),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final List<dynamic> json =
        jsonDecode(response.body);

    return json
        .map(
          (story) =>
              StoryModel.fromJson(story),
        )
        .toList();
  }

  throw Exception(
    'Failed to fetch archived stories: ${response.body}',
  );
}
}