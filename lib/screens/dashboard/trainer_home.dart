import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymassist/providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';

class TrainerHome extends ConsumerWidget {
  const TrainerHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDataProvider);

    return userAsync.when(
      data: (data) {
        if (data == null) return const Center(child: Text('No data found'));
        final name = data['displayName'] ?? 'Trainer';
        final trainerCode = data['trainerCode'] ?? 'N/A';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Trainer Dashboard'),
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
                Text('Welcome, $name 👋',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  child: ListTile(
                    title: const Text('Your Trainer Code'),
                    subtitle: Text(
                      trainerCode,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.people),
                  label: const Text('View Trainees'),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.traineeList);
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48)),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
      const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
