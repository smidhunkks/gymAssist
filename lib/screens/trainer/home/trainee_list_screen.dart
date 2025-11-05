import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class TraineeListScreen extends StatefulWidget {
  const TraineeListScreen({Key? key}) : super(key: key);

  @override
  State<TraineeListScreen> createState() => _TraineeListScreenState();
}

class _TraineeListScreenState extends State<TraineeListScreen> {
  final String trainerUid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _sendInviteEmail(String email, String inviteLink) async {
    final Email emailToSend = Email(
      recipients: [email],
      subject: 'Join me on Fitbuddy!',
      body: '''
Hi there 👋,

I’m inviting you to join my fitness program on Fitbuddy.

Use this referral link to sign up:
$inviteLink

Or, open the app and use my trainer code directly to link with me.

See you inside!
''',
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(emailToSend);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite email opened in Gmail')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open email app: $e')),
      );
    }
  }
  void _showAddTraineeDialog() async {
    final emailController = TextEditingController();
    final trainerDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(trainerUid)
        .get();
    final trainerCode = trainerDoc.data()?['trainerCode'] ?? 'N/A';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Invite a Trainee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the trainee’s email address. They will receive your referral link.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Trainee Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) return;

                final inviteLink =
                    'https://fitbuddyapp.page.link/invite?code=$trainerCode';

                Navigator.pop(ctx);
                _sendInviteEmail(email, inviteLink);
              },
              child: const Text('Send Invite'),
            ),
          ],
        );
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getTraineeStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(trainerUid)
        .collection('trainees')
        .orderBy('joinedAt', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> _getTraineeDetails(String traineeUid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(traineeUid)
        .get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Trainees')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _getTraineeStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No trainees linked yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final trainees = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: trainees.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final traineeId = trainees[index].id;
              final joinedAt = trainees[index].data()['joinedAt'] as Timestamp?;
              final joinedText = joinedAt != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                      joinedAt.millisecondsSinceEpoch,
                    ).toLocal().toString().split('.')[0]
                  : 'Unknown';

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getTraineeDetails(traineeId),
                builder: (context, traineeSnapshot) {
                  if (traineeSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text('Loading trainee...'),
                    );
                  }

                  final traineeData = traineeSnapshot.data;
                  if (traineeData == null) {
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_off),
                      ),
                      title: const Text('Unknown trainee'),
                      subtitle: Text('ID: $traineeId'),
                    );
                  }

                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person, color: Colors.white),
                      backgroundColor: Colors.blueAccent,
                    ),
                    title: Text(
                      traineeData['displayName'] ?? 'Unnamed',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(traineeData['email'] ?? 'No email'),
                        Text(
                          'Joined: $joinedText',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTraineeDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Trainee'),
      ),
    );
  }
}
