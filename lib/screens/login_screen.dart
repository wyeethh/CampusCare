import 'package:flutter/material.dart';

import '../app_widgets.dart';
import '../auth_service.dart';
import '../colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.signIn(_email.text, _password.text);
      // AuthGate will automatically show the home screen
    } catch (e) {
      if (mounted) showSnack(context, AuthService.message(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgot() async {
    if (_email.text.trim().isEmpty) {
      showSnack(context, 'Enter your email first, then tap Forgot password.');
      return;
    }
    try {
      await AuthService.instance.resetPassword(_email.text);
      if (mounted) showSnack(context, 'Password reset email sent.');
    } catch (e) {
      if (mounted) showSnack(context, AuthService.message(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    double headerHeight = 250;

    return Scaffold(
      backgroundColor: kBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Teal header with logo
            Container(
              height: headerHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Image.asset('assets/images/campuscare_logo.png'),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'CampusCare',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your school clinic, in your pocket.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // Login form card
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: kTextDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Log in to manage your health and visits.',
                          style: TextStyle(fontSize: 13, color: kTextGrey),
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: _email,
                          label: 'School email',
                          icon: Icons.mail_outline,
                          hint: 'maria.santos@bulsu.edu.ph',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your email';
                            }
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
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Please enter your password'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _forgot,
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: kPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Log in',
                          loading: _loading,
                          onPressed: _login,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'New student? ',
                              style: TextStyle(fontSize: 13, color: kTextGrey),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              ),
                              child: const Text(
                                'Create an account',
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
            ),

            const SizedBox(height: 40),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 14, color: kTextGrey),
                SizedBox(width: 6),
                Text(
                  'Secured with Firebase Authentication',
                  style: TextStyle(fontSize: 12, color: kTextGrey),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
