import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;
  final String phoneNumber;
  final String address;
  final DateTime? createdAt;

  CustomerModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.role = 'customer',
    this.isActive = true,
    this.phoneNumber = '',
    this.address = '',
    this.createdAt,
  });

  /// Create CustomerModel from a Firestore Document Snapshot
  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    DateTime? parsedDate;
    if (data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      parsedDate = DateTime.tryParse(data['createdAt']);
    }

    return CustomerModel(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      isActive: data['isActive'] ?? true,
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      createdAt: parsedDate,
    );
  }

  /// Create CustomerModel from a Map
  factory CustomerModel.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt']);
    }

    return CustomerModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
      isActive: map['isActive'] ?? true,
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      createdAt: parsedDate,
    );
  }

  /// Convert CustomerModel to Map for Firestore document creation
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'isActive': isActive,
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

