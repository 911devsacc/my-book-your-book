import 'package:flutter/material.dart';
import '../constants/styles.dart';
import '../constants/strings.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingSmall.left,
        right: AppDimensions.paddingSmall.right,
        top: AppDimensions.paddingSmall.top,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.paddingSmall.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: AppDecorations.inputDecoration,
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: Strings.typeMessage,
                  border: InputBorder.none,
                  contentPadding: AppDimensions.padding,
                ),
                maxLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSmall),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.background),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}
