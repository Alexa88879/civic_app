import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Welcome, ${user?.email ?? 'User'}!',
        style: const TextStyle(fontSize: 24),
      ),
      const SizedBox(height: 20),

      ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/report');
        },
        icon: const Icon(Icons.report_problem),
        label: const Text('Report Issue'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),

      const SizedBox(height: 10),

      ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/issues');
        },
        icon: const Icon(Icons.list),
        label: const Text('View Reported Issues'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    ],
  ),
),

    );
  }
}
