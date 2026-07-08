import 'package:flutter/foundation.dart';

import '../models/conversation_model.dart';
import '../core/services/conversation_service.dart';

class ConversationProvider extends ChangeNotifier {

  final ConversationService _service =
      ConversationService();

  List<ConversationModel> conversations = [];

  bool loading = false;

  Future<void> loadConversations() async {

    loading = true;

    notifyListeners();

    conversations = await _service.getConversations();

    loading = false;

    notifyListeners();

  }

}