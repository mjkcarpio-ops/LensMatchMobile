import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clinic_information_model.dart';

class ClinicInformationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'CLINIC_INFORMATION';
  static const String _docId = 'general';

  /// Fetch clinic information once from CLINIC_INFORMATION/general
  Future<ClinicInformationModel?> getClinicInformation() async {
    try {
      final doc =
          await _firestore.collection(_collectionName).doc(_docId).get();
      if (!doc.exists) return null;
      return ClinicInformationModel.fromFirestore(doc);
    } catch (_) {
      return null;
    }
  }

  /// Stream clinic information real-time from CLINIC_INFORMATION/general
  Stream<ClinicInformationModel?> getClinicInformationStream() {
    return _firestore
        .collection(_collectionName)
        .doc(_docId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return ClinicInformationModel.fromFirestore(snapshot);
    });
  }
}
