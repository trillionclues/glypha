import 'package:glypha/core/failure/failure.dart';
import 'package:glypha/core/services/auth_service.dart';
import 'package:glypha/features/auth/presentation/provider/onboarding_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_notifier.g.dart';

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  // void setPhoneNumber(String phoneNumber) {
  //   state = state.copyWith(phoneNumber: phoneNumber);
  // }

  // void setEducationLevel(String level) {
  //   state = state.copyWith(educationLevel: level);
  // }

  void setDailyGoal(String goal) {
    state = state.copyWith(dailyGoal: goal);
  }

  void setLearningStyle(String style) {
    state = state.copyWith(learningStyle: style);
  }

  void toggleInterest(String interest) {
    final interests = List<String>.from(state.interests);
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
    state = state.copyWith(interests: interests);
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<bool> submitDetails(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateAdditionalDetails(
        userId: userId,
        interests: state.interests.isEmpty ? null : state.interests,
        dailyGoal: state.dailyGoal.isEmpty ? null : state.dailyGoal,
        learningStyle: state.learningStyle.isEmpty ? null : state.learningStyle,
      );

      state = state.copyWith(isLoading: false);
      return true;
    } on AuthFailure catch (failure) {
      state = state.copyWith(isLoading: false, error: failure);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: const AuthFailure.serverError(),
      );
      return false;
    }
  }

  Future<bool> completeOnboarding(String userId) async {
    return submitDetails(userId);
  }

  bool canProceedFromStep(int step) {
    switch (step) {
      case 0:
        return state.dailyGoal.isNotEmpty;
      case 1:
        return state.interests.isNotEmpty;
      case 2:
        return state.learningStyle.isNotEmpty; // Represents habit/time choice
      default:
        return false;
    }
  }
}
