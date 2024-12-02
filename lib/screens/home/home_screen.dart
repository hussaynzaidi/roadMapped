import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/roadmap.dart';
import '../../repositories/roadmap_repository.dart';
import '../../services/auth_service.dart';
import '../../widgets/roadmap_card.dart';
import '../roadmap/roadmap_create_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _roadmapRepository = context.read<RoadmapRepository>();
    final user = context.read<AuthService>().currentUser;
    _roadmapsStream = user != null 
        ? _roadmapRepository.getUserRoadmaps(user.uid)
        : _roadmapRepository.getPublicRoadmaps();
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

  double _getChildAspectRatio() {
    switch (_currentLayout) {
      case GridLayout.single:
        return 3.0;
      case GridLayout.double:
        return 0.75;
      case GridLayout.triple:
        return 0.7;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoadMapped'),
        actions: [
          PopupMenuButton<GridLayout>(
            icon: const Icon(Icons.view_module),
            initialValue: _currentLayout,
            onSelected: (GridLayout layout) {
              setState(() {
                _currentLayout = layout;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: GridLayout.single,
                child: Row(
                  children: [
                    Icon(Icons.view_agenda),
                    SizedBox(width: 8),
                    Text('Single Column'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: GridLayout.double,
                child: Row(
                  children: [
                    Icon(Icons.grid_view),
                    SizedBox(width: 8),
                    Text('Two Columns'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: GridLayout.triple,
                child: Row(
                  children: [
                    Icon(Icons.grid_on),
                    SizedBox(width: 8),
                    Text('Three Columns'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthService>().signOut();
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          childAspectRatio: _getChildAspectRatio(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          return RoadmapCard(
            roadmap: Roadmap(
              id: 'sample',
              title: 'Sample Roadmap',
              description: 'This is a sample roadmap description that might be a bit longer to test the layout',
              steps: [],
              createdBy: 'system',
              createdAt: DateTime.now(),
              progress: 0.5,
            ),
            isListView: _currentLayout == GridLayout.single,
          );
        },
        itemCount: 10,
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
