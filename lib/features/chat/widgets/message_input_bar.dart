import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  bool _showEmoji = false;
  bool get _hasText => _controller.text.trim().isNotEmpty;
@override
void initState() {
  super.initState();

  _controller.addListener(() {
    setState(() {});
  });
}

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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
                    onPressed: () {},
                    icon: const Icon(
                      Icons.attach_file,
                    ),
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
                        : IconButton(
                            key: const ValueKey("mic"),
                            onPressed: () {
                              HapticFeedback.lightImpact();

                              // TODO: Start voice recording
                            },
                            icon: const Icon(Icons.mic),
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