import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:image_picker/image_picker.dart';
import '../widgets/attachment_sheet.dart';


class MessageInputBar extends StatefulWidget {
  final Future<void> Function(String message)? onSend;

  const MessageInputBar({
    super.key,
    this.onSend,
  });

  @override
  State<MessageInputBar> createState() =>
      _MessageInputBarState();
}
class _MessageInputBarState
    extends State<MessageInputBar> {
  final TextEditingController _controller =
      TextEditingController();

  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  bool _showEmoji = false;
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _timer;
  bool get _hasText => _controller.text.trim().isNotEmpty;
  Future<void> _pickFromGallery() async {
  final file = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );

  if (file == null) return;

  debugPrint(file.path);

  // Backend upload comes later.
}
Future<void> _pickFromCamera() async {
  final file = await _picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 85,
  );

  if (file == null) return;

  debugPrint(file.path);

  // Backend upload comes later.
}
@override
void initState() {
  super.initState();

  _controller.addListener(() {
    setState(() {});
  });
}
void _startRecording() {
  HapticFeedback.mediumImpact();

  setState(() {
    _isRecording = true;
    _recordDuration = Duration.zero;
  });

  _timer?.cancel();

  _timer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {
      setState(() {
        _recordDuration +=
            const Duration(seconds: 1);
      });
    },
  );
}
void _stopRecording() {
  _timer?.cancel();

  HapticFeedback.lightImpact();

  final duration = _recordDuration;

  setState(() {
    _isRecording = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "Voice message recorded (${_formatRecordingTime()})",
      ),
    ),
  );

  // Later we'll upload the audio here.
}
String _formatRecordingTime() {
  final minutes =
      _recordDuration.inMinutes
          .toString()
          .padLeft(2, "0");

  final seconds =
      (_recordDuration.inSeconds % 60)
          .toString()
          .padLeft(2, "0");

  return "$minutes:$seconds";
}
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (_) {
      return AttachmentSheet(
        onGallery: _pickFromGallery,
        onCamera: _pickFromCamera,
        onDocument: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Documents coming soon"),
            ),
          );
        },
        onLocation: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Location sharing coming soon"),
            ),
          );
        },
        onContact: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Contact sharing coming soon"),
            ),
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showEmoji,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showEmoji) {
          setState(() {
            _showEmoji = false;
          });
        }
      },
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isRecording)
              Container(
                margin: const EdgeInsets.only(
                  bottom: 8,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Row(
                  children: [

                    const Icon(
                      Icons.fiber_manual_record,
                      color: Colors.red,
                      size: 14,
                    ),

                    const SizedBox(width: 10),

                    Text(
                      _formatRecordingTime(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 20),

                    const Expanded(
                      child: Text(
                        "← Slide to cancel",
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _toggleEmojiKeyboard,
                    icon: Icon(
                      _showEmoji
                          ? Icons.keyboard
                          : Icons
                              .emoji_emotions_outlined,
                    ),
                  ),

                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textCapitalization:
                        TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 5,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() {
                            _showEmoji = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText:
                            "Type a message...",
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            25,
                          ),
                          borderSide:
                              BorderSide.none,
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
          onPressed: () async {
            HapticFeedback.lightImpact();

            final text = _controller.text.trim();

            if (text.isEmpty) return;

            if (widget.onSend != null) {
              await widget.onSend!(text);
            }

            _controller.clear();
            
          },
          icon: const Icon(
            Icons.send,
            color: Colors.blue,
          ),
        )
      : GestureDetector(
          key: const ValueKey("mic"),
          onLongPressStart: (_) {
            _startRecording();
          },
          onLongPressEnd: (_) {
            _stopRecording();
          },
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.mic),
          ),
        ),
),
                ],
              ),
            ),

            if (_showEmoji)
              SizedBox(
                height: 320,
                child: EmojiPicker(
                  textEditingController:
                      _controller,
                  config: Config(
                    height: 320,
                    checkPlatformCompatibility:
                        true,
                    emojiViewConfig:
                        const EmojiViewConfig(
                      emojiSizeMax: 28,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}