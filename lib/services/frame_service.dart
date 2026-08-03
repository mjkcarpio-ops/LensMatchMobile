import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/frame_model.dart';

class FrameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'FRAME_CATALOG';

  /// Stream of all frame documents from FRAME_CATALOG collection
  Stream<List<FrameModel>> getFramesStream() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FrameModel.fromFirestore(doc)).toList();
    });
  }

  /// Fetch all frame documents once from FRAME_CATALOG collection
  Future<List<FrameModel>> getFrames() async {
    final snapshot = await _firestore.collection(_collectionName).get();
    return snapshot.docs.map((doc) => FrameModel.fromFirestore(doc)).toList();
  }
}
