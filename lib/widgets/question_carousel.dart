import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:scrollable/exports.dart';
import '../config/carousel_options.dart';

class QuestionCarousel extends StatelessWidget {
  final List<String> questions;
  final Function(String) onQuestionSelected;

  const QuestionCarousel({
    super.key,
    required this.questions,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    const double carouselItemHeight = 50;
    return ScrollHaptics(
      hapticEffectDuringScroll: HapticType.light,
      distancebetweenHapticEffectsDuringScroll: carouselItemHeight,
      child: CarouselSlider.builder(
        itemCount: questions.length,
        itemBuilder: (context, index, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ElevatedButton(
              onPressed: () => onQuestionSelected(questions[index]),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                minimumSize: const Size.fromHeight(carouselItemHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                questions[index],
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 0,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        options: QuestionsSliderOptions(),
      ),
    );
  }
}
