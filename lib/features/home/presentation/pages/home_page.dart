import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glypha/features/home/presentation/widgets/map_view.dart';
import 'package:glypha/features/home/presentation/widgets/topstats_bar.dart';
import 'package:glypha/features/home/presentation/provider/level_provider.dart';
import 'package:glypha/features/home/presentation/provider/progression_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  static const String route = '/home';
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLevel();
    });
  }

  void _scrollToCurrentLevel() {
    if (!_scrollController.hasClients) return;

    // Delay to let the scroll view build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final levelsAsync = ref.read(levelListProvider);
      final progressionMap = ref.read(progressionMapProvider);

      if (!levelsAsync.hasValue || levelsAsync.isLoading) {
        return;
      }
      final dynamicLevels = levelsAsync.value!;

      if (dynamicLevels.isEmpty) return;

      // Find the index of the current level (first incomplete, unlocked level)
      int currentIndex = 0;
      for (int i = 0; i < dynamicLevels.length; i++) {
        final id = dynamicLevels[i].id;
        final prog = progressionMap[id];
        final isCompleted = prog?.isCompleted ?? false;

        if (!isCompleted) {
          currentIndex = i;
          break;
        }
      }

      // Calculate scroll position
      // Levels are rendered bottom-to-top: y = (levels.length - index) * 180 + 50
      // We want to scroll so the current level is visible in the viewport center
      final totalHeight = 180.0 * dynamicLevels.length + 400.0;
      final levelY = (dynamicLevels.length - currentIndex) * 180.0 + 50;

      // Target scroll: position the current level near the center of screen
      final screenHeight = MediaQuery.of(context).size.height;
      final targetScroll = (levelY - screenHeight / 2).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for level data changes to trigger scroll
    ref.listen(levelListProvider, (previous, next) {
      if (next.hasValue && !next.isLoading) {
        // Use a slight delay to ensure layout is ready
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToCurrentLevel();
        });
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          MapView(
            scrollController: _scrollController,
            pulseController: _pulseController,
          ),
          const TopStatsBar(),
        ],
      ),
    );
  }
}
