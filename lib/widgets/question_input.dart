import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'sendable_textfield.dart';

class QuestionInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSubmitted;
  final int remainingQuestions;
  final bool isSubscribed;
  final VoidCallback? onShowOutOfQuestions;

  const QuestionInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.remainingQuestions,
    required this.isSubscribed,
    this.onShowOutOfQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onShowOutOfQuestions,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: AppTheme.accent1,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Center(
                  child: Text(
                    isSubscribed ? '∞' : remainingQuestions.toString(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: SendableTextField(
                controller: controller,
                focusNode: focusNode,
                labelText: 'Ask what you want, passenger?',
                onSubmitted: onSubmitted,
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              icon: Icon(Icons.send_rounded,
                  color: Theme.of(context).primaryColor),
              onPressed: () => onSubmitted(controller.text),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.accent1,
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
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
