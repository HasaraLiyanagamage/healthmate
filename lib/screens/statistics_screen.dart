import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/health_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedPeriod = 'Day';

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
              _buildHeader(),
              Expanded(
                child: Consumer<HealthProvider>(
                  builder: (context, provider, child) {
                    return _buildContent(provider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            'Statistics today',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildContent(HealthProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPeriodTabs(),
          const SizedBox(height: 30),
          _buildStepsCircle(provider),
          const SizedBox(height: 40),
          _buildMetricsSummary(provider),
          const SizedBox(height: 40),
          _buildChart(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    final periods = ['Day', 'Week', 'Month', 'Year'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: periods.map((period) {
        final isSelected = period == selectedPeriod;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPeriod = period;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withAlpha(51) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              period,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepsCircle(HealthProvider provider) {
    int displayValue;
    String label;
    int goal;
    
    switch (selectedPeriod) {
      case 'Day':
        displayValue = provider.todaySteps;
        label = 'steps today';
        goal = 10000;
        break;
      case 'Week':
        displayValue = 65900;
        label = 'avg steps/week';
        goal = 70000;
        break;
      case 'Month':
        displayValue = 266000;
        label = 'total steps';
        goal = 280000;
        break;
      case 'Year':
        displayValue = 3480000;
        label = 'total steps';
        goal = 3650000;
        break;
      default:
        displayValue = provider.todaySteps;
        label = 'steps';
        goal = 10000;
    }
    
    final percent = (displayValue / goal).clamp(0.0, 1.0);

    return CircularPercentIndicator(
      radius: 100,
      lineWidth: 20,
      percent: percent,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayValue.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
      progressColor: const Color(0xFF18E9CD),
      backgroundColor: Colors.white.withAlpha(51),
      circularStrokeCap: CircularStrokeCap.round,
    );
  }

  Widget _buildMetricsSummary(HealthProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMetricItem(
            'Distance',
            '${(provider.todaySteps * 0.0005).toStringAsFixed(2)} mi',
          ),
          _buildMetricItem(
            'Time',
            '${(provider.todaySteps / 100).toStringAsFixed(0)} hrs',
          ),
          _buildMetricItem(
            'Calories',
            provider.todayCalories.toStringAsFixed(0),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _getBottomTitle(value.toInt()),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _generateBarGroups(),
        ),
      ),
    );
  }

  double _getMaxY() {
    switch (selectedPeriod) {
      case 'Day':
        return 3500; // Max hourly steps ~3200
      case 'Week':
        return 12000; // Max daily steps ~11200
      case 'Month':
        return 75000; // Max weekly steps ~71000
      case 'Year':
        return 330000; // Max monthly steps ~320000
      default:
        return 100;
    }
  }

  String _getBottomTitle(int index) {
    switch (selectedPeriod) {
      case 'Day':
        // Hours: 0, 4, 8, 12, 16, 20
        final hours = ['12AM', '4AM', '8AM', '12PM', '4PM', '8PM'];
        return index < hours.length ? hours[index] : '';
      case 'Week':
        // Days: Mon, Tue, Wed, Thu, Fri, Sat, Sun
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return index < days.length ? days[index] : '';
      case 'Month':
        // Weeks: W1, W2, W3, W4
        return 'W${index + 1}';
      case 'Year':
        // Months: Jan, Feb, Mar, etc.
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return index < months.length ? months[index] : '';
      default:
        return '';
    }
  }

  List<BarChartGroupData> _generateBarGroups() {
    List<List<double>> data;
    
    switch (selectedPeriod) {
      case 'Day':
        // Hourly data for 24 hours (showing every 4 hours = 6 points)
        data = [
          [500, 300],   // 12AM-4AM
          [800, 600],   // 4AM-8AM
          [2500, 1800], // 8AM-12PM
          [3200, 2400], // 12PM-4PM
          [2800, 2100], // 4PM-8PM
          [1200, 900],  // 8PM-12AM
        ];
        break;
      case 'Week':
        // Daily data for 7 days
        data = [
          [8500, 6200],  // Monday
          [9200, 7100],  // Tuesday
          [7800, 5900],  // Wednesday
          [10500, 8200], // Thursday
          [9800, 7500],  // Friday
          [11200, 8900], // Saturday
          [8900, 6800],  // Sunday
        ];
        break;
      case 'Month':
        // Weekly data for 4 weeks
        data = [
          [62000, 48000],  // Week 1
          [68000, 52000],  // Week 2
          [71000, 55000],  // Week 3
          [65000, 50000],  // Week 4
        ];
        break;
      case 'Year':
        // Monthly data for 12 months
        data = [
          [250000, 190000], // January
          [280000, 210000], // February
          [310000, 240000], // March
          [295000, 225000], // April
          [320000, 250000], // May
          [305000, 235000], // June
          [290000, 220000], // July
          [315000, 245000], // August
          [300000, 230000], // September
          [285000, 215000], // October
          [270000, 205000], // November
          [260000, 195000], // December
        ];
        break;
      default:
        data = [[0, 0]];
    }

    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index][0],
            color: const Color(0xFF18E9CD),
            width: selectedPeriod == 'Year' ? 6 : 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: data[index][1],
            color: const Color(0xFF5BFCE1),
            width: selectedPeriod == 'Year' ? 6 : 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }
}
