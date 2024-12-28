import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:gal/gal.dart';
import 'dart:typed_data';
import '../services/api_service.dart';
import '../styles/app_colors.dart';

class AnalysisResultScreen extends StatelessWidget {
  final Map<String, dynamic> analysisResult;
  final String imagePath;

  const AnalysisResultScreen({Key? key, required this.analysisResult, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(analysisResult);
    final objectData = analysisResult;
    print(objectData);
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Result', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<ImageProvider>(
              future: ApiService.getImage(imagePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Icon(Icons.error, color: AppColors.accent);
                } else if (snapshot.hasData) {
                  return Image(
                    image: snapshot.data!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                } else {
                  return Icon(Icons.landscape, color: AppColors.accent);
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    objectData['name'] ?? 'Unknown Object',
                    style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    objectData['category'] ?? 'Unknown Category',
                    style: GoogleFonts.exo2(fontSize: 18, color: AppColors.secondary),
                  ),
                  SizedBox(height: 16),
                  Text(
                    objectData['description'] ?? 'No description available',
                    style: GoogleFonts.exo2(fontSize: 16, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 16),
                  Text(
                    objectData['properties'] ?? 'No properties available',
                    style: GoogleFonts.exo2(fontSize: 16, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow('Color', objectData['color'] ?? 'Unknown'),
                  _buildInfoRow('Common Uses', objectData['common_uses'] ?? 'Unknown'),
                  _buildQualityInfo(analysisResult),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          await _saveImage(context);
        },
        backgroundColor: AppColors.accent,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppColors.primary)),
          Expanded(child: Text(value, style: GoogleFonts.exo2(color: AppColors.onBackground))),
        ],
      ),
    );
  }


  Widget _buildQualityInfo(Map<String, dynamic> result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Image Quality', result['imageQuality'] ?? 'Unknown'),
        _buildInfoRow('Confidence Level', result['confidenceLevel'] ?? 'Unknown'),
      ],
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    try {
      Uint8List captureImage = File(imagePath).readAsBytesSync();

      String _directory = '';
      if (Platform.isIOS) {
        _directory = (await getApplicationSupportDirectory()).path;
      } else {
        _directory = '/storage/emulated/0/DCIM';
      }

      final path = '$_directory/objectai_${const Uuid().v1()}.png';
      final savedImageFile = await File(path).create();
      await savedImageFile.writeAsBytes(captureImage);

      await Gal.putImage(path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved to gallery', style: GoogleFonts.exo2(color: AppColors.onPrimary)),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving image: $e', style: GoogleFonts.exo2(color: AppColors.onPrimary)),
          backgroundColor: Colors.red,
        ),
      );
      print('Error saving image: $e');
    }
  }
}