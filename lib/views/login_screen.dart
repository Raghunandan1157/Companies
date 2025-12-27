import 'package:flutter/material.dart';
import 'package:corp_pulse/theme/app_theme.dart';
import 'package:corp_pulse/components/glass_background.dart';
import 'package:corp_pulse/components/glow_button.dart';
import 'package:corp_pulse/components/shimmer_loading.dart';
import 'package:corp_pulse/models/data_models.dart';
import 'package:corp_pulse/services/mock_data_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  Role _selectedRole = Role.ceo;
  String? _selectedRegion;
  bool _isLoading = false;

  final List<String> _regions = MockDataService().regionNames;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole != Role.ceo && _selectedRegion == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a region')),
        );
        return;
      }

      setState(() => _isLoading = true);

      // Simulate Loading
      await Future.delayed(const Duration(seconds: 1));

      // Generate Data
      await MockDataService().generateData();

      if (mounted) {
        setState(() => _isLoading = false);

        final session = UserSession(
          name: _nameController.text,
          employeeId: _idController.text,
          role: _selectedRole,
          assignedRegion: _selectedRole == Role.ceo ? null : _selectedRegion,
        );

        Navigator.pushReplacementNamed(
          context,
          '/main',
          arguments: session,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ambient Background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonPurple.withOpacity(0.1),
                boxShadow: const [BoxShadow(blurRadius: 100, spreadRadius: 50, color: Color(0x1AD500F9))],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonCyan.withOpacity(0.1),
                boxShadow: const [BoxShadow(blurRadius: 100, spreadRadius: 50, color: Color(0x1A00E5FF))],
              ),
            ),
          ),

          Center(
            child: _isLoading ? _buildLoading() : _buildForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShimmerLoading(width: 100, height: 100, borderRadius: BorderRadius.circular(50)),
        const SizedBox(height: 20),
        const Text("Authenticating...", style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: GlassBackground(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LOGIN',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _idController,
                  label: 'Employee ID',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<Role>(
                  value: _selectedRole,
                  dropdownColor: AppTheme.surface,
                  decoration: _inputDecoration('Role', Icons.work_outline),
                  items: const [
                    DropdownMenuItem(value: Role.ceo, child: Text('CEO')),
                    DropdownMenuItem(value: Role.regionalManager, child: Text('Regional Manager')),
                    DropdownMenuItem(value: Role.branchUser, child: Text('Branch/Team User')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedRole = val!;
                      if (val == Role.ceo) _selectedRegion = null;
                    });
                  },
                ),

                if (_selectedRole != Role.ceo) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    dropdownColor: AppTheme.surface,
                    decoration: _inputDecoration('Region', Icons.map_outlined),
                    items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) => setState(() => _selectedRegion = val),
                    validator: (val) => val == null ? 'Select a region' : null,
                  ),
                ],

                const SizedBox(height: 40),
                GlowButton(
                  text: 'LOGIN',
                  onPressed: _handleLogin,
                  color: AppTheme.neonGreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.neonCyan),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.neonCyan)),
      labelStyle: const TextStyle(color: Colors.white60),
    );
  }
}
