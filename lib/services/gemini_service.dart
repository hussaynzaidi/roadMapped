import 'package:flutter_gemini/flutter_gemini.dart';
import '../models/roadmap.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class GeminiService {
  final gemini = Gemini.instance;
  static String response = '';

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
              "resources": []
            }
          ]
        }
      ''';

      final result = await gemini.prompt(parts: [Part.text(prompt)]);

      if (result?.content?.parts?.first != null) {
        final text = result!.content!.parts!.first.toString();

        // Extract JSON content between curly braces
        final startIndex = text.indexOf('{');
        final endIndex = text.lastIndexOf('}') + 1;

        if (startIndex >= 0 && endIndex > startIndex) {
          final jsonStr = text.substring(startIndex, endIndex);
          print('Extracted JSON: $jsonStr'); // Debug print
          final json = jsonDecode(jsonStr);

          return Roadmap(
            id: const Uuid().v4(),
            title: json['title'],
            description: json['description'],
            steps: (json['steps'] as List)
                .map((step) => RoadmapStep(
                      id: const Uuid().v4(),
                      title: step['title'],
                      description: step['description'],
                      resources: const [],
                      isCompleted: false,
                    ))
                .toList(),
            createdBy: '',
            createdAt: DateTime.now(),
            isPublic: true,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error generating roadmap: $e');
      return null;
    }
  }
}
