import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int targetValue;
  final String type; // 'steps', 'water', 'calories', 'streak'
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetValue,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    int? targetValue,
    String? type,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      targetValue: targetValue ?? this.targetValue,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  static List<Achievement> getDefaultAchievements() {
    return [
      Achievement(
        id: 'first_step',
        title: 'First Steps',
        description: 'Complete your first 1,000 steps',
        icon: Icons.hiking,
        targetValue: 1000,
        type: 'steps',
      ),
      Achievement(
        id: 'walker',
        title: 'Walker',
        description: 'Walk 5,000 steps in a day',
        icon: Icons.directions_walk,
        targetValue: 5000,
        type: 'steps',
      ),
      Achievement(
        id: 'marathon',
        title: 'Marathon',
        description: 'Walk 10,000 steps in a day',
        icon: Icons.directions_run,
        targetValue: 10000,
        type: 'steps',
      ),
      Achievement(
        id: 'super_walker',
        title: 'Super Walker',
        description: 'Walk 15,000 steps in a day',
        icon: Icons.bolt,
        targetValue: 15000,
        type: 'steps',
      ),
      Achievement(
        id: 'hydrated',
        title: 'Stay Hydrated',
        description: 'Drink 2 liters of water',
        icon: Icons.water_drop,
        targetValue: 2,
        type: 'water',
      ),
      Achievement(
        id: 'water_master',
        title: 'Water Master',
        description: 'Drink 3 liters of water',
        icon: Icons.waves,
        targetValue: 3,
        type: 'water',
      ),
      Achievement(
        id: 'week_streak',
        title: '7 Day Streak',
        description: 'Log activity for 7 days straight',
        icon: Icons.local_fire_department,
        targetValue: 7,
        type: 'streak',
      ),
      Achievement(
        id: 'month_streak',
        title: '30 Day Streak',
        description: 'Log activity for 30 days straight',
        icon: Icons.emoji_events,
        targetValue: 30,
        type: 'streak',
      ),
    ];
  }
}
