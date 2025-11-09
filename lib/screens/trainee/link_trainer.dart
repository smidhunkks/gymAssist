import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';

class LinkTrainerScreen extends ConsumerStatefulWidget {
  const LinkTrainerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LinkTrainerScreen> createState() => _LinkTrainerScreenState();
}

class _LinkTrainerScreenState extends ConsumerState<LinkTrainerScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;

  Future<void> _linkTrainer() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter trainer code')));
      return;
    }

    setState(() => _loading = true);

    try {
      final firestore = ref.read(firestoreProvider);
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      final traineeUid = user.uid;
      final traineeRef = firestore.collection('users').doc(traineeUid);

      // 1️⃣ Find trainer by code
      final trainerQuery = await firestore
          .collection('users')
          .where('trainerCode', isEqualTo: code)
          .where('isTrainer', isEqualTo: true)
          .limit(1)
          .get();

      if (trainerQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid trainer code')),
        );
        setState(() => _loading = false);
        return;
      }

      final trainerDoc = trainerQuery.docs.first;
      final trainerId = trainerDoc.id;

      // 2️⃣ Check trainee existence
      final traineeSnap = await traineeRef.get();
      if (traineeSnap.exists) {
        await traineeRef.update({
          'trainerId': trainerId,
          'linkedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await traineeRef.set({
          'uid': traineeUid,
          'email': user.email,
          'displayName': user.displayName ?? '',
          'isTrainer': false,
          'trainerId': trainerId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 3️⃣ Add trainee to trainer’s list
      final traineeInTrainerRef = firestore
          .collection('users')
          .doc(trainerId)
          .collection('trainees')
          .doc(traineeUid);

      final traineeExists = await traineeInTrainerRef.get();
      if (!traineeExists.exists) {
        await traineeInTrainerRef.set({
          'joinedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await traineeInTrainerRef.update({
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trainer linked successfully ✅')),
      );

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to link trainer: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link with Trainer')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your trainer’s code below to connect your account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Trainer Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.link),
              label: _loading
                  ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Text('Link Trainer'),
              onPressed: _loading ? null : _linkTrainer,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
