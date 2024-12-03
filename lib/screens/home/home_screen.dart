import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/roadmap.dart';
import '../../repositories/roadmap_repository.dart';
import '../../services/auth_service.dart';
import '../../widgets/roadmap_card.dart';
import '../roadmap/roadmap_create_screen.dart';
import '../roadmap/roadmap_detail.dart';

enum GridLayout { single, double, triple }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GridLayout _currentLayout = GridLayout.single;
  late final RoadmapRepository _roadmapRepository;
  late final Stream<List<Roadmap>> _roadmapsStream;
  bool _showPublicRoadmaps = false;

  @override
  void initState() {
    super.initState();
    _roadmapRepository = context.read<RoadmapRepository>();
    _updateRoadmapsStream();
  }

  void _updateRoadmapsStream() {
    final user = context.read<AuthService>().currentUser;
    _roadmapsStream = _showPublicRoadmaps
        ? _roadmapRepository.getPublicRoadmaps()
        : (user != null
            ? _roadmapRepository.getUserRoadmaps(user.uid)
            : Stream.value([]));
  }

  Future<void> _logout() async {
    await context.read<AuthService>().signOut();
  }

  int _getCrossAxisCount() {
    switch (_currentLayout) {
      case GridLayout.single:
        return 1;
      case GridLayout.double:
        return 2;
      case GridLayout.triple:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoadMapped'),
        actions: [
          IconButton(
            icon: Icon(_showPublicRoadmaps ? Icons.person : Icons.public),
            onPressed: () {
              setState(() {
                _showPublicRoadmaps = !_showPublicRoadmaps;
                _updateRoadmapsStream();
              });
            },
          ),
          PopupMenuButton<GridLayout>(
            icon: const Icon(Icons.grid_view),
            onSelected: (GridLayout layout) {
              setState(() => _currentLayout = layout);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: GridLayout.single,
                child: Text('List View'),
              ),
              const PopupMenuItem(
                value: GridLayout.double,
                child: Text('Grid (2)'),
              ),
              const PopupMenuItem(
                value: GridLayout.triple,
                child: Text('Grid (3)'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<List<Roadmap>>(
        stream: _roadmapsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final roadmaps = snapshot.data ?? [];
          
          if (roadmaps.isEmpty) {
            return Center(
              child: Text(_showPublicRoadmaps 
                ? 'No public roadmaps available.'
                : 'You haven\'t created any roadmaps yet.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(),
              childAspectRatio: _currentLayout == GridLayout.single 
                  ? 3 
                  : _currentLayout == GridLayout.double 
                      ? 0.8 
                      : 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: roadmaps.length,
            itemBuilder: (context, index) {
              return RoadmapCard(
                roadmap: roadmaps[index],
                isListView: _currentLayout == GridLayout.single,
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RoadmapCreateScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
