import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roche/screens/map_screen.dart';
import '../models/rock.dart';
import '../services/api_service.dart';
import 'analysis_result_screen.dart';
import 'login_screen.dart';
import '../styles/app_colors.dart';
import 'analysis_screen.dart';
import 'collection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Rock> _recentRocks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRocks();
  }

  Future<void> _loadRocks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rocksData = await ApiService.getRocks();
      print('Fetched rocks data: $rocksData');
      setState(() {
        _recentRocks = rocksData.map((data) => Rock.fromMap(data)).toList();
        print('Parsed rocks: $_recentRocks');
        // Only keep the 5 most recent rocks
        if (_recentRocks.length > 5) {
          _recentRocks = _recentRocks.sublist(0, 5);
        }
      });
    } catch (e) {
      print('Error loading rocks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur chargement de pierres: ${e.toString()}',
            style: GoogleFonts.exo2(color: Colors.red),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await ApiService.clearToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building with recent rocks: $_recentRocks');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RockAI',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.onPrimary),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Text(
                'Bienvenue sur RockAI',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Identifiez des pierres avec l\'intelligence artificielle ',
                style: GoogleFonts.exo2(
                  fontSize: 16,
                  color: AppColors.secondary,
                ),
              ),
              SizedBox(height: 24),

              // Main Actions
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'Analyser une pierre',
                      Icons.camera_alt,
                      'avec le modèle router.ai',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AnalysisScreen()),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      'Collection',
                      Icons.collections_bookmark,
                      'Consultez votre collection de pierres',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CollectionScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Recent Analyses Section
              Text(
                'Analyses récentes',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16),
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _recentRocks.isEmpty
                      ? _buildEmptyState()
                      : _buildRecentRocksList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
          }, icon: Icon(Icons.map, color: AppColors.primary,)),
          IconButton(onPressed: (){}, icon: Icon(Icons.people_alt_outlined, color: AppColors.primary,))
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, String description, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.primary),
              SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.exo2(
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {

    print(_recentRocks);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.landscape_outlined,
            size: 64,
            color: AppColors.secondary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'Pas de pierres analysées encore',
            style: GoogleFonts.exo2(
              fontSize: 16,
              color: AppColors.secondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Analysez votre première pierre !',
            style: GoogleFonts.exo2(
              fontSize: 14,
              color: AppColors.secondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRocksList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _recentRocks.length,
      itemBuilder: (context, index) {
        final rock = _recentRocks[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: rock.imageUrl != null
                ? FutureBuilder<ImageProvider>(
              future: ApiService.getImage(rock.imageUrl!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Icon(Icons.error, color: AppColors.accent);
                } else if (snapshot.hasData) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image(
                      image: snapshot.data!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.landscape, color: AppColors.accent),
                    ),
                  );
                } else {
                  return Icon(Icons.landscape, color: AppColors.accent);
                }
              },
            )
                : Icon(Icons.landscape, color: AppColors.accent),
            title: Text(
              rock.name,
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              rock.category,
              style: GoogleFonts.exo2(color: AppColors.secondary),
            ),
            trailing: Icon(Icons.chevron_right, color: AppColors.primary),
            onTap: () {
              print(_recentRocks[index].toMap() );
              print('le print de la fete');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AnalysisResultScreen(

                    analysisResult: _recentRocks[index].toMap(),
                    imagePath: _recentRocks[index].imageUrl!,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }


} 