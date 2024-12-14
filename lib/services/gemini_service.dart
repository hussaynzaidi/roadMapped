import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:roadmapped/models/resource.dart';
import 'package:roadmapped/repositories/resource_repository.dart';
import '../models/roadmap.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:logging/logging.dart';

class GeminiService {
  final gemini = Gemini.instance;
  final ResourceRepository _resourceRepository;
  static final _logger = Logger('GeminiService');

  GeminiService(this._resourceRepository);

  Future<Roadmap?> generateFullRoadmap(String topic) async {
    try {
      final prompt = '''
        Create a detailed learning roadmap for: "$topic"
        Format as JSON with the following structure:
        {
          "title": "Learning $topic",
          "description": "2-3 sentences about this learning path",
          "steps": [
            {
              "title": "step title",
              "description": "detailed step description",
              "resources": [
                {
                  "title": "Resource Title",
                  "description": "Resource Description",
                  "type": "link",
                  "content": "URL or text content"
                }
              ]
            }
          ]
        }
      ''';

      final result = await gemini.prompt(parts: [Part.text(prompt)]);

      if (result?.content?.parts?.first != null) {
        final outputPart = result!.content!.parts!.first;
        final outputJson = Part.toJson(outputPart);
        final jsonData =
            outputJson['text'].replaceAll('```json', '').replaceAll('```', '');

        final parsed = jsonDecode(jsonData);
        final generatedRoadmapTitle = parsed['title'];
        final generatedRoadmapDescription = parsed['description'];

        final steps = (parsed['steps'] as List<dynamic>).map((stepData) async {
          final resourceIds = await Future.wait(
            (stepData['resources'] as List<dynamic>).map((resource) async {
              final resourceId = const Uuid().v4();
              final newResource = Resource(
                id: resourceId,
                title: resource['title'] as String,
                description: resource['description'] as String,
                type: resource['type'].toString().toLowerCase() == 'link'
                    ? ResourceType.link
                    : ResourceType.text,
                content: resource['content'] as String,
                createdBy: 'Gemini',
                createdAt: DateTime.now(),
              );

              // Save resource to Firestore
              await _resourceRepository.create(newResource);
              return resourceId;
            }),
          );

          return RoadmapStep(
            id: const Uuid().v4(),
            title: stepData['title'],
            description: stepData['description'],
            resources: resourceIds,
            isCompleted: false,
          );
        });

        // Wait for all steps and resources to be created
        final completedSteps = await Future.wait(steps);

        return Roadmap(
          id: const Uuid().v4(),
          title: generatedRoadmapTitle,
          description: generatedRoadmapDescription,
          steps: completedSteps,
          createdBy: 'Gemini',
          createdAt: DateTime.now(),
          isPublic: true,
        );
      }
      return null;
    } catch (e) {
      _logger.severe('Error generating roadmap: $e');
      return null;
    }
  }
}
