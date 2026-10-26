import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_widgets.dart';
import '../auth_service.dart';
import '../colors.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  // Camera / gallery act
  Future<void> _changePhoto(ImageSource source) async {
    try {
      XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (file == null) return;

      String photoUrl = '';
      try {
        // Save the picture to Firebase Storage
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_photos')
            .child('${AuthService.instance.uid}.jpg');

        await storageRef.putFile(File(file.path));
        photoUrl = await storageRef.getDownloadURL();
      } catch (e) {
        // If storage is not enabled, just keep the picture on the phone
        photoUrl = file.path;
      }

      await AuthService.instance.saveProfile(AuthService.instance.uid, {
        'photoUrl': photoUrl,
      });

      if (mounted) showSnack(context, 'Profile photo updated.');
    } catch (e) {
      if (mounted) showSnack(context, 'Could not open the camera.');
    }
  }

  Future<void> _removePhoto() async {
    await AuthService.instance.saveProfile(AuthService.instance.uid, {
      'photoUrl': '',
    });
    if (mounted) showSnack(context, 'Profile photo removed.');
  }

  void _photoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Profile photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Choose how to add your photo',
                    style: TextStyle(fontSize: 12, color: kTextGrey),
                  ),
                ),
                const SizedBox(height: 14),
                _optionTile(
                  Icons.camera_alt_outlined,
                  'Take a photo',
                  'Use your camera',
                  kPrimary,
                  () {
                    Navigator.pop(context);
                    _changePhoto(ImageSource.camera);
                  },
                ),
                _optionTile(
                  Icons.image_outlined,
                  'Choose from gallery',
                  'Pick an existing photo',
                  kPrimary,
                  () {
                    Navigator.pop(context);
                    _changePhoto(ImageSource.gallery);
                  },
                ),
                _optionTile(
                  Icons.delete_outline,
                  'Remove photo',
                  'Go back to initials',
                  kDanger,
                  () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: kTextGrey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _optionTile(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AppCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color == kDanger ? kDangerSoft : kPrimarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: kTextGrey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kTextGrey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String uid = AuthService.instance.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: AuthService.instance.profileStream(uid),
      builder: (context, snapshot) {
        Map<String, dynamic> profile = snapshot.data?.data() ?? {};
        String name = (profile['fullName'] ?? '').toString();
        String photo = (profile['photoUrl'] ?? '').toString();

        return SingleChildScrollView(
          child: Column(
            children: [
              // Teal header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 24),
                decoration: const BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'My profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: profileAvatar(photo, name, 92),
                          ),
                          GestureDetector(
                            onTap: _photoOptions,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                                color: kPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name.isEmpty ? 'Student' : name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (profile['program'] ?? '').isEmpty
                            ? 'Add your program'
                            : profile['program'].toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    AppCard(
                      child: Column(
                        children: [
                          InfoRow(
                            icon: Icons.badge_outlined,
                            label: 'Student ID',
                            value: (profile['studentId'] ?? '').toString(),
                          ),
                          const Divider(color: kBorder),
                          InfoRow(
                            icon: Icons.school_outlined,
                            label: 'Program',
                            value: (profile['program'] ?? '').toString(),
                          ),
                          const Divider(color: kBorder),
                          InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Contact number',
                            value: (profile['contactNumber'] ?? '').toString(),
                          ),
                          const Divider(color: kBorder),
                          InfoRow(
                            icon: Icons.favorite_outline,
                            label: 'Emergency contact',
                            value: (profile['emergencyContact'] ?? '').toString(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Edit profile',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(profile: profile),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Log out',
                      color: kDanger,
                      filled: false,
                      onPressed: () => _confirmLogout(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?'),
        content: const Text('You need to log in again to use CampusCare.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay', style: TextStyle(color: kTextGrey)),
          ),
          TextButton(
            onPressed: () {
              AuthService.instance.signOut();
              Navigator.pop(context);
            },
            child: const Text('Log out', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
  }
}
