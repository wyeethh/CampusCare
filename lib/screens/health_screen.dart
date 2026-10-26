import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_widgets.dart';
import '../auth_service.dart';
import '../colors.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final _allergies = TextEditingController();
  final _conditions = TextEditingController();
  final _emergency = TextEditingController();
  String _bloodType = '';
  bool _loading = false;
  bool _loaded = false;

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-',
    'O+', 'O-', 'AB+', 'AB-',
  ];

  @override
  void dispose() {
    _allergies.dispose();
    _conditions.dispose();
    _emergency.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await AuthService.instance.saveProfile(AuthService.instance.uid, {
        'bloodType': _bloodType,
        'allergies': _allergies.text.trim(),
        'conditions': _conditions.text.trim(),
        'emergencyContact': _emergency.text.trim(),
      });
      if (mounted) showSnack(context, 'Health information saved.');
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to save. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String uid = AuthService.instance.uid;

    return Scaffold(
      backgroundColor: kBg,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: AuthService.instance.profileStream(uid),
        builder: (context, snapshot) {
          Map<String, dynamic> profile = snapshot.data?.data() ?? {};

          // Fill the fields one time when the profile is loaded
          if (!_loaded && profile.isNotEmpty) {
            _bloodType = (profile['bloodType'] ?? '').toString();
            _allergies.text = (profile['allergies'] ?? '').toString();
            _conditions.text = (profile['conditions'] ?? '').toString();
            _emergency.text = (profile['emergencyContact'] ?? '').toString();
            _loaded = true;
          }

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text(
                    'Health information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Blood type',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: kTextDark,
                                ),
                              ),
                              Text(
                                'Tap to select',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kTextGrey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.6,
                            children: _bloodTypes.map((type) {
                              bool selected = _bloodType == type;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _bloodType = type),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: selected ? kPrimary : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected ? kPrimary : kBorder,
                                    ),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? Colors.white
                                          : kTextDark,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),
                          AppTextField(
                            controller: _allergies,
                            label: 'Allergies',
                            icon: Icons.warning_amber_outlined,
                            hint: 'Peanuts, penicillin...',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _conditions,
                            label: 'Existing conditions',
                            icon: Icons.favorite_outline,
                            hint: 'Mild asthma...',
                            maxLines: 2,
                          ),

                          const SizedBox(height: 20),
                          const Text(
                            'Emergency contact',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kTextDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Someone we can call if you need help.',
                            style: TextStyle(fontSize: 12, color: kTextGrey),
                          ),
                          const SizedBox(height: 10),
                          AppTextField(
                            controller: _emergency,
                            label: 'Name and number',
                            icon: Icons.call_outlined,
                            hint: 'Elena Santos • 0917 765 4321',
                          ),

                          const SizedBox(height: 20),
                          AppButton(
                            label: 'Save health info',
                            loading: _loading,
                            onPressed: _save,
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              'Only you can see this information',
                              style: TextStyle(
                                fontSize: 12,
                                color: kTextGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
