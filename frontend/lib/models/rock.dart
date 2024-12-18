class Rock {
  final int? id;
  final String name;
  final String type;
  final String description;
  final List<String> geographicalPresence;
  final PhysicalProperties physicalProperties;
  final List<String> color;
  final Hardness hardness;
  final String? imageUrl;
  final String? dangerLevel;
  final String? geologicalProperties;
  final String? commonUses;
  final String imageQuality;
  final String confidenceLevel;

  Rock({
    this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.geographicalPresence,
    required this.physicalProperties,
    required this.color,
    required this.hardness,
    required this.imageUrl,
    this.dangerLevel,
    this.geologicalProperties,
    this.commonUses,
    required this.imageQuality,
    required this.confidenceLevel
  });

  factory Rock.fromMap(Map<String, dynamic> map) {
    return Rock(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      description: map['description'],
      geographicalPresence: List<String>.from(map['geographical_presence'] ?? []),
      physicalProperties: PhysicalProperties.fromMap(map['physical_properties'] ?? {}),
      color: List<String>.from(map['color'] ?? []),
      hardness: Hardness.fromMap(map['hardness'] ?? {}),
      imageUrl: map['image_url'],
      dangerLevel: map['dangerLevel'],
      geologicalProperties: map['geologicalProperties'],
      commonUses: map['commonUses'],
      imageQuality: map['image_quality'] ?? 'Not determined',
      confidenceLevel: map['confidence_level'] ?? 'Not determined'
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'geographical_presence': geographicalPresence,
      'physical_properties': physicalProperties.toMap(),
      'color': color,
      'hardness': hardness.toMap(),
      'image_url': imageUrl,
      'dangerLevel': dangerLevel,
      'geologicalProperties': geologicalProperties,
      'commonUses': commonUses,
      'image_quality': imageQuality,
      'confidence_level': confidenceLevel

    };
  }
}

class PhysicalProperties {
  final String? texture;
  final List<String> composition;
  final String? density;
  final String? porosity;
  final String? permeability;

  PhysicalProperties({
    this.texture,
    required this.composition,
    this.density,
    this.porosity,
    this.permeability,
  });

  factory PhysicalProperties.fromMap(Map<String, dynamic> map) {
    return PhysicalProperties(
      texture: map['texture'],
      composition: List<String>.from(map['composition'] ?? []),
      density: map['density'],
      porosity: map['porosity'],
      permeability: map['permeability'],
    );
  }

  // Ajoutez cette méthode
  Map<String, dynamic> toMap() {
    return {
      'texture': texture,
      'composition': composition,
      'density': density,
      'porosity': porosity,
      'permeability': permeability,
    };
  }
}

class Hardness {
  final String? mohsScale;
  final String? description;

  Hardness({
    this.mohsScale,
    this.description,
  });

  factory Hardness.fromMap(Map<String, dynamic> map) {
    return Hardness(
      mohsScale: map['mohs_scale'],
      description: map['description'],
    );
  }

  // Ajoutez cette méthode
  Map<String, dynamic> toMap() {
    return {
      'mohs_scale': mohsScale,
      'description': description,
    };
  }
}