import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/roadmap.dart';
import '../../models/progress.dart';
import '../../services/auth_service.dart';
import '../../repositories/roadmap_repository.dart';
import '../../repositories/progress_repository.dart';
import '../../widgets/roadmap_card.dart';
import '../roadmap/roadmap_detail.dart';
import 'settings_screen.dart';

class _MedalInfo {
  final String id;
  final String icon;
  final String name;
  final String description;

  const _MedalInfo({
    required this.id,
    required this.icon,
    required this.name,
    required this.description,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final RoadmapRepository _roadmapRepository;
  late final ProgressRepository _progressRepository;
  final List<_MedalInfo> allMedals = [
    // Creator Medals
    _MedalInfo(
      id: 'creator_1',
      icon: '🌱',
      name: 'Path Pioneer',
      description: 'Created first roadmap',
    ),
    _MedalInfo(
      id: 'creator_5',
      icon: '⭐',
      name: 'Route Master',
      description: 'Created 5+ roadmaps',
    ),
    _MedalInfo(
      id: 'creator_10',
      icon: '🌟',
      name: 'Journey Architect',
      description: 'Created 10+ roadmaps',
    ),

    // Completion Medals
    _MedalInfo(
      id: 'completer_1',
      icon: '🎯',
      name: 'First Summit',
      description: 'Completed first roadmap',
    ),
    _MedalInfo(
      id: 'completer_5',
      icon: '🏆',
      name: 'Peak Performer',
      description: 'Completed 5+ roadmaps',
    ),
    _MedalInfo(
      id: 'completer_10',
      icon: '👑',
      name: 'Knowledge King',
      description: 'Completed 10+ roadmaps',
    ),

    // Engagement Medals
    _MedalInfo(
      id: 'steps_50',
      icon: '🔥',
      name: 'Step Master',
      description: 'Completed 50+ steps',
    ),
    _MedalInfo(
      id: 'steps_100',
      icon: '💫',
      name: 'Century Achiever',
      description: 'Completed 100+ steps',
    ),
    _MedalInfo(
      id: 'streak_7',
      icon: '⚡',
      name: 'Momentum Master',
      description: '7-day learning streak',
    ),
    _MedalInfo(
      id: 'public_3',
      icon: '🌍',
      name: 'Community Guide',
      description: 'Created 3+ public roadmaps',
    ),
    _MedalInfo(
      id: 'collector_5',
      icon: '🏅',
      name: 'Medal Collector',
      description: 'Earned 5+ different medals',
    ),
  ];
  @override
  void initState() {
    super.initState();
    _roadmapRepository = context.read<RoadmapRepository>();
    _progressRepository = context.read<ProgressRepository>();
  }

  // Widget _buildMedalsList(Map<String, bool> medals) {
  //   return GridView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 4,
  //       childAspectRatio: 0.85,
  //       crossAxisSpacing: 8,
  //       mainAxisSpacing: 4,
  //     ),
  //     itemCount: allMedals.length,
  //     itemBuilder: (context, index) {
  //       final medal = allMedals[index];
  //       final isUnlocked = medals[medal.id] ?? false;

  //       return Card(
  //         child: InkWell(
  //           onTap: () {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(
  //                 content: Text(medal.description),
  //                 duration: const Duration(seconds: 2),
  //               ),
  //             );
  //           },
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Text(
  //                 medal.icon,
  //                 style: const TextStyle(fontSize: 22),
  //               ),
  //               const SizedBox(height: 2),
  //               Text(
  //                 medal.name,
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   fontSize: 9,
  //                   color: isUnlocked
  //                       ? null
  //                       : Theme.of(context)
  //                           .colorScheme
  //                           .onSurface
  //                           .withOpacity(0.5),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showAchievementsDialog(BuildContext context, Map<String, bool> medals) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievements',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '${medals.values.where((v) => v).length} / ${allMedals.length} unlocked',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: allMedals.length,
                  itemBuilder: (context, index) {
                    final medal = allMedals[index];
                    final isUnlocked = medals[medal.id] ?? false;

                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0.8,
                        end: isUnlocked ? 1.0 : 0.8,
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Tooltip(
                            message: medal.description,
                            preferBelow: false,
                            child: Card(
                              elevation: isUnlocked ? 4 : 1,
                              color: isUnlocked
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withOpacity(0.5),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        medal.icon,
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        medal.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked
                                              ? null
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Progress'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Created'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Medals Section
            StreamBuilder<List<Roadmap>>(
              stream: _roadmapRepository.getUserRoadmaps(user.uid),
              builder: (context, createdSnapshot) {
                return StreamBuilder<List<RoadmapProgress>>(
                  stream: _progressRepository.getAllUserProgress(user.uid),
                  builder: (context, progressSnapshot) {
                    final medals = <String, bool>{};

                    // Check created roadmaps count
                    if (createdSnapshot.hasData) {
                      final createdCount = createdSnapshot.data!.length;
                      medals['creator_1'] = createdCount >= 1;
                      medals['creator_5'] = createdCount >= 5;
                      medals['creator_10'] = createdCount >= 10;
                    }

                    // Check completed roadmaps count
                    if (progressSnapshot.hasData) {
                      final completedCount = progressSnapshot.data!
                          .where((p) => p.progressPercentage >= 1.0)
                          .length;
                      medals['completer_1'] = completedCount >= 1;
                      medals['completer_5'] = completedCount >= 5;
                      medals['completer_10'] = completedCount >= 10;

                      // Count total completed steps
                      final totalSteps = progressSnapshot.data!
                          .expand((p) => p.completedSteps.values)
                          .where((completed) => completed)
                          .length;
                      medals['steps_50'] = totalSteps >= 50;

                      medals['streak_7'] = true;
                    }

                    return Container(
                      height: 70,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).focusColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          'Achievements',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          '${medals.values.where((v) => v).length} / ${allMedals.length} unlocked',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: TextButton(
                          child: const Text('View all >>'),
                          onPressed: () =>
                              _showAchievementsDialog(context, medals),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Existing TabBarView
            Expanded(
              child: TabBarView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // Created Roadmaps Tab
                  StreamBuilder<List<Roadmap>>(
                    stream: _roadmapRepository.getUserRoadmaps(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No roadmaps created yet'),
                        );
                      }

                      final roadmaps = snapshot.data!;
                      return ListView.builder(
                        itemCount: roadmaps.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RoadmapCard(
                            roadmap: roadmaps[index],
                            isListView: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoadmapDetailScreen(
                                    roadmap: roadmaps[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  // Completed Roadmaps Tab
                  StreamBuilder<List<RoadmapProgress>>(
                    stream: _progressRepository.getAllUserProgress(user.uid),
                    builder: (context, progressSnapshot) {
                      if (progressSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!progressSnapshot.hasData ||
                          progressSnapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No completed roadmaps yet'),
                        );
                      }

                      final completedProgressList = progressSnapshot.data!
                          .where(
                              (progress) => progress.progressPercentage >= 1.0)
                          .toList();

                      if (completedProgressList.isEmpty) {
                        return const Center(
                          child: Text('No completed roadmaps yet'),
                        );
                      }

                      return ListView.builder(
                        itemCount: completedProgressList.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final progress = completedProgressList[index];
                          return StreamBuilder<Roadmap?>(
                            stream: _roadmapRepository
                                .getRoadmap(progress.roadmapId),
                            builder: (context, roadmapSnapshot) {
                              if (!roadmapSnapshot.hasData) {
                                return const SizedBox();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: RoadmapCard(
                                  roadmap: roadmapSnapshot.data!,
                                  isListView: true,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RoadmapDetailScreen(
                                          roadmap: roadmapSnapshot.data!,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
