import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../repositories/resource_repository.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceList extends StatelessWidget {
  final List<String> resourceIds;

  const ResourceList({Key? key, required this.resourceIds}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resourceRepository = context.read<ResourceRepository>();

    return StreamBuilder<List<Resource>>(
      stream: resourceRepository.getResourcesByIds(resourceIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No resources available.'));
        }

        final resources = snapshot.data!;

        return ListView.builder(
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return ListTile(
              title: Text(resource.title),
              subtitle: Text(resource.description),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () {
                  // Open resource URL
                  _launchURL(resource.url);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
} 