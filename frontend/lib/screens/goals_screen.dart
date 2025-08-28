import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../screens/profile_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Goals',
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
      body: Center(
        child: Text(
          'Set your financial goals here!',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
