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
Analyze the image and provide a JSON response with these key details in french without the accents, do not forget the double quotes at every word,:
{
  "rock": {
    "name": "Name or identification of the object",
    "category": "Object category/type",
    "description": "Detailed visual description",
    "color": "Main colors present",
    "properties": "Main properties of the object",
    "common_uses": "Typical uses or purposes"
  },
  "confidence_level": "high/medium/low",
  "image_quality": "high/medium/low"
}
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
      throw Exception('An error occurred during analysis $e');
    }
  }

  Future<Map<String, dynamic>> processAndAnalyzeImage(String imagePath) async {
    try {
      Map<String, dynamic> analysisResult = await analyzeImage(imagePath);
        await handleRockAnalysis(analysisResult, imagePath);
        return {'message': 'Rock added to collection: '};
    } catch (e) {
      print('An error occurred during processing and analysis: $e');
      return {'error': 'An error occurred during analysis : $e'};
    }
  }

  Future<void> handleRockAnalysis(Map<String, dynamic> analysisResult, String imagePath) async {
    final rock = Rock(
      name: analysisResult['rock']['name'] ?? 'pas d\'information',
      category: analysisResult['rock']['category'] ?? 'pas d\'information',
      description: analysisResult['rock']['description'] ?? 'pas d\'information',
      color: analysisResult['rock']['color'] ?? 'pas d\'information',
      properties: analysisResult['rock']['properties'] ?? 'pas d\'information',
      common_uses: analysisResult['rock']['common_uses'] ?? 'pas d\'information',
      confidenceLevel: analysisResult['confidence_level'] ?? 'pas d\'information',
      imageQuality: analysisResult['image_quality'] ?? 'pas d\'information',
      imageUrl: imagePath,
    );

    try {
      await ApiService.addRock(rock.toMap(), File(imagePath));
    } catch (e) {
      print('Error saving rock to backend: $e');
      throw Exception('Failed to save rock to collection');
    }
  }
} 