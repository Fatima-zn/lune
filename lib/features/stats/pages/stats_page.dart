import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';
import '../../../data/models/listening_stats.dart';
import '../../../providers/storage_provider.dart';
import '../../../core/widgets/_loading_screen.dart';
import '../../../core/theme/app_theme.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(listeningStatsProvider);

    return statsAsync.when(
      loading: () => const LoadingScreen(message: 'Loading stats...'),
      error: (_, __) => const Center(
        child: Text('Failed to load stats', style: TextStyle(color: AppColors.textMuted)),
      ),
      data: (stats) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Stats'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.headphones,
                        value: _formatDuration(stats.totalListeningTime),
                        label: 'Listening',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle_outline,
                        value: '${stats.episodesCompleted}',
                        label: 'Completed',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department,
                        value: '${stats.currentStreak} days',
                        label: 'Streak',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.favorite,
                        value: '${stats.totalFavorites}',
                        label: 'Saved',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Monthly Goal
                _MonthlyGoalCard(
                  monthlyTotal: stats.monthlyTotal,
                  goalHours: stats.listeningGoalHours,
                  progress: stats.goalProgress,
                  onEditGoal: () => _showEditGoalDialog(context, ref),
                ),
                const SizedBox(height: 24),

                // Monthly chart
                if (stats.monthlyListening.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Text(
                          'Listening History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${_getMonthName(DateTime.now().month)})',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: _MonthlyChart(monthlyData: stats.monthlyListening),
                  ),
                  const SizedBox(height: 24),
                ],

                // Top podcasts
                if (stats.topPodcasts.isNotEmpty) ...[
                  const Text(
                    'Top Podcasts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...stats.topPodcasts.map((podcast) => _TopPodcastTile(podcast: podcast)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  void _showEditGoalDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Hours per month',
            suffixText: 'h',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final hours = int.tryParse(controller.text);
              if (hours != null && hours > 0) {
                ref.read(storageServiceProvider).setListeningGoal(hours);
                ref.invalidate(listeningStatsProvider);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceLight, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MonthlyGoalCard extends StatelessWidget {
  final Duration monthlyTotal;
  final int goalHours;
  final double progress;
  final VoidCallback onEditGoal;

  const _MonthlyGoalCard({
    required this.monthlyTotal,
    required this.goalHours,
    required this.progress,
    required this.onEditGoal,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = (progress * 100).toInt();
    final remainingHours = goalHours - monthlyTotal.inHours;
    final goalDuration = Duration(hours: goalHours);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Goal',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: onEditGoal,
                child: const Icon(Icons.edit, size: 16, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 18,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(monthlyTotal),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                _formatDuration(goalDuration),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 2),
          if (remainingHours > 0)
            Text(
              '$remainingHours hours to go!',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            )
          else
            const Text(
              'Goal reached!',
              style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class _MonthlyChart extends StatefulWidget {
  final Map<String, int> monthlyData;

  const _MonthlyChart({required this.monthlyData});

  @override
  State<_MonthlyChart> createState() => _MonthlyChartState();
}

class _MonthlyChartState extends State<_MonthlyChart> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToToday();
  }

  void _scrollToToday() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final now = DateTime.now();
      final today = now.day - 1;
      final offset = today * 28.0;
      final screenWidth = MediaQuery.of(context).size.width - 32;
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final targetOffset = (offset - screenWidth / 2 + 14).clamp(0.0, maxScroll);
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayIndex = now.day - 1;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final values = <double>[];
    final labels = <String>[];

    for (int i = 1; i <= daysInMonth; i++) {
      final key = '${now.year}-${now.month.toString().padLeft(2, '0')}-${i.toString().padLeft(2, '0')}';
      final seconds = widget.monthlyData[key] ?? 0;
      final minutes = seconds / 60;
      values.add(minutes);
      labels.add('$i');
    }

    final maxY = values.fold<double>(0, (max, v) => v > max ? v : max);
    double chartMax;
    if (maxY <= 0) {
      chartMax = 5;
    } else if (maxY <= 5) {
      chartMax = 5;
    } else if (maxY <= 10) {
      chartMax = 10;
    } else if (maxY <= 30) {
      chartMax = 30;
    } else if (maxY <= 60) {
      chartMax = 60;
    } else {
      chartMax = ((maxY / 60).ceil() * 60).toDouble();
    }

    final interval = chartMax / 4;
    final chartWidth = daysInMonth * 28.0;
    final screenWidth = MediaQuery.of(context).size.width - 32;

    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                  child: Text(
                    '${chartMax.toInt()}m',
                    style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Expanded(child: SizedBox()),
                SizedBox(
                  height: 20,
                  child: Text(
                    '${(chartMax / 2).toInt()}m',
                    style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Expanded(child: SizedBox()),
                const SizedBox(
                  height: 20,
                  child: Text(
                    '0',
                    style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth > screenWidth - 40 ? chartWidth : screenWidth - 40,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.center,
                    maxY: chartMax,
                    barGroups: values.asMap().entries.map((entry) {
                      final isToday = entry.key == todayIndex;
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.surfaceLight,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: daysInMonth <= 7 ? 1 : (daysInMonth <= 15 ? 2 : 3),
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            final isToday = index == todayIndex;
                            if (index >= 0 && index < labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  labels[index],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isToday ? AppColors.primary : AppColors.textMuted,
                                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: AppColors.surfaceLight,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPodcastTile extends StatelessWidget {
  final PodcastStat podcast;

  const _TopPodcastTile({required this.podcast});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //to do
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceLight, width: 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: podcast.imageUrl != null && podcast.imageUrl!.isNotEmpty
                  ? Image.network(
                      podcast.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: AppColors.surfaceLight,
                        child: const Icon(Icons.podcasts, size: 24, color: AppColors.textMuted),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: AppColors.surfaceLight,
                      child: const Icon(Icons.podcasts, size: 24, color: AppColors.textMuted),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    podcast.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${podcast.episodesPlayed} episodes • ${_formatDuration(podcast.listeningTime)}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}