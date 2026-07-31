import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/reply_message_model.dart';
import 'reply_preview.dart';
import 'selected_media_preview.dart';

class MessageInputBar extends StatefulWidget {
  final Future<void> Function(String message) onSendText;
  final Future<void> Function(File image, String? caption) onSendImage;
  final Future<void> Function(File file) onSendFile;
  final Future<void> Function(File audio) onSendVoice;

  final ReplyMessageModel? reply;
  final VoidCallback onCancelReply;

  final bool visible;

  const MessageInputBar({
    super.key,
    required this.onSendText,
    required this.onSendImage,
    required this.onSendFile,
    required this.onSendVoice,
    required this.reply,
    required this.onCancelReply,
    this.visible = true,
  });

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

  File? _selectedImage;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (!mounted) return;

      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
    Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
      _selectedFile = null;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    setState(() {
      _selectedFile = result.files.single;
      _selectedImage = null;
    });
  }

  Future<void> _sendMessage() async {
    if (_sending) return;

    final text = _controller.text.trim();

    if (text.isEmpty &&
        _selectedImage == null &&
        _selectedFile == null) {
      return;
    }

    setState(() => _sending = true);

    try {
      if (_selectedImage != null) {
        await widget.onSendImage(
          _selectedImage!,
          text.isEmpty ? null : text,
        );

        _selectedImage = null;
      } else if (_selectedFile != null) {
        await widget.onSendFile(
          File(_selectedFile!.path!),
        );

        _selectedFile = null;
      } else {
        await widget.onSendText(text);
      }

      _controller.clear();
      widget.onCancelReply();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
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
                leading: const Icon(Icons.image),
                title: const Text("Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text("Document"),
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
    setState(() => _isRecording = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.reply != null)
            ReplyPreview(
              reply: widget.reply!,
              onCancel: widget.onCancelReply,
            ),

          if (_selectedImage != null)
            SelectedMediaPreview(
              image: _selectedImage!,
              onRemove: () {
                setState(() {
                  _selectedImage = null;
                  _selectedFile = null;
                });
              },
            ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _toggleEmojiKeyboard,
                  icon: const Icon(Icons.emoji_emotions_outlined),
                ),

                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: _showAttachmentSheet,
                  icon: const Icon(Icons.attach_file),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _hasText
                      ? IconButton(
                          key: const ValueKey("send"),
                          onPressed: _sending ? null : _sendMessage,
                          icon: const Icon(Icons.send),
                        )
                      : IconButton(
                          key: const ValueKey("mic"),
                          onPressed: () {
                            if (_isRecording) {
                              // completed in 17D
                            } else {
                              _startRecording();
                            }
                          },
                          icon: Icon(
                            _isRecording
                                ? Icons.stop_circle
                                : Icons.mic,
                          ),
                        ),
                ),
              ],
            ),
          ),
                    if (_showEmoji)
            SizedBox(
              height: 280,
              child: Center(
                child: Text(
                  'Emoji Picker Here',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}