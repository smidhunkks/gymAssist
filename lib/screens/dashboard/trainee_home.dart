// lib/screens/home/trainee_home.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymassist/providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/trainer_provider.dart';
import '../../routes/app_routes.dart';

class TraineeHome extends ConsumerWidget {
  const TraineeHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // userDataProvider gives the trainee's own Firestore document (Map or null)
    final userAsync = ref.watch(userDataProvider);

    return userAsync.when(
      data: (userData) {
        if (userData == null) {
          return const Scaffold(
            body: Center(child: Text('No user data found')),
          );
        }

        final traineeName = userData['displayName'] ?? 'Trainee';
        final trainerId = userData['trainerId'] as String?;
        // if trainerId is present, watch trainerProvider
        final trainerAsync = trainerId != null && trainerId.isNotEmpty
            ? ref.watch(trainerProvider(trainerId))
            : const AsyncValue.data(null);

        return Scaffold(
          appBar: AppBar(
            title: Text('Hi, $traineeName'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await ref.read(firebaseAuthProvider).signOut();
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $traineeName 👋',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Trainer card area
                trainerAsync.when(
                  data: (trainerData) {
                    if (trainerData == null) {
                      // Not linked
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'You are not linked to a trainer yet.',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.link),
                              label: const Text('Link with Trainer'),
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.linkTrainer);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final trainerName = trainerData['displayName'] ?? 'Your Trainer';
                    final trainerCode = trainerData['trainerCode'] ?? 'N/A';

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.fitness_center, color: Colors.blueAccent),
                        title: Text('Trainer: $trainerName'),
                        subtitle: Text('Trainer Code: $trainerCode'),
                        trailing: IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {
                            // Optionally navigate to chat or share contact
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading trainer: $e'),
                ),

                const SizedBox(height: 32),

                // Placeholder for trainee features
                const Text('Your Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      'Progress tracking coming soon 💪',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error loading user: $e'))),
    );
  }
}
