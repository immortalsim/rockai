import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'rock_detail_screen.dart';
import '../models/rock.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../styles/app_colors.dart';

class CollectionScreen extends StatefulWidget {
  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<Rock> rocks = [];

  @override
  void initState() {
    super.initState();
    loadRocks();
  }

  Future<void> refreshCollection() async {
    await loadRocks();
    setState(() {});
  }

  Future<void> loadRocks() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/collection.json');

    if (await file.exists()) {
      final String jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        rocks = jsonList.map((json) => Rock.fromMap(json)).toList();
      });
    } else {
      String jsonString = await DefaultAssetBundle.of(context).loadString('assets/rocklist/collection.json');
      setState(() {
        rocks = (json.decode(jsonString) as List)
            .map((item) => Rock.fromMap(item))
            .toList();
      });
    }
  }

  Future<void> removeRock(Rock rock) async {
    setState(() {
      rocks.remove(rock);
    });
    await saveRocks();

    // Delete the image file if it's not an asset
    if (rock.imageUrl != null && !rock.imageUrl!.startsWith('assets/')) {
      try {
        await File(rock.imageUrl!).delete();
      } catch (e) {
        print('Error deleting image file: $e');
      }
    }
  }

  Future<void> saveRocks() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/collection.json');
    final String rocksJson = json.encode(rocks.map((rock) => rock.toMap()).toList());
    await file.writeAsString(rocksJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Collection', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.primary,
      ),
      body: rocks.isEmpty
          ? Center(
        child: Text(
          'Your collection is empty',
          style: GoogleFonts.exo2(color: AppColors.secondary, fontSize: 18),
        ),
      )
          : GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: rocks.length,
        itemBuilder: (context, index) {
          final rock = rocks[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RockDetailScreen(rockData: rock.toMap()),
                ),
              );
              refreshCollection();
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.surface,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          child: rock.imageUrl != null
                              ? Image.asset(
                            rock.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(Icons.error_outline, size: 50, color: AppColors.accent),
                              );
                            },
                          )
                              : Icon(Icons.landscape_outlined, size: 80, color: AppColors.accent),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rock.name,
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Danger: ${rock.dangerLevel ?? 'Unknown'}",
                              style: GoogleFonts.exo2(
                                color: AppColors.secondary,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              rock.geologicalProperties ?? 'No geological properties',
                              style: GoogleFonts.exo2(
                                color: AppColors.accent,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteConfirmationDialog(rock),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(Rock rock) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Rock'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this rock from your collection?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                removeRock(rock);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}