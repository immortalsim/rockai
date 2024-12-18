import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../styles/app_colors.dart';

class RockDetailScreen extends StatelessWidget {
  final Map<String, dynamic> rockData;

  const RockDetailScreen({Key? key, required this.rockData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(rockData['name'], style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(rockData['imagePath']),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rockData['name'], style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  ...rockData.entries.where((entry) => entry.key != 'imagePath').map((entry) => _buildDynamicItem(entry.key, entry.value)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imagePath) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        child: imagePath != null && imagePath.isNotEmpty
            ? Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.error_outline, size: 100, color: AppColors.onSurface),
        )
            : const Center(
          child: Icon(Icons.landscape_outlined, size: 100, color: AppColors.onSurface),
        ),
      ),
    );
  }

  Widget _buildDynamicItem(String key, dynamic value) {
    if (value is String) {
      return _buildDetailItem(_getIconForKey(key), _formatKey(key), value);
    } else if (value is List) {
      return _buildDetailList(_getIconForKey(key), _formatKey(key), value.map((e) => e.toString()));
    } else if (value is Map) {
      return _buildNestedMap(key, Map<String, dynamic>.from(value));
    }
    return const SizedBox.shrink();
  }

  Widget _buildNestedMap(String key, Map<String, dynamic> map) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatKey(key), style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            ...map.entries.map((entry) => _buildNestedItem(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildNestedItem(String key, dynamic value) {
    if (value is String) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, top: 4),
        child: Row(
          children: [
            Text('${_formatKey(key)}:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500, color: AppColors.secondary)),
            const SizedBox(width: 8),
            Expanded(child: Text(value, style: GoogleFonts.exo2(color: AppColors.onSurface))),
          ],
        ),
      );
    } else if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text('${_formatKey(key)}:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500, color: AppColors.secondary)),
          ),
          ...value.map((item) => Padding(
            padding: const EdgeInsets.only(left: 32, top: 2),
            child: Row(
              children: [
                const Icon(Icons.diamond_outlined, size: 12, color: AppColors.accent),
                const SizedBox(width: 8),
                Expanded(child: Text(item.toString(), style: GoogleFonts.exo2(color: AppColors.onSurface))),
              ],
            ),
          )),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDetailItem(IconData icon, String title, String content) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.accent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(content, style: GoogleFonts.exo2(color: AppColors.onSurface)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailList(IconData icon, String title, Iterable<String> items) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.accent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.diamond_outlined, size: 12, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item, style: GoogleFonts.exo2(color: AppColors.onSurface))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForKey(String key) {
    switch (key) {
      case 'type':
        return Icons.category_outlined;
      case 'description':
        return Icons.description_outlined;
      case 'geographicalPresence':
        return Icons.map_outlined;
      case 'color':
        return Icons.palette_outlined;
      case 'hardness':
        return Icons.fitness_center_outlined;
      case 'physicalProperties':
        return Icons.science_outlined;
      case 'commonUses':
        return Icons.build_outlined;
      case 'dangerLevel':
        return Icons.warning_outlined;
      case 'geologicalProperties':
        return Icons.landscape_outlined;
      case 'imageQuality':
        return Icons.high_quality_outlined;
      case 'confidenceLevel':
        return Icons.thumb_up_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _formatKey(String key) {
    return key.split(RegExp(r'(?=[A-Z])')).map((word) => word.capitalize()).join(' ');
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}