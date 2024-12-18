import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'analysis_result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/analysis_service.dart';
import '../models/rock.dart';
import 'package:path_provider/path_provider.dart';
import '../styles/app_colors.dart';

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late Future<void> _initializeControllerFuture;
  late CameraController _cameraController;
  final AnalysisService _analysisService = AnalysisService();
  String _analysisResult = '';
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    return _cameraController.initialize();
  }

  Future<void> _captureAndAnalyzeImage() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }

    final XFile image = await _cameraController.takePicture();

    bool? shouldAnalyze = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Analyze this image?', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500, color: AppColors.primary)),
          content: Image.file(File(image.path)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.exo2(color: AppColors.accent)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Analyze', style: GoogleFonts.exo2(color: AppColors.primary )),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldAnalyze == true) {
      setState(() {
        _isAnalyzing = true;
        _analysisResult = 'Analyzing...';
      });

      try {
        final result = await _analysisService.processAndAnalyzeImage(image.path);
        setState(() {
          _isAnalyzing = false;
        });

        if (result != null && result['is_rock'] == true) {
          Map<String, dynamic> rockData;
          if (result['objects'] != null && result['objects'] is List && result['objects'].isNotEmpty) {
            rockData = result['objects'][0];
          } else if (result is Map<String, dynamic>) {
            rockData = result;
          } else {
            throw Exception('Unexpected result format');
          }

          bool? shouldSave = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Save to Collection?', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500, color: AppColors.primary)),
                content: Text('Do you want to save this rock to your collection?', style: GoogleFonts.exo2()),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel', style: GoogleFonts.exo2(color: AppColors.accent)),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: Text('Save', style: GoogleFonts.exo2(color: AppColors.primary)),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            },
          );

          if (shouldSave == true) {
            await _saveToCollection(rockData, image.path);
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnalysisResultScreen(
                analysisResult: rockData,
                imagePath: image.path,
              ),
            ),
          );
        } else {
          setState(() {
            _analysisResult = 'Not a rock or analysis failed';
          });
        }
      } catch (e) {
        setState(() {
          _analysisResult = 'Error during analysis.';
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _saveToCollection(Map<String, dynamic> analysisResult, String imagePath) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String permanentPath = '${appDir.path}/$fileName';
    await File(imagePath).copy(permanentPath);

    Rock newRock = Rock(
      name: analysisResult['name'],
      type: analysisResult['type'],
      description: analysisResult['description'],
      geographicalPresence: List<String>.from(analysisResult['geographical_presence']),
      physicalProperties: PhysicalProperties.fromMap(analysisResult['physical_properties']),
      color: List<String>.from(analysisResult['color']),
      hardness: Hardness.fromMap(analysisResult['hardness']),
      imageUrl: permanentPath,
      dangerLevel: analysisResult['dangerLevel'],
      geologicalProperties: analysisResult['geologicalProperties'],
      commonUses: analysisResult['commonUses'],
      imageQuality: analysisResult['image_quality'],
      confidenceLevel: analysisResult['confidence_level'],
    );

    final prefs = await SharedPreferences.getInstance();
    final String? savedRocksJson = prefs.getString('collection');
    List<Rock> rocks = [];

    if (savedRocksJson != null) {
      rocks = (json.decode(savedRocksJson) as List)
          .map((item) => Rock.fromMap(item))
          .toList();
    }

    rocks.add(newRock);

    final String rocksJson = json.encode(rocks.map((rock) => rock.toMap()).toList());
    await prefs.setString('collection', rocksJson);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rock added to collection', style: GoogleFonts.exo2(color: AppColors.onPrimary)),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rock Analysis', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildAnalysisBody();
          } else {
            return Center(child: CircularProgressIndicator(color: AppColors.accent));
          }
        },
      ),
    );
  }

  Widget _buildAnalysisBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: CameraPreview(_cameraController),
        ),
        Container(
          padding: EdgeInsets.all(16),
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                child: Text('Analyze', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500)),
                onPressed: _isAnalyzing ? null : _captureAndAnalyzeImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                _analysisResult,
                style: GoogleFonts.exo2(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onBackground),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
