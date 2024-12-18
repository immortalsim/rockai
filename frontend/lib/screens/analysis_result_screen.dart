import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:gal/gal.dart';
import 'dart:typed_data';
import '../styles/app_colors.dart';

class AnalysisResultScreen extends StatelessWidget {
  final Map<String, dynamic> analysisResult;
  final String imagePath;

  const AnalysisResultScreen({Key? key, required this.analysisResult, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Result', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(File(imagePath), fit: BoxFit.cover, width: double.infinity),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analysisResult['name'] ?? 'Unknown Rock',
                    style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    analysisResult['type'] ?? 'Unknown Type',
                    style: GoogleFonts.exo2(fontSize: 18, color: AppColors.secondary),
                  ),
                  SizedBox(height: 16),
                  Text(
                    analysisResult['description'] ?? 'No description available',
                    style: GoogleFonts.exo2(fontSize: 16, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow('Danger Level', analysisResult['dangerLevel'] ?? 'Unknown'),
                  _buildInfoRow('Geological Properties', analysisResult['geologicalProperties'] ?? 'Unknown'),
                  _buildInfoRow('Common Uses', analysisResult['commonUses'] ?? 'Unknown'),
                  _buildListInfoRow('Geographical Presence', List<String>.from(analysisResult['geographical_presence'] ?? [])),
                  _buildListInfoRow('Color', List<String>.from(analysisResult['color'] ?? [])),
                  _buildPhysicalPropertiesInfo(analysisResult['physical_properties'] ?? {}),
                  _buildHardnessInfo(analysisResult['hardness'] ?? {}),
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

  Widget _buildListInfoRow(String label, List<dynamic> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ...values.map((value) => Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 2.0),
            child: Text('• $value', style: GoogleFonts.exo2(color: AppColors.onBackground)),
          )),
        ],
      ),
    );
  }

  Widget _buildPhysicalPropertiesInfo(Map<String, dynamic> properties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Physical Properties:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppColors.primary)),
        _buildInfoRow('Texture', properties['texture'] ?? 'Unknown'),
        _buildListInfoRow('Composition', properties['composition'] ?? []),
        _buildInfoRow('Density', properties['density'] ?? 'Unknown'),
        _buildInfoRow('Porosity', properties['porosity'] ?? 'Unknown'),
        _buildInfoRow('Permeability', properties['permeability'] ?? 'Unknown'),
      ],
    );
  }

  Widget _buildHardnessInfo(Map<String, dynamic> hardness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hardness:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppColors.primary)),
        _buildInfoRow('Mohs Scale', hardness['mohs_scale'] ?? 'Unknown'),
        _buildInfoRow('Description', hardness['description'] ?? 'Unknown'),
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
        // Note: Pour Android, assurez-vous d'avoir la permission WRITE_EXTERNAL_STORAGE
        _directory = '/storage/emulated/0/DCIM';
      }

      final path = '$_directory/rockai_${const Uuid().v1()}.png';
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