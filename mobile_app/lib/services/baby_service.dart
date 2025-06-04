import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BabyService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchBabyProfiles() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('babies')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
  

  Future<void> saveBabyProfile({
    required String name,
    required String birthDate,
    required String feedingPreferences,
    required String allergies,
    required String notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('babies')
        .doc();
    
    await docRef.set({
      'name': name,
      'birthDate': birthDate,
      'feedingPreferences': feedingPreferences,
      'allergies': allergies,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBabyProfile(String docId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('babies')
        .doc(docId)
        .delete();
  }
  Future<void> updateBabyProfile({
    required String docId,
    required String name,
    required String birthDate,
    required String feedingPreferences,
    required String allergies,
    required String notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('babies')
        .doc(docId)
        .update({
          'name': name,
          'birthDate': birthDate,
          'feedingPreferences': feedingPreferences,
          'allergies': allergies,
          'notes': notes,
        });
  }
}