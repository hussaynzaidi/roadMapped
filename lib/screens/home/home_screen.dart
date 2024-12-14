import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/roadmap.dart';
import '../../repositories/roadmap_repository.dart';
import '../../services/auth_service.dart';
import '../../widgets/roadmap_card.dart';
import '../profile/profile_screen.dart';
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
  List<Roadmap> _allRoadmaps = [];
  List<Roadmap> _filteredRoadmaps = [];
  bool _showPublicRoadmaps = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _roadmapRepository = context.read<RoadmapRepository>();
    _fetchRoadmaps();
  }

  Future<void> _fetchRoadmaps() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null && !_showPublicRoadmaps) {
      setState(() {
        _allRoadmaps = [];
        _filteredRoadmaps = [];
      });
      return;
    }

    final roadmaps = _showPublicRoadmaps
        ? await _roadmapRepository.getPublicRoadmaps().first
        : await _roadmapRepository.getUserRoadmaps(user!.uid).first;

    setState(() {
      _allRoadmaps = roadmaps;
      _filteredRoadmaps = roadmaps;
    });
  }

  void _filterRoadmaps(String query) {
    if (query.isEmpty) {
      setState(() => _filteredRoadmaps = _allRoadmaps);
      return;
    }

    // Debounce the search
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final searchTerms = query.toLowerCase().split(' ');

      setState(() {
        _filteredRoadmaps = _allRoadmaps.where((roadmap) {
          // Search in title and description
          final inTitle = roadmap.title.toLowerCase();
          final inDescription = roadmap.description.toLowerCase();

          // Search in steps
          final inSteps = roadmap.steps.any((step) {
            final stepTitle = step.title.toLowerCase();
            final stepDescription = step.description.toLowerCase();
            return searchTerms.every((term) =>
                stepTitle.contains(term) || stepDescription.contains(term));
          });

          // Check if all search terms are found
          return searchTerms.every((term) =>
              inTitle.contains(term) ||
              inDescription.contains(term) ||
              inSteps);
        }).toList();

        // Sort results by relevance
        _filteredRoadmaps.sort((a, b) {
          final aTitle = a.title.toLowerCase();
          final bTitle = b.title.toLowerCase();
          final exactMatchA = aTitle == query.toLowerCase();
          final exactMatchB = bTitle == query.toLowerCase();

          if (exactMatchA != exactMatchB) {
            return exactMatchA ? -1 : 1;
          }

          final startsWithA = aTitle.startsWith(query.toLowerCase());
          final startsWithB = bTitle.startsWith(query.toLowerCase());

          if (startsWithA != startsWithB) {
            return startsWithA ? -1 : 1;
          }

          return 0;
        });
      });
    });
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

  // Future<void> _logout() async {
  //   await context.read<AuthService>().signOut();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoadMapped'),
        forceMaterialTransparency: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: Icon(
                _showPublicRoadmaps ? Icons.public_off_outlined : Icons.public),
            tooltip: _showPublicRoadmaps
                ? 'View My Roadmaps'
                : 'View Public Roadmaps',
            onPressed: () {
              setState(() {
                _showPublicRoadmaps = !_showPublicRoadmaps;
              });
              _fetchRoadmaps();
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
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: _logout,
          //   tooltip: 'Logout',
          // ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: _filterRoadmaps,
              decoration: InputDecoration(
                hintText: 'Search roadmaps...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: _filteredRoadmaps.isEmpty
          ? Center(
              child: Text(
                _showPublicRoadmaps
                    ? 'No public roadmaps available yet.\nBe the first to create one!'
                    : 'You haven\'t created any roadmaps yet.\nTap + to create one.',
                textAlign: TextAlign.center,
              ),
            )
          : GridView.builder(
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
              itemCount: _filteredRoadmaps.length,
              itemBuilder: (context, index) {
                return RoadmapCard(
                  roadmap: _filteredRoadmaps[index],
                  isListView: _currentLayout == GridLayout.single,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoadmapDetailScreen(
                          roadmap: _filteredRoadmaps[index],
                        ),
                      ),
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

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
