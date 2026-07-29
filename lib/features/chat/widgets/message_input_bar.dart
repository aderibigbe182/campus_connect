import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message_model.dart';

class MessageInputBar extends StatefulWidget {
  const MessageInputBar({
    super.key,
    required this.onSend,
    required this.onImageSelected,
    required this.onFileSelected,
    required this.replyingTo,
    required this.onCancelReply,
    required this.onTyping,
    required this.onStopTyping,
    this.enabled = true,
  });

  final Future<void> Function(String message) onSend;

  final Future<void> Function(File image) onImageSelected;

  final Future<void> Function(File file) onFileSelected;

  final ReplyMessageModel? replyingTo;

  final VoidCallback onCancelReply;

  final VoidCallback onTyping;

  final VoidCallback onStopTyping;

  final bool enabled;

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _controller = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  final ImagePicker _picker = ImagePicker();

  bool _hasText = false;

  bool _sending = false;

  bool _showEmoji = false;

  bool _isRecording = false;

  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();

    _controller.removeListener(_onTextChanged);

    _controller.dispose();

    _focusNode.dispose();

    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;

    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }

    widget.onTyping();

    _typingTimer?.cancel();

    _typingTimer = Timer(
      const Duration(seconds: 2),
      () {
        widget.onStopTyping();
      },
    );
  }

  Future<void> _pickImage() async {}

  Future<void> _pickFile() async {}

  Future<void> _sendMessage() async {}

  void _toggleEmojiKeyboard() {}

  void _showAttachmentSheet() {}

  Future<void> _startRecording() async {}

  Future<void> _stopRecording() async {}
}
Future<void> _pickImage() async {
  try {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    await widget.onImageSelected(
      File(image.path),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to select image.\n$e',
        ),
      ),
    );
  }
}

Future<void> _pickFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );

    if (result == null) return;

    final path = result.files.single.path;

    if (path == null) return;

    await widget.onFileSelected(
      File(path),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to select file.\n$e',
        ),
      ),
    );
  }
}

Future<void> _sendMessage() async {
  final text = _controller.text.trim();

  if (text.isEmpty || _sending) return;

  setState(() {
    _sending = true;
  });

  try {
    await widget.onSend(text);

    _controller.clear();

    widget.onStopTyping();
  } finally {
    if (mounted) {
      setState(() {
        _sending = false;
      });
    }
  }
}

void _toggleEmojiKeyboard() {
  if (_showEmoji) {
    _focusNode.requestFocus();
  } else {
    _focusNode.unfocus();
  }

  setState(() {
    _showEmoji = !_showEmoji;
  });
}

void _showAttachmentSheet() {
  showModalBottomSheet(
    context: context,
    builder: (_) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _startRecording() async {
  setState(() {
    _isRecording = true;
  });
}

Future<void> _stopRecording() async {
  setState(() {
    _isRecording = false;
  });
}
@override
Widget build(BuildContext context) {
  return SafeArea(
    top: false,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.replyingTo != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.replyingTo!.senderName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.replyingTo!.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancelReply,
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _toggleEmojiKeyboard,
                icon: Icon(
                  _showEmoji
                      ? Icons.keyboard
                      : Icons.emoji_emotions_outlined,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  minLines: 1,
                  maxLines: 6,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(24),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.attach_file,
                      ),
                      onPressed:
                          _showAttachmentSheet,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 200),
                child: _hasText
                    ? FloatingActionButton(
                        key: const ValueKey(
                          'send',
                        ),
                        mini: true,
                        elevation: 0,
                        onPressed: _sending
                            ? null
                            : _sendMessage,
                        child: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send,
                              ),
                      )
                    : FloatingActionButton(
                        key: const ValueKey(
                          'mic',
                        ),
                        mini: true,
                        elevation: 0,
                        onPressed: _isRecording
                            ? _stopRecording
                            : _startRecording,
                        child: Icon(
                          _isRecording
                              ? Icons.stop
                              : Icons.mic,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}