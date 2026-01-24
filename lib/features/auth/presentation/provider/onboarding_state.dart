import 'package:equatable/equatable.dart';
import 'package:glypha/core/failure/failure.dart';

class OnboardingState extends Equatable {
  final int currentStep;
  final List<String> interests;
  final bool isLoading;
  final AuthFailure? error;

  // New fields for updated onboarding flow
  final String dailyGoal;
  final String learningStyle;

  const OnboardingState({
    this.currentStep = 0,
    this.interests = const [],
    this.isLoading = false,
    this.error,
    this.dailyGoal = '',
    this.learningStyle = '',
  });

  OnboardingState copyWith({
    int? currentStep,
    List<String>? interests,
    bool? isLoading,
    AuthFailure? error,
    String? dailyGoal,
    String? learningStyle,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      interests: interests ?? this.interests,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      learningStyle: learningStyle ?? this.learningStyle,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        interests,
        isLoading,
        error,
        dailyGoal,
        learningStyle,
      ];
}
