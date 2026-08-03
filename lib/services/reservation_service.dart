import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/frame_model.dart';
import '../models/reservation_model.dart';
import 'auth_service.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  static const String _collectionName = 'RESERVATIONS';

  /// Submit a new frame reservation for the currently authenticated user
  Future<void> createReservation(FrameModel frame) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'You must be logged in to reserve a frame.';
    }

    // 1. Check frame availability
    if (!frame.availability) {
      throw 'This frame is currently unavailable for reservation.';
    }

    // 2. Verify frame exists in FRAME_CATALOG
    final frameDoc =
        await _firestore.collection('FRAME_CATALOG').doc(frame.id).get();
    if (!frameDoc.exists) {
      throw 'This frame is no longer available in the catalog.';
    }

    final frameData = frameDoc.data();
    if (frameData != null) {
      final isAvailable = frameData['availability'] ?? true;
      if (isAvailable is bool && !isAvailable) {
        throw 'This frame is currently unavailable for reservation.';
      } else if (isAvailable is String &&
          isAvailable.trim().toLowerCase() == 'false') {
        throw 'This frame is currently unavailable for reservation.';
      }
    }

    // 3. Prevent duplicate Pending reservations for the same customer & frame
    final existingQuery = await _firestore
        .collection(_collectionName)
        .where('customerId', isEqualTo: user.uid)
        .where('frameId', isEqualTo: frame.id)
        .where('status', isEqualTo: 'Pending')
        .get();

    if (existingQuery.docs.isNotEmpty) {
      throw 'You already have a pending reservation for this frame.';
    }

    // 4. Fetch customer profile details
    final profile = await _authService.getCustomerProfile(user.uid);
    final String customerName = (profile?.fullName.isNotEmpty == true)
        ? profile!.fullName
        : (user.displayName?.isNotEmpty == true
            ? user.displayName!
            : 'Customer');
    final String customerEmail = (profile?.email.isNotEmpty == true)
        ? profile!.email
        : (user.email ?? '');

    // 5. Create reservation document
    await _firestore.collection(_collectionName).add({
      'customerId': user.uid,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'frameId': frame.id,
      'frameName': frame.frameName,
      'brand': frame.brand,
      'frameStyle': frame.frameStyle,
      'price': frame.price,
      'imageUrl': frame.imageUrl,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'statusUpdatedAt': null,
    });
  }

  /// Stream of all reservations belonging to the current user
  Stream<List<ReservationModel>> getUserReservationsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collectionName)
        .where('customerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final reservations = snapshot.docs
          .map((doc) => ReservationModel.fromFirestore(doc))
          .toList();

      // Sort client-side by createdAt descending (newest first)
      reservations.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return reservations;
    });
  }
}
