import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.237.177:3000/api';


  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  }

  static Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      final errorData = json.decode(response.body);
      print('Registration Error: ${response.statusCode}');
      print('Error Details: $errorData');
      throw Exception(errorData['message'] ?? 'Registration failed');
    }
  }

  static Future<List<dynamic>> getRocks() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rocks'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final dynamic rocks = json.decode(response.body);
      print('Raw rocks data: $rocks'); // Log the raw data
      if (rocks is List) {
        return rocks;
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  }


  static Future<ImageProvider> getImage(String imageUrl) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rocks$imageUrl'),
    );

    if (response.statusCode == 200) {
      final imageData = response.bodyBytes;
      return MemoryImage(imageData);
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  }

  static Future<Map<String, dynamic>> addRock(Map<String, dynamic> rockData, File imageFile) async {
    final headers = await getAuthHeaders();

    // Convert the Map<String, dynamic> to Map<String, String>
    final Map<String, String> stringData = {};
    rockData.forEach((key, value) {
      stringData[key] = value.toString();
    });

    final request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/rocks')
    )
      ..headers.addAll(headers)
      ..fields.addAll(stringData) // Use the converted Map<String, String>
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      return json.decode(responseBody);
    } else {
      final responseBody = await response.stream.bytesToString();
      throw Exception(json.decode(responseBody)['message']);
    }
  }


  static Future<void> deleteRock(String rockId) async {
    final headers = await getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/rocks/$rockId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['message']);
    }
  }
}
