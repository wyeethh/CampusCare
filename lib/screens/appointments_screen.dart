import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_widgets.dart';
import '../auth_service.dart';
import '../colors.dart';
import 'book_appointment_screen.dart';
import 'appointment_details_screen.dart';
import 'edit_appointment_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool showUpcoming = true;

  @override
  Widget build(BuildContext context) {
    String uid = AuthService.instance.uid;

    return Scaffold(
      backgroundColor: kBg,
      // + button only shows in the Upcoming tab (like the mockup)
      floatingActionButton: showUpcoming
          ? FloatingActionButton(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookAppointmentScreen(),
                ),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
            ),

            // Upcoming / History toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    _tabButton('Upcoming', showUpcoming, () {
                      setState(() => showUpcoming = true);
                    }),
                    _tabButton('History', !showUpcoming, () {
                      setState(() => showUpcoming = false);
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: AuthService.instance.appointmentsStream(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: kPrimary),
                    );
                  }

                  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                      snapshot.data?.docs ?? [];

                  List<QueryDocumentSnapshot<Map<String, dynamic>>> list =
                      docs.where((doc) {
                    String status = (doc.data()['status'] ?? 'Pending').toString();
                    String date = (doc.data()['date'] ?? '').toString();
                    bool isUpcoming = (status == 'Pending' || status == 'Approved') &&
                        date.compareTo(todayString()) >= 0;
                    return showUpcoming ? isUpcoming : !isUpcoming;
                  }).toList();

                  list.sort((a, b) => (b.data()['date'] ?? '')
                      .toString()
                      .compareTo((a.data()['date'] ?? '').toString()));

                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            showUpcoming
                                ? Icons.event_available_outlined
                                : Icons.history,
                            size: 50,
                            color: kPrimary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            showUpcoming
                                ? 'No upcoming appointments'
                                : 'No appointment history yet',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kTextDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            showUpcoming
                                ? 'Tap + to book a clinic visit.'
                                : 'Completed and cancelled visits appear here.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: kTextGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return _appointmentCard(list[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : kTextGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _appointmentCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data();
    String status = (data['status'] ?? 'Pending').toString();
    String date = (data['date'] ?? '').toString();
    bool editable = status == 'Pending' || status == 'Approved';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentDetailsScreen(doc: doc),
        ),
      ),
      child: AppCard(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
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
                      monthShort(date),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kPrimary,
                      ),
                    ),
                    Text(
                      dayNumber(date),
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
                      '${formatDate(date)} • ${data['time'] ?? ''}',
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
          if (editable) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAppointmentScreen(doc: doc),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: const BorderSide(color: kPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmCancel(doc),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kDanger,
                      side: const BorderSide(color: kDanger),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }

  void _confirmCancel(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel this appointment?'),
        content: const Text('You can book a new slot anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep it', style: TextStyle(color: kTextGrey)),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.instance
                  .appointmentsRef(AuthService.instance.uid)
                  .doc(doc.id)
                  .update({'status': 'Cancelled'});
              if (context.mounted) {
                Navigator.pop(context);
                showSnack(context, 'Appointment cancelled.');
              }
            },
            child: const Text('Yes, cancel', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
  }
}
