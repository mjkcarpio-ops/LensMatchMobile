import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicInformationModel {
  final String clinicName;
  final String contactNumber;
  final String email;
  final String address;
  final String businessHours;
  final String reservationInstructions;

  ClinicInformationModel({
    required this.clinicName,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.businessHours,
    this.reservationInstructions = '',
  });

  /// Create ClinicInformationModel from a Firestore DocumentSnapshot
  factory ClinicInformationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ClinicInformationModel.fromMap(data);
  }

  /// Create ClinicInformationModel from a Map
  factory ClinicInformationModel.fromMap(Map<String, dynamic> data) {
    return ClinicInformationModel(
      clinicName: data['clinicName'] ?? data['name'] ?? 'LensMatch Clinic',
      contactNumber: data['contactNumber'] ?? data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      businessHours: data['businessHours'] ?? data['hours'] ?? '',
      reservationInstructions:
          data['reservationInstructions'] ?? data['instructions'] ?? '',
    );
  }

  /// Convert ClinicInformationModel to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'clinicName': clinicName,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'businessHours': businessHours,
      'reservationInstructions': reservationInstructions,
    };
  }
}
