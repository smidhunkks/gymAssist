import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_provider.dart'; // for firestoreProvider

/// Stream of trainee's assigned workouts
final traineeWorkoutsProvider =
StreamProvider.family<List<Map<String, dynamic>>, String>((ref, traineeId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('users')
      .doc(traineeId)
      .collection('workouts')
      .orderBy('assignedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((d) => d.data()).toList());
});
