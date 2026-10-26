import 'package:flutter/material.dart';

import '../app_widgets.dart';
import '../auth_service.dart';
import '../colors.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _studentId;
  late final TextEditingController _program;
  late final TextEditingController _contact;
  late final TextEditingController _emergency;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: (widget.profile['fullName'] ?? '').toString());
    _studentId = TextEditingController(text: (widget.profile['studentId'] ?? '').toString());
    _program = TextEditingController(text: (widget.profile['program'] ?? '').toString());
    _contact = TextEditingController(text: (widget.profile['contactNumber'] ?? '').toString());
    _emergency = TextEditingController(text: (widget.profile['emergencyContact'] ?? '').toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _studentId.dispose();
    _program.dispose();
    _contact.dispose();
    _emergency.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.saveProfile(AuthService.instance.uid, {
        'fullName': _name.text.trim(),
        'studentId': _studentId.text.trim(),
        'program': _program.text.trim(),
        'contactNumber': _contact.text.trim(),
        'emergencyContact': _emergency.text.trim(),
      });
      if (mounted) {
        showSnack(context, 'Profile updated.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to save profile.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const WhiteHeader(title: 'Edit profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AppCard(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _name,
                  label: 'Full name',
                  icon: Icons.person_outline,
                  hint: 'Maria Santos',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _studentId,
                  label: 'Student ID',
                  icon: Icons.badge_outlined,
                  hint: '2022-01234',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _program,
                  label: 'Program',
                  icon: Icons.school_outlined,
                  hint: 'BS Information Technology - 3rd year',
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _contact,
                  label: 'Contact number',
                  icon: Icons.phone_outlined,
                  hint: '0917 123 4567',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _emergency,
                  label: 'Emergency contact',
                  icon: Icons.favorite_outline,
                  hint: 'Elena Santos • 0918 765 4321',
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Save changes',
                  loading: _loading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
