import 'package:flutter/material.dart';
import 'package:corp_pulse/models/data_models.dart';
import 'package:corp_pulse/components/glow_button.dart';
import 'package:corp_pulse/theme/app_theme.dart';

class ProfileTab extends StatelessWidget {
  final UserSession session;

  const ProfileTab({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white10,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(session.name, style: Theme.of(context).textTheme.headlineMedium),
          Text("ID: ${session.employeeId}", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.neonPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.neonPurple),
            ),
            child: Text(
              session.role.toString().split('.').last.toUpperCase(),
              style: const TextStyle(color: AppTheme.neonPurple, fontWeight: FontWeight.bold),
            ),
          ),
          if (session.assignedRegion != null) ...[
            const SizedBox(height: 10),
            Text("Region: ${session.assignedRegion}", style: const TextStyle(color: AppTheme.neonCyan)),
          ],
          const SizedBox(height: 50),
          GlowButton(
            text: 'LOGOUT',
            color: AppTheme.neonRed,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
