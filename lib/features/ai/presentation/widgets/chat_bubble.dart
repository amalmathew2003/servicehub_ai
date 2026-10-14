
import 'package:flutter/material.dart';
import 'package:service_hub_ai/core/theme/app_colors.dart';
import 'package:service_hub_ai/features/ai/presentation/models/chat_message.dart';
import 'package:service_hub_ai/features/ai/presentation/widgets/staff_result_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: message.isAi
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(message.isAi ? 4 : 18),
            bottomRight: Radius.circular(message.isAi ? 18 : 4),
          ),
          border: message.isAi
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (message.staff.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...message.staff.map(
                (staff) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: StaffResultCard(staff: staff),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
