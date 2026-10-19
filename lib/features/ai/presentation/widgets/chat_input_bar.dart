
import 'package:flutter/material.dart';
import 'package:service_hub_ai/core/theme/app_colors.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final bool isLoading;
  final VoidCallback onMicPressed;
  final VoidCallback onSendPressed;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isListening,
    required this.isLoading,
    required this.onMicPressed,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.send,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: isListening
                        ? 'Listening...'
                        : 'Tell me what you need...',
                    hintStyle: TextStyle(
                      color: isListening
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.45),
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) {
                    if (!isLoading) onSendPressed();
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isListening
                    ? Colors.redAccent
                    : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onMicPressed,
                icon: Icon(
                  isListening
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: isLoading ? null : onSendPressed,
                icon: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
