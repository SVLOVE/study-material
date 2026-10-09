import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final String language;
  final Set<String> selectedExamCategories;
  final String? targetExam;
  final int? targetYear;
  final String? preparationLevel;

  OnboardingState({
    this.language = 'en',
    this.selectedExamCategories = const {},
    this.targetExam,
    this.targetYear,
    this.preparationLevel,
  });

  OnboardingState copyWith({
    String? language,
    Set<String>? selectedExamCategories,
    String? targetExam,
    int? targetYear,
    String? preparationLevel,
  }) {
    return OnboardingState(
      language: language ?? this.language,
      selectedExamCategories: selectedExamCategories ?? this.selectedExamCategories,
      targetExam: targetExam ?? this.targetExam,
      targetYear: targetYear ?? this.targetYear,
      preparationLevel: preparationLevel ?? this.preparationLevel,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return OnboardingState();
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void toggleExamCategory(String categoryId) {
    final currentCategories = Set<String>.from(state.selectedExamCategories);
    if (currentCategories.contains(categoryId)) {
      currentCategories.remove(categoryId);
    } else {
      currentCategories.add(categoryId);
    }
    state = state.copyWith(selectedExamCategories: currentCategories);
  }

  void setTargetExam(String examId) {
    state = state.copyWith(targetExam: examId);
  }

  void setTargetYear(int year) {
    state = state.copyWith(targetYear: year);
  }

  void setPreparationLevel(String level) {
    state = state.copyWith(preparationLevel: level);
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(() {
  return OnboardingNotifier();
});
