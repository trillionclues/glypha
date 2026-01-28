import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glypha/app/routes/route_paths.dart';
import 'package:glypha/features/auth/presentation/provider/auth_notifier.dart';
import 'package:glypha/features/auth/presentation/provider/auth_state.dart';
import 'package:glypha/features/auth/presentation/provider/onboarding_notifier.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  static const route = '/onboarding';

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  late ConfettiController _confettiController;

  // Local state for reminder step
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _notificationsEnabled = true;
  bool _showSuccess = false;

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingNotifierProvider.notifier)
          .setLearningStyle(_selectedTime.format(context));
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: const Text('Done',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                    2024, 1, 1, _selectedTime.hour, _selectedTime.minute),
                onDateTimeChanged: (DateTime newTime) {
                  setState(() {
                    _selectedTime = TimeOfDay.fromDateTime(newTime);
                    // Updated state in notifier if needed, usually converted to string
                    ref
                        .read(onboardingNotifierProvider.notifier)
                        .setLearningStyle('${_selectedTime.format(context)}');
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingNotifierProvider);

    ref.watch(authNotifierProvider);
    // Check if to show normal steps or success screen
    if (_showSuccess) {
      return _buildSuccessScreen(theme);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(onboardingState.currentStep, theme),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _GoalStep(formKey: _formKeys[0]),
                      _InterestsStep(formKey: _formKeys[1]),
                      _ReminderStep(
                        selectedTime: _selectedTime,
                        notificationsEnabled: _notificationsEnabled,
                        onTimeTap: _showTimePicker,
                        onToggleNotifications: (val) =>
                            setState(() => _notificationsEnabled = val),
                      ),
                    ],
                  ),
                ),
                _BottomNavigation(
                  currentStep: onboardingState.currentStep,
                  pageController: _pageController,
                  formKeys: _formKeys,
                  onComplete: () {
                    setState(() {
                      _showSuccess = true;
                      _confettiController.play();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(int currentStep, ThemeData theme) {
    const steps = ['Goal', 'Interests', 'Habit'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: [
                if (currentStep > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                      );
                      ref
                          .read(onboardingNotifierProvider.notifier)
                          .previousStep();
                    },
                  ),
                const Spacer(),
                const Spacer(),
                if (currentStep > 0) const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(steps.length, (index) {
              final isActive = index <= currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(ThemeData theme) {
    final onboardingState = ref.watch(onboardingNotifierProvider);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                            size: 60, color: theme.colorScheme.primary)
                        .animate()
                        .scale(duration: 500.ms, curve: Curves.elasticOut),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "You're all set!",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade().slideY(begin: 0.5, end: 0),
                  const SizedBox(height: 16),
                  Text(
                    'Your journey to self-mastery begins now.\nRemember: progress, not perfection.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.5, end: 0),
                  const Spacer(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SummaryIcon(
                          icon: Icons.check_circle_outline,
                          label: 'Daily check-ins',
                          theme: theme),
                      const SizedBox(width: 24),
                      _SummaryIcon(
                          icon: Icons.book_outlined,
                          label: 'Learning',
                          theme: theme),
                      const SizedBox(width: 24),
                      _SummaryIcon(
                          icon: Icons.insights,
                          label: 'AI Insights',
                          theme: theme),
                    ],
                  ).animate().fade(delay: 400.ms),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onboardingState.isLoading
                          ? null
                          : () {
                              final authState = ref.read(authNotifierProvider);
                              if (authState is AuthAuthenticated) {
                                ref
                                    .read(onboardingNotifierProvider.notifier)
                                    .completeOnboarding(authState.user.id)
                                    .then((success) {
                                  if (success && context.mounted) {
                                    context.goNamed(AppRoute.home.name);
                                  } else if (!success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Failed to save details. Please try again.')),
                                    );
                                  }
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Error: User not authenticated')),
                                );
                              }
                            },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                      child: onboardingState.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Let's go",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ).animate().fade(delay: 600.ms).slideY(begin: 1, end: 0),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 20,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _SummaryIcon(
      {required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7)),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _GoalStep extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  const _GoalStep({required this.formKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            "What's your main goal?",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize your daily challenges.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                  duration: 2000.ms,
                  delay: 1000.ms,
                  color: theme.colorScheme.primary.withOpacity(0.2)),
          const SizedBox(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _Goals.all.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final goal = _Goals.all[index];
              return _SelectableCard(
                title: goal.title,
                subtitle: goal.subtitle,
                icon: goal.icon,
                isSelected: onboardingState.dailyGoal == goal.title,
                onTap: () {
                  ref
                      .read(onboardingNotifierProvider.notifier)
                      .setDailyGoal(goal.title);
                },
              )
                  .animate()
                  .fade(delay: (100 * index).ms)
                  .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
            },
          ),
        ],
      ).animate().fade().slideY(begin: 0.1, end: 0),
    );
  }
}

class _InterestsStep extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  const _InterestsStep({required this.formKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Pick your favorite topics',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select at least 2 subjects you want to master.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                  duration: 2000.ms,
                  delay: 1000.ms,
                  color: theme.colorScheme.primary.withOpacity(0.2)),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _Interests.all.asMap().entries.map((entry) {
              final index = entry.key;
              final interest = entry.value;
              final isSelected = onboardingState.interests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (_) {
                  ref
                      .read(onboardingNotifierProvider.notifier)
                      .toggleInterest(interest);
                },
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ).animate().fade(delay: (30 * index).ms).scale(
                  begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
            }).toList(),
          ),
        ],
      ).animate().fade().slideY(begin: 0.1, end: 0),
    );
  }
}

