import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/rock.dart';
import 'api_service.dart';

class AnalysisService {
  final String OPENROUTER_API_KEY = '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';

  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      String prompt = '''
Analyze the image and provide a JSON response with these key details:
{
  "is_rock": true/false,
  "object": {
    "name": "The Name of the Rock who appears, else just say 'Don' Identify'",
    "type": "Rock type or object category",
    "description": "Brief visual description",
    "color": ["Main colors"],
    "texture": "Texture description",
    "possible_uses": "Potential uses"
  },
  "confidence_level": "high/medium/low"
}
If it's not a rock, analyze the main visible object. Provide concise, factual information based solely on the image.
''';

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $OPENROUTER_API_KEY',
        },
        body: jsonEncode({
          'model': 'mistralai/pixtral-12b:free',
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {'type': 'image_url', 'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}}
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String content = jsonResponse['choices'][0]['message']['content'];
        print('API Response: $content');

        content = content.replaceAll(RegExp(r'^```json\s*|\s*```$'), '');
        content = content.trim();

        try {
          return json.decode(content);
        } catch (e) {
          throw Exception('Failed to parse JSON response');
        }
      } else {
        throw Exception('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during analysis: $e');
      throw Exception('An error occurred during analysis');
    }
  }

  Future<Map<String, dynamic>> processAndAnalyzeImage(String imagePath) async {
    try {
      Map<String, dynamic> analysisResult = await analyzeImage(imagePath);

      if (analysisResult['is_rock'] == true) {
        await handleRockAnalysis(analysisResult, imagePath);
        return {'is_rock': true, 'message': 'Rock added to collection'};
      } else {
        return handleNonRockAnalysis(analysisResult);
      }
    } catch (e) {
      print('An error occurred during processing and analysis: $e');
      return {'is_rock': false, 'error': 'An error occurred during analysis'};
    }
  }

  Future<void> handleRockAnalysis(Map<String, dynamic> analysisResult, String imagePath) async {
    final rock = Rock(
      name: analysisResult['object']['name'],
      type: analysisResult['object']['type'],
      description: analysisResult['object']['description'],
      color: List<String>.from(analysisResult['object']['color']),
      commonUses: analysisResult['object']['possible_uses'],
      imageUrl: imagePath,
      confidenceLevel: analysisResult['confidence_level'],
      geographicalPresence: ['Non déterminé'],
      physicalProperties: PhysicalProperties(
        texture: analysisResult['object']['texture'],
        composition: ['Non déterminé'],
        density: 'Non déterminé',
        porosity: 'Non déterminé',
        permeability: 'Non déterminé',
      ),
      hardness: Hardness(
        mohsScale: 'Soon',
        description: 'Soon',
      ),
      dangerLevel: 'Soon',
      geologicalProperties: 'Soon',
      imageQuality: 'Soon',
    );

    try {
      await ApiService.addRock(rock.toMap());
    } catch (e) {
      print('Error saving rock to backend: $e');
      throw Exception('Failed to save rock to collection');
    }
  }

  Map<String, dynamic> handleNonRockAnalysis(Map<String, dynamic> analysisResult) {
    return {
      'is_rock': false,
      'message': 'The analyzed object is not a rock.',
      'object_name': analysisResult['object']['name'],
      'object_type': analysisResult['object']['type'],
      'description': analysisResult['object']['description'],
    };
  }
} 