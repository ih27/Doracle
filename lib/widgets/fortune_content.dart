import 'package:flutter/material.dart';
import 'package:typewritertext/typewritertext.dart';
import '../config/theme.dart';

class FortuneContent extends StatelessWidget {
  final TypeWriterController fortuneController;
  final bool isFortuneCompleted;
  final VoidCallback onAskAnother;

  const FortuneContent({
    super.key,
    required this.fortuneController,
    required this.isFortuneCompleted,
    required this.onAskAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: TypeWriter(
                      controller: fortuneController,
                      builder: (context, value) {
                        return SelectionArea(
                          child: Text(
                            value.text,
                            style: AppTheme.dogTextStyle,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isFortuneCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 22),
              child: ElevatedButton(
                onPressed: onAskAnother,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Ask Another Question',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        letterSpacing: 0,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