class _ReminderStep extends StatelessWidget {
  final TimeOfDay selectedTime;
  final bool notificationsEnabled;
  final VoidCallback onTimeTap;
  final ValueChanged<bool> onToggleNotifications;

  const _ReminderStep({
    required this.selectedTime,
    required this.notificationsEnabled,
    required this.onTimeTap,
    required this.onToggleNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Set your daily reminder',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A gentle nudge to check in with yourself. Consistency is key.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                  duration: 2000.ms,
                  delay: 1000.ms,
                  color: theme.colorScheme.primary.withOpacity(0.2)),
          const SizedBox(height: 48),
          Center(
            child: GestureDetector(
              onTap: onTimeTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Icon(Icons.notifications_active,
                            size: 32, color: theme.colorScheme.primary)
                        .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true))
                        .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.2, 1.2),
                            duration: 1000.ms,
                            curve: Curves.easeInOut)
                        .then()
                        .shake(hz: 4, curve: Curves.easeInOut),
                    const SizedBox(height: 16),
                    Text(
                      selectedTime.format(context),
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to change',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ).animate().scale(curve: Curves.easeOutBack),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.notifications_none, color: Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily notifications',
                          style: theme.textTheme.titleMedium),
                      Text('You\'ll get a gentle reminder',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: notificationsEnabled,
                  onChanged: onToggleNotifications,
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ).animate().slideY(begin: 1, end: 0, delay: 200.ms),
        ],
      ).animate().fade(),
    );
  }
}

class _BottomNavigation extends ConsumerWidget {
  final int currentStep;
  final PageController pageController;
  final List<GlobalKey<FormState>> formKeys;
  final VoidCallback onComplete;

  const _BottomNavigation({
    required this.currentStep,
    required this.pageController,
    required this.formKeys,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    bool canProceed() {
      return ref
          .read(onboardingNotifierProvider.notifier)
          .canProceedFromStep(currentStep);
    }

    void handleNext() {
      if (canProceed()) {
        if (currentStep < 2) {
          pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
          );
          ref.read(onboardingNotifierProvider.notifier).nextStep();
        } else {
          onComplete();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Please make a selection to continue'),
              backgroundColor: theme.colorScheme.error),
        );
      }
    }

    void handleSkip() async {
      final user = authState is AuthAuthenticated ? authState.user : null;
      if (user != null) {
        // Mark onboarding as complete and navigate to Home (or Success screen if we want)
        // if user asked for "Skip for now" to just go.
        // We can call completeOnboarding immediately and navigate.
        final success = await ref
            .read(onboardingNotifierProvider.notifier)
            .completeOnboarding(user.id);
        if (success && context.mounted) {
          context.goNamed(AppRoute.home.name);
        }
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onboardingState.isLoading ? null : handleNext,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: onboardingState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(
                      currentStep < 2 ? 'Continue' : 'I\'m ready',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onboardingState.isLoading ? null : handleSkip,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onBackground.withOpacity(0.5),
            ),
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }
}

class _Goal {
  final String title;
  final String subtitle;
  final IconData icon;
  const _Goal(
      {required this.title, required this.subtitle, required this.icon});
}

class _Goals {
  static const all = [
    _Goal(
        title: 'Learn New Skills',
        subtitle: 'Master new topics efficiently',
        icon: Icons.lightbulb_outline),
    _Goal(
        title: 'Build Daily Habits',
        subtitle: 'Consistency is key to success',
        icon: Icons.calendar_today),
    _Goal(
        title: 'Expand Knowledge',
        subtitle: 'Explore diverse subjects daily',
        icon: Icons.menu_book),
  ];
}

class _Interests {
  static const all = [
    'Technology',
    'Science',
    'History',
    'Art',
    'Music',
    'Business',
    'Psychology',
    'Philosophy',
    'Literature',
    'Economics',
    'Politics',
    'Health',
    'Sports',
    'Travel'
  ];
}

class _SelectableCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.05)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ).animate(target: isSelected ? 1 : 0).shimmer(
                        duration: 1200.ms,
                        color: theme.colorScheme.primary.withOpacity(0.3)),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }
}
