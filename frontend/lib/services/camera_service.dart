// lib/services/camera_service.dart
import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller!.initialize();
  }

  Future<XFile> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }
    return await controller!.takePicture();
  }

  void dispose() {
    controller?.dispose();
  }
}
