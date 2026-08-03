import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String reservationId;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String frameId;
  final String frameName;
  final String brand;
  final String frameStyle;
  final double price;
  final String imageUrl;
  final String status;
  final DateTime? createdAt;
  final DateTime? statusUpdatedAt;

  ReservationModel({
    required this.reservationId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.frameId,
    required this.frameName,
    required this.brand,
    required this.frameStyle,
    this.price = 0.0,
    required this.imageUrl,
    this.status = 'Pending',
    this.createdAt,
    this.statusUpdatedAt,
  });

  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  /// Create ReservationModel from a Firestore DocumentSnapshot
  factory ReservationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReservationModel.fromMap(data, doc.id);
  }

  /// Create ReservationModel from a Map and document ID
  factory ReservationModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    double parsedPrice = 0.0;
    final rawPrice = data['price'];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      final sanitized = rawPrice.replaceAll(RegExp(r'[^\d.]'), '');
      parsedPrice = double.tryParse(sanitized) ?? 0.0;
    }

    return ReservationModel(
      reservationId: id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      frameId: data['frameId'] ?? '',
      frameName: data['frameName'] ?? '',
      brand: data['brand'] ?? '',
      frameStyle: data['frameStyle'] ?? data['shape'] ?? '',
      price: parsedPrice,
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? 'Pending',
      createdAt: parseDate(data['createdAt']),
      statusUpdatedAt: parseDate(data['statusUpdatedAt'] ?? data['updatedAt']),
    );
  }

  /// Convert ReservationModel to Map for Firestore document creation
  Map<String, dynamic> toMap() {
    return {
      'reservationId': reservationId,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'frameId': frameId,
      'frameName': frameName,
      'brand': brand,
      'frameStyle': frameStyle,
      'price': price,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'statusUpdatedAt': statusUpdatedAt != null ? Timestamp.fromDate(statusUpdatedAt!) : null,
    };
  }
}
