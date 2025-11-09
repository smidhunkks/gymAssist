import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_provider.dart';


/// family provider to fetch trainer doc by trainerId (one-shot).
final trainerProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, trainerId) async {
  if (trainerId.isEmpty) return null;
  final firestore = ref.watch(firestoreProvider);
  final snap = await firestore.collection('users').doc(trainerId).get();
  return snap.exists ? snap.data() : null;
});
