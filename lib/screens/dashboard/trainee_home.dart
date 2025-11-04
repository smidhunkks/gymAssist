import 'package:flutter/material.dart';

class TraineeHome extends StatelessWidget {
  const TraineeHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trainee Dashboard')),
      body: const Center(child: Text('Welcome Trainee!')),
    );
  }
}
