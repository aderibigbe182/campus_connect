import 'package:flutter/foundation.dart';

import '../models/message_model.dart';
import '../core/services/message_service.dart';
import '../core/services/socket_service.dart';

class ChatProvider extends ChangeNotifier {

  final MessageService _messageService = MessageService();

  final List<MessageModel> _messages = [];

  List<MessageModel> get messages => _messages;

  bool _loading = false;

  bool get loading => _loading;

  Future<void> loadMessages(

    int conversationId,

  ) async {

    _loading = true;

    notifyListeners();

    try {

      final data = await _messageService.getMessages(

        conversationId,

      );

      _messages

        ..clear()

        ..addAll(data);

    }

    finally {

      _loading = false;

      notifyListeners();

    }

  }

  Future<void> sendMessage({

    required int conversationId,

    required String message,

  }) async {

    final newMessage = await _messageService.sendMessage(

      conversationId: conversationId,

      message: message,

    );

    _messages.add(

      newMessage,

    );
    SocketService.instance.sendMessage(

  {

    "id": newMessage.id,

    "conversation_id": newMessage.conversationId,

    "sender_id": newMessage.senderId,

    "message": newMessage.message,

    "message_type": newMessage.messageType,

    "created_at": newMessage.createdAt.toIso8601String(),

  },

);
    notifyListeners();

  }

void listenForMessages() {

  SocketService.instance.onNewMessage(

    (data) {

      final message = MessageModel.fromJson(

        data,

      );

      final exists = _messages.any(

        (m) => m.id == message.id,

      );

      if (!exists) {

        _messages.add(

          message,

        );

          notifyListeners();

      }

    },

  );

}
void stopListening() {

  SocketService.instance.removeNewMessageListener();
  SocketService.instance.removeDeliveredListener();
  SocketService.instance.removeSeenListener();

}
void listenForDeliveredMessages() {

  SocketService.instance.onMessageDelivered(

    (data) {

      final index = _messages.indexWhere(

        (m) => m.id == data["messageId"],

      );

      if (index != -1) {

        // Will update when we add status fields
        _messages[index] = MessageModel(

  id: _messages[index].id,

  conversationId: _messages[index].conversationId,

  senderId: _messages[index].senderId,

  message: _messages[index].message,

  messageType: _messages[index].messageType,

  edited: _messages[index].edited,

  deleted: _messages[index].deleted,

  createdAt: _messages[index].createdAt,

  delivered: true,

  seen: _messages[index].seen,

);

notifyListeners();

      }

    },

  );

}
void listenForSeenMessages() {

  SocketService.instance.onMessageSeen(

    (data) {

      final index = _messages.indexWhere(

        (m) => m.id == data["messageId"],

      );

      if (index != -1) {

        _messages[index] = MessageModel(

  id: _messages[index].id,

  conversationId: _messages[index].conversationId,

  senderId: _messages[index].senderId,

  message: _messages[index].message,

  messageType: _messages[index].messageType,

  edited: _messages[index].edited,

  deleted: _messages[index].deleted,

  createdAt: _messages[index].createdAt,

  delivered: true,

  seen: true,

);

notifyListeners();

      }

    },

  );

}
}