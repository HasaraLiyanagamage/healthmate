import 'package:flutter/material.dart';

class HealthTip {
  final String id;
  final String title;
  final String description;
  final String category; // 'exercise', 'nutrition', 'hydration', 'sleep', 'mental'
  final IconData icon;

  HealthTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
  });

  static List<HealthTip> getAllTips() {
    return [
      HealthTip(
        id: 'tip_1',
        title: 'Stay Hydrated',
        description: 'Drink at least 8 glasses of water daily to maintain optimal body function and energy levels.',
        category: 'hydration',
        icon: Icons.water_drop,
      ),
      HealthTip(
        id: 'tip_2',
        title: 'Take Walking Breaks',
        description: 'Stand up and walk for 5 minutes every hour to improve circulation and reduce sedentary time.',
        category: 'exercise',
        icon: Icons.directions_walk,
      ),
      HealthTip(
        id: 'tip_3',
        title: 'Quality Sleep',
        description: 'Aim for 7-9 hours of sleep each night to support recovery and mental clarity.',
        category: 'sleep',
        icon: Icons.bedtime,
      ),
      HealthTip(
        id: 'tip_4',
        title: 'Balanced Diet',
        description: 'Include a variety of fruits, vegetables, proteins, and whole grains in your meals.',
        category: 'nutrition',
        icon: Icons.restaurant,
      ),
      HealthTip(
        id: 'tip_5',
        title: 'Morning Exercise',
        description: 'Start your day with 10-15 minutes of light exercise to boost energy and metabolism.',
        category: 'exercise',
        icon: Icons.wb_sunny,
      ),
      HealthTip(
        id: 'tip_6',
        title: 'Mindful Breathing',
        description: 'Practice deep breathing for 5 minutes daily to reduce stress and improve focus.',
        category: 'mental',
        icon: Icons.self_improvement,
      ),
      HealthTip(
        id: 'tip_7',
        title: 'Limit Screen Time',
        description: 'Reduce screen exposure before bed to improve sleep quality and eye health.',
        category: 'sleep',
        icon: Icons.phone_android,
      ),
      HealthTip(
        id: 'tip_8',
        title: 'Portion Control',
        description: 'Use smaller plates and eat slowly to help control portion sizes and prevent overeating.',
        category: 'nutrition',
        icon: Icons.dinner_dining,
      ),
      HealthTip(
        id: 'tip_9',
        title: 'Stretch Daily',
        description: 'Incorporate stretching into your routine to improve flexibility and prevent injuries.',
        category: 'exercise',
        icon: Icons.accessibility_new,
      ),
      HealthTip(
        id: 'tip_10',
        title: 'Stay Positive',
        description: 'Practice gratitude and positive thinking to improve mental well-being and reduce stress.',
        category: 'mental',
        icon: Icons.sentiment_satisfied_alt,
      ),
    ];
  }

  static HealthTip getRandomTip() {
    final tips = getAllTips();
    tips.shuffle();
    return tips.first;
  }
}
