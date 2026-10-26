import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_widgets.dart';
import '../auth_service.dart';
import '../colors.dart';
import 'book_appointment_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index) goToTab;
  const HomeScreen({super.key, required this.goToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String greeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 18) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    String uid = AuthService.instance.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: AuthService.instance.profileStream(uid),
      builder: (context, profileSnap) {
        Map<String, dynamic> profile = profileSnap.data?.data() ?? {};
        String name = (profile['fullName'] ?? '').toString();
        String photo = (profile['photoUrl'] ?? '').toString();

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: AuthService.instance.appointmentsStream(uid),
          builder: (context, apptSnap) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> all =
                apptSnap.data?.docs ?? [];

            List<QueryDocumentSnapshot<Map<String, dynamic>>> upcoming = all
                .where((doc) {
                  String status = (doc.data()['status'] ?? 'Pending').toString();
                  String date = (doc.data()['date'] ?? '').toString();
                  return (status == 'Pending' || status == 'Approved') &&
                      date.compareTo(todayString()) >= 0;
                })
                .toList();

            upcoming.sort((a, b) => (a.data()['date'] ?? '')
                .toString()
                .compareTo((b.data()['date'] ?? '').toString()));

            return CustomScrollView(
              slivers: [
                // Teal header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 30),
                    decoration: const BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    greeting(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    name.isEmpty ? 'Student' : name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen(),
                                ),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                  // Red badge when there is an upcoming visit
                                  if (upcoming.isNotEmpty)
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFDC2626),
                                          shape: BoxShape.circle,
                                          border: Border.fromBorderSide(
                                            BorderSide(
                                              color: kPrimary,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _showStudentInfo(profile),
                              child: profileAvatar(photo, name, 42),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Next appointment
                      const Text(
                        'Next appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      upcoming.isEmpty
                          ? _emptyAppointment()
                          : _nextAppointment(upcoming.first),

                      const SizedBox(height: 20),

                      // Health summary
                      Row(
                        children: [
                          _summaryCard(
                            Icons.water_drop_outlined,
                            (profile['bloodType'] ?? '').isEmpty
                                ? '—'
                                : profile['bloodType'].toString(),
                            'Blood type',
                          ),
                          const SizedBox(width: 10),
                          _summaryCard(
                            Icons.warning_amber_outlined,
                            (profile['allergies'] ?? '').isEmpty
                                ? 'None'
                                : _countList(profile['allergies'].toString()),
                            'Allergies',
                          ),
                          const SizedBox(width: 10),
                          _summaryCard(
                            Icons.notifications_active_outlined,
                            'On',
                            'Reminders',
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Quick actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _actionCard(
                              Icons.calendar_month_outlined,
                              'Book visit',
                              'Pick a date & time',
                              () => widget.goToTab(1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _actionCard(
                              Icons.favorite_outline,
                              'Health info',
                              'Blood type, allergies',
                              () => widget.goToTab(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _actionCard(
                              Icons.history,
                              'History',
                              'Past appointments',
                              () => widget.goToTab(1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _actionCard(
                              Icons.person_outline,
                              'My profile',
                              'Photo & contacts',
                              () => widget.goToTab(3),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Stay on schedule banner
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: kPrimarySoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_active_outlined,
                                color: kPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stay on schedule',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: kTextDark,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Reminders arrive 1 hour before your visit.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: kTextGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ]),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Tap the avatar on the header to see the student information
  void _showStudentInfo(Map<String, dynamic> profile) {
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const Center(
                  child: Text(
                    'Student information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.person_outline,
                        label: 'Full name',
                        value: (profile['fullName'] ?? '').toString(),
                      ),
                      const Divider(color: kBorder),
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
                const SizedBox(height: 14),
                AppButton(
                  label: 'Go to my profile',
                  onPressed: () {
                    Navigator.pop(context);
                    widget.goToTab(3);
                  },
                ),
              ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _countList(String value) {
    List<String> parts = value.split(',').where((v) => v.trim().isNotEmpty).toList();
    return parts.length.toString();
  }

  Widget _emptyAppointment() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.event_available_outlined, size: 40, color: kPrimary),
          const SizedBox(height: 10),
          const Text(
            'No upcoming appointment',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Book a visit at the school clinic.',
            style: TextStyle(fontSize: 13, color: kTextGrey),
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Book visit',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookAppointmentScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextAppointment(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data();
    String status = (data['status'] ?? 'Pending').toString();

    return GestureDetector(
      onTap: () => widget.goToTab(1),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 60,
              decoration: BoxDecoration(
                color: kPrimarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    monthShort((data['date'] ?? '').toString()),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                    ),
                  ),
                  Text(
                    dayNumber((data['date'] ?? '').toString()),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (data['reason'] ?? 'Clinic visit').toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDate((data['date'] ?? '').toString())} • ${data['time'] ?? ''}',
                    style: const TextStyle(fontSize: 12, color: kTextGrey),
                  ),
                  const SizedBox(height: 8),
                  StatusChip(status: status),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextGrey),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(IconData icon, String value, String label) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: kPrimary, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: kTextGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kPrimarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kPrimary, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: kTextGrey),
            ),
          ],
        ),
      ),
    );
  }
}
