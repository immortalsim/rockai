import 'dart:convert';

class Rock {
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final String common_uses;
  final String confidenceLevel;
  final String imageQuality;
  final String color;
  final String properties;

  Rock({
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.common_uses,
    required this.confidenceLevel,
    required this.imageQuality,
    required this.color,
    required this.properties,
  });

  factory Rock.fromMap(Map<String, dynamic> map) {
    print('Parsing rock: $map'); // Log the map being parsed
    return Rock(
      name: map['name'] ?? 'pas d\'information',
      category: map['category'] ?? 'pas d\'information',
      description: map['description'] ?? 'pas d\'information',
      imageUrl: map['imageUrl'] ?? 'pas d\'information',
      common_uses: map['common_uses'] ?? 'pas d\'information',
      confidenceLevel: map['confidenceLevel'] ?? 'pas d\'information',
      imageQuality: map['imageQuality'] ?? 'pas d\'information',
      color: map['color'] ?? 'pas d\'information', // Ensure color is a list of strings
      properties: map['properties'] ?? 'pas d\'information',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'common_uses': common_uses,
      'confidenceLevel': confidenceLevel,
      'imageQuality': imageQuality,
      'color': color, // No need to encode color as JSON string
      'properties': properties,
    };
  }

  static List<String> _parseList(dynamic list) {
    if (list is String) {
      // Try to decode the string as JSON
      try {
        return List<String>.from(json.decode(list));
      } catch (e) {
        // If decoding fails, treat the string as a single-item list
        return [list];
      }
    } else if (list is List) {
      return List<String>.from(list);
    } else {
      return ['pas d\'information'];
    }
  }

  static Map<String, dynamic> _parseMap(dynamic map) {
    if (map is String) {
      // Try to decode the string as JSON
      try {
        // Clean the string to make it a valid JSON object
        String cleanedMap = map
            .replaceAll('Ã©', 'é') // Fix encoding issues (you can add more replacements if needed)
            .replaceAll('Ã', 'A')
            .replaceAll("'", '"'); // Ensure all quotes are correct

        // Add curly braces to make the string a valid JSON object if necessary
        if (!cleanedMap.startsWith('{')) {
          cleanedMap = '{$cleanedMap}';
        }

        final decodedMap = json.decode(cleanedMap);
        if (decodedMap is Map) {
          return decodedMap.map((key, value) => MapEntry(key.toString(), value));
        } else {
          return {};
        }
      } catch (e) {
        // If decoding fails, return an empty map
        print('Error decoding properties: $e');
        return {};
      }
    } else if (map is Map) {
      return map.map((key, value) => MapEntry(key.toString(), value));
    } else {
      return {};
    }
  }






}
