import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:glypha/features/home/presentation/widgets/nav_item.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const borderRadius = BorderRadius.vertical(top: Radius.circular(20));

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.85),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    NavItem(
                      icon: Icons.map_outlined,
                      activeIcon: Icons.map_rounded,
                      label: 'Map',
                      isActive: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    NavItem(
                      icon: Icons.school_outlined,
                      activeIcon: Icons.school_rounded,
                      label: 'Lessons',
                      isActive: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                    NavItem(
                      icon: Icons.leaderboard_outlined,
                      activeIcon: Icons.leaderboard_rounded,
                      label: 'Leaderboard',
                      isActive: currentIndex == 2,
                      onTap: () => onTap(2),
                    ),
                    NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      isActive: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),
                    // NavItem(
                    //   icon: Icons.settings_outlined,
                    //   activeIcon: Icons.settings_rounded,
                    //   label: 'Settings',
                    //   isActive: currentIndex == 4,
                    //   onTap: () => onTap(4),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
