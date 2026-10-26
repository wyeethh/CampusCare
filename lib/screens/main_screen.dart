import 'package:flutter/material.dart';

import '../app_widgets.dart';
import '../auth_service.dart';
import '../colors.dart';
import '../notifications_helper.dart';
import 'appointments_screen.dart';
import 'health_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _todayReminder();
  }

  // Local notification when there is an appointment today (like the mockup)
  Future<void> _todayReminder() async {
    try {
      final snap = await AuthService.instance
          .appointmentsRef(AuthService.instance.uid)
          .where('date', isEqualTo: todayString())
          .get();

      bool hasVisit = snap.docs.any((doc) {
        String status = (doc.data()['status'] ?? '').toString();
        return status == 'Pending' || status == 'Approved';
      });

      if (hasVisit) {
        await Future.delayed(const Duration(seconds: 3));
        for (final doc in snap.docs) {
          final data = doc.data();
          String status = (data['status'] ?? '').toString();
          if (status == 'Pending' || status == 'Approved') {
            NotificationsHelper.showNow(
              'Appointment today at ${data['time']}',
              '${data['reason']} at the school clinic. '
              'Please arrive 10 minutes early.',
            );
          }
        }
      }
    } catch (e) {
      // Ignore, notifications are optional
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(goToTab: (index) => setState(() => _index = index)),
          const AppointmentsScreen(),
          const HealthScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: NavigationBar(
          height: 68,
          backgroundColor: Colors.white,
          indicatorColor: kPrimarySoft,
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: kTextGrey),
              selectedIcon: Icon(Icons.home, color: kPrimary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: kTextGrey),
              selectedIcon: Icon(Icons.calendar_month, color: kPrimary),
              label: 'Appointments',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline, color: kTextGrey),
              selectedIcon: Icon(Icons.favorite, color: kPrimary),
              label: 'Health',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: kTextGrey),
              selectedIcon: Icon(Icons.person, color: kPrimary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
