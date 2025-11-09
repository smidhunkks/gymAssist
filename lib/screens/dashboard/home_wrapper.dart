import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'trainer_home.dart';
import 'trainee_home.dart';
import '../auth/login_screen.dart';

class HomeWrapper extends ConsumerWidget {
  const HomeWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const LoginScreen();

        final userDoc = ref.watch(userDataProvider);

        return userDoc.when(
          data: (data) {
            if (data == null) {
              return const Scaffold(
                body: Center(child: Text('Loading user profile...')),
              );
            }

            // Ensure correct type
            print("user data : $data");
            final dynamic rawFlag = data['isTrainer'];
            final bool isTrainer = rawFlag == true; // strict boolean check
            print("isTrainer - $isTrainer");
            return isTrainer ? const TrainerHome() : const TraineeHome();
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            body: Center(child: Text('Error loading user data: $e')),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
    );
  }
}
