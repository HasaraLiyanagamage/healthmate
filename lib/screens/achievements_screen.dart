import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/health_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E1E1E),
                    const Color(0xFF2D2D2D),
                  ]
                : [
                    const Color(0xFF00CDB4),
                    const Color(0xFF00A594),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF121212) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Consumer<HealthProvider>(
                    builder: (context, provider, child) {
                      return _buildContent(context, provider);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Achievements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HealthProvider provider) {
    final achievements = Achievement.getDefaultAchievements();
    final unlockedCount = _getUnlockedCount(achievements, provider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCard(unlockedCount, achievements.length),
          const SizedBox(height: 24),
          const Text(
            'Your Achievements',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 16),
          ...achievements.map((achievement) {
            final isUnlocked = _isAchievementUnlocked(achievement, provider);
            return _buildAchievementCard(achievement, isUnlocked);
          }),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int unlocked, int total) {
    final percentage = (unlocked / total * 100).toInt();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00CDB4), Color(0xFF5B54E8)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overall Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$unlocked / $total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: unlocked / total,
                minHeight: 12,
                backgroundColor: Colors.white.withAlpha(51),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$percentage% Complete',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isUnlocked ? Colors.white : Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked 
                    ? const Color(0xFF00CDB4).withAlpha(25)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                size: 32,
                color: isUnlocked ? const Color(0xFF00CDB4) : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                      if (isUnlocked)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF66BB6A),
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUnlocked ? Colors.grey.shade600 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getUnlockedCount(List<Achievement> achievements, HealthProvider provider) {
    int count = 0;
    for (var achievement in achievements) {
      if (_isAchievementUnlocked(achievement, provider)) {
        count++;
      }
    }
    return count;
  }

  bool _isAchievementUnlocked(Achievement achievement, HealthProvider provider) {
    switch (achievement.type) {
      case 'steps':
        return provider.todaySteps >= achievement.targetValue;
      case 'water':
        return provider.todayWater >= achievement.targetValue;
      case 'calories':
        return provider.todayCalories >= achievement.targetValue;
      case 'streak':
        // For now, we'll check if they have records for consecutive days
        // This is a simplified version
        return provider.records.length >= achievement.targetValue;
      default:
        return false;
    }
  }
}
