import 'package:cloud_firestore/cloud_firestore.dart';

class FrameModel {
  final String id;
  final String frameName;
  final String brand;
  final String frameStyle;
  final double price;
  final String description;
  final String imageUrl;
  final String arModelUrl;
  final bool availability;

  FrameModel({
    required this.id,
    required this.frameName,
    required this.brand,
    required this.frameStyle,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.arModelUrl,
    this.availability = true,
  });

  /// Formatted price string for UI display (e.g., "$129.00")
  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  /// Create FrameModel from a Firestore DocumentSnapshot
  factory FrameModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FrameModel.fromMap(data, doc.id);
  }

  /// Create FrameModel from a Map and document ID
  factory FrameModel.fromMap(Map<String, dynamic> data, String id) {
    // Parse price safely
    double parsedPrice = 0.0;
    final rawPrice = data['price'];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      final sanitized = rawPrice.replaceAll(RegExp(r'[^\d.]'), '');
      parsedPrice = double.tryParse(sanitized) ?? 0.0;
    }

    // Parse availability safely
    bool parsedAvailability = true;
    final rawAvailability = data['availability'];
    if (rawAvailability is bool) {
      parsedAvailability = rawAvailability;
    } else if (rawAvailability is String) {
      final lower = rawAvailability.trim().toLowerCase();
      parsedAvailability = (lower == 'true' || lower == 'available' || lower == 'in stock');
    } else if (rawAvailability is num) {
      parsedAvailability = rawAvailability != 0;
    }

    return FrameModel(
      id: id,
      frameName: data['frameName'] ?? data['name'] ?? '',
      brand: data['brand'] ?? '',
      frameStyle: data['frameStyle'] ?? data['style'] ?? data['shape'] ?? '',
      price: parsedPrice,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      arModelUrl: data['arModelUrl'] ?? '',
      availability: parsedAvailability,
    );
  }

  /// Convert FrameModel to a Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'frameName': frameName,
      'brand': brand,
      'frameStyle': frameStyle,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'arModelUrl': arModelUrl,
      'availability': availability,
    };
  }
}
