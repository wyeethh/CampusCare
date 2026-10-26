import 'package:flutter/material.dart';

import '../app_widgets.dart';
import '../auth_service.dart';
import '../colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _studentId = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _studentId.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.register(
        fullName: _name.text,
        studentId: _studentId.text,
        email: _email.text,
        password: _password.text,
      );
      if (mounted) {
        showSnack(context, 'Account created. Welcome to CampusCare!');
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) showSnack(context, AuthService.message(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const WhiteHeader(title: 'Create account'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AppCard(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join CampusCare',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Use your school email to get started.',
                  style: TextStyle(fontSize: 13, color: kTextGrey),
                ),
                const SizedBox(height: 20),
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
                  controller: _email,
                  label: 'School email',
                  icon: Icons.mail_outline,
                  hint: 'maria.santos@bulsu.edu.ph',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _password,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  hint: '••••••••',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 8) return 'At least 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _confirm,
                  label: 'Confirm password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  hint: '••••••••',
                  validator: (v) => v != _password.text
                      ? 'Passwords do not match'
                      : null,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Create account',
                  loading: _loading,
                  onPressed: _register,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already registered? ',
                      style: TextStyle(fontSize: 13, color: kTextGrey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          color: kPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
