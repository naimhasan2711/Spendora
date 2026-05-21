import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/models/models.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../providers/goals_provider.dart';

/// Goals Screen
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGoals = ref.watch(activeGoalsProvider);
    final completedGoals = ref.watch(completedGoalsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Savings Goals'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GoalsList(goals: activeGoals, isEmpty: 'No active goals'),
            _GoalsList(goals: completedGoals, isEmpty: 'No completed goals'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'goalsFAB',
          onPressed: () => context.push(AppRoutes.addGoal),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _GoalsList extends StatelessWidget {
  final List<GoalModel> goals;
  final String isEmpty;

  const _GoalsList({required this.goals, required this.isEmpty});

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.savings_outlined,
                size: 80,
                color: context.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 24),
              Text(
                isEmpty,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        return _GoalCard(goal: goals[index]);
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalModel goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final saved = goal.savedAmount;
    final target = goal.targetAmount;
    final progress = (saved / target).clamp(0.0, 1.0);
    final isCompleted = saved >= target;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate days remaining
    int? daysRemaining;
    if (goal.targetDate != null) {
      daysRemaining = goal.targetDate!.difference(DateTime.now()).inDays;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1A3A34),
                  const Color(0xFF0D524A),
                  const Color(0xFF0A3D36)
                ]
              : [
                  const Color(0xFF0D6B5E),
                  const Color(0xFF14A085),
                  const Color(0xFF0D6B5E)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D6B5E).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _showGoalDetails(context, goal);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Image Header
            if (goal.imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.1),
                  child: Icon(
                    IconData(goal.iconCodePoint, fontFamily: 'MaterialIcons'),
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      if (goal.imageUrl == null)
                        Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.only(right: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            IconData(goal.iconCodePoint,
                                fontFamily: 'MaterialIcons'),
                            color: Colors.white,
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.name,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            if (daysRemaining != null)
                              Text(
                                daysRemaining > 0
                                    ? '$daysRemaining days remaining'
                                    : 'Target date passed',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: daysRemaining > 0
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : const Color(0xFFFFB347),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 14,
                                color: Color(0xFF7FFF7F),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Completed',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF7FFF7F),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress
                  CircularPercentIndicator(
                    radius: 50,
                    lineWidth: 10,
                    percent: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    progressColor: Colors.white,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    center: Text(
                      '${(progress * 100).toInt()}%',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saved',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            AppFormatters.formatCurrency(saved),
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF7FFF7F),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Target',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            AppFormatters.formatCurrency(target),
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Add Money Button
                  if (!isCompleted) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showAddMoneyDialog(context, goal);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.5)),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Money'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDetails(BuildContext context, GoalModel goal) {
    // TODO: Navigate to goal details
  }

  void _showAddMoneyDialog(BuildContext context, GoalModel goal) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Goal'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '৳ ',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                // TODO: Add to goal
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
