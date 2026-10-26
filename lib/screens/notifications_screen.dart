import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_widgets.dart';
import '../auth_service.dart';
import '../colors.dart';

// List of everything that happened with your appointments (bell icon)
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = AuthService.instance.uid;

    return Scaffold(
      backgroundColor: kBg,
      appBar: const WhiteHeader(title: 'Notifications'),
      body: StreamBuilder<QuerySnapshot>(
        stream: AuthService.instance.appointmentsStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimary),
            );
          }

          List<QueryDocumentSnapshot> docs =
              (snapshot.data?.docs ?? []).cast<QueryDocumentSnapshot>();

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 50, color: kPrimary),
                  SizedBox(height: 10),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your appointment updates will appear here.',
                    style: TextStyle(fontSize: 13, color: kTextGrey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  docs[index].data() as Map<String, dynamic>;
              String status = (data['status'] ?? 'Pending').toString();
              String date = (data['date'] ?? '').toString();
              String time = (data['time'] ?? '').toString();
              String reason = (data['reason'] ?? 'Clinic visit').toString();

              String title = 'Appointment request sent';
              String message =
                  'Your $reason on ${formatDate(date)} at $time is waiting for approval.';
              IconData icon = Icons.schedule;

              if (status == 'Approved') {
                title = 'Your appointment was approved';
                message =
                    '$reason • ${formatDate(date)} at $time at the School Clinic.';
                icon = Icons.check_circle_outline;
              } else if (status == 'Completed') {
                title = 'Appointment completed';
                message = '$reason • ${formatDate(date)}';
                icon = Icons.task_alt;
              } else if (status == 'Cancelled') {
                title = 'Appointment cancelled';
                message = '$reason • ${formatDate(date)}';
                icon = Icons.cancel_outlined;
              }

              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: statusBackground(status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: statusColor(status), size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kTextDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: kTextGrey,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            status == 'Pending' ? 'now' : formatDate(date),
                            style: const TextStyle(
                              fontSize: 11,
                              color: kTextGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
