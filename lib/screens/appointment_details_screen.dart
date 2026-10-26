import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_widgets.dart';
import '../auth_service.dart';
import '../colors.dart';
import 'edit_appointment_screen.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  const AppointmentDetailsScreen({super.key, required this.doc});

  Future<void> _simulateStatus(BuildContext context) async {
    Map<String, dynamic> data = doc.data();
    String status = (data['status'] ?? 'Pending').toString();
    String next = 'Approved';

    if (status == 'Approved') next = 'Completed';
    if (status == 'Completed' || status == 'Cancelled') return;

    await AuthService.instance
        .appointmentsRef(AuthService.instance.uid)
        .doc(doc.id)
        .update({'status': next});

    if (context.mounted) {
      showSnack(context, 'Status updated to $next (simulated).');
    }
  }

  Future<void> _cancel(BuildContext context) async {
    bool? yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel this appointment?'),
        content: const Text('You can book a new slot anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it', style: TextStyle(color: kTextGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, cancel', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );

    if (yes == true) {
      await AuthService.instance
          .appointmentsRef(AuthService.instance.uid)
          .doc(doc.id)
          .update({'status': 'Cancelled'});
      if (context.mounted) showSnack(context, 'Appointment cancelled.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const WhiteHeader(title: 'Appointment details'),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: AuthService.instance
            .appointmentsRef(AuthService.instance.uid)
            .doc(doc.id)
            .snapshots(),
        builder: (context, snapshot) {
          Map<String, dynamic> data =
              snapshot.data?.data() ?? doc.data();

          String status = (data['status'] ?? 'Pending').toString();
          String date = (data['date'] ?? '').toString();
          String time = (data['time'] ?? '').toString();
          String reason = (data['reason'] ?? 'Clinic visit').toString();
          String notes = (data['notes'] ?? '').toString();
          bool editable = status == 'Pending' || status == 'Approved';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kPrimary, kPrimaryDark],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusChip(status: status),
                      const SizedBox(height: 12),
                      Text(
                        reason,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16, color: Colors.white70),
                          SizedBox(width: 4),
                          Text(
                            'School Clinic',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                AppCard(
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Date',
                        value: formatDate(date),
                      ),
                      const Divider(color: kBorder),
                      InfoRow(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: time,
                      ),
                      const Divider(color: kBorder),
                      InfoRow(
                        icon: Icons.notes,
                        label: 'Notes',
                        value: notes,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 12),

                AppCard(child: _statusTracker(status)),

                if (editable)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: TextButton(
                        onPressed: () => _simulateStatus(context),
                        child: const Text(
                          'Simulate next status (for demo)',
                          style: TextStyle(fontSize: 12, color: kTextGrey),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                AppButton(
                  label: 'Edit appointment',
                  onPressed: editable
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditAppointmentScreen(doc: doc),
                            ),
                          )
                      : null,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Cancel appointment',
                  color: kDanger,
                  filled: false,
                  onPressed: editable ? () => _cancel(context) : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusTracker(String status) {
    List<String> steps = ['Pending', 'Approved', 'Completed'];
    int current = steps.indexOf(status);
    if (status == 'Cancelled') current = -1;

    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= current ? kPrimary : Colors.white,
                  border: Border.all(
                    color: i <= current ? kPrimary : kBorder,
                    width: 2,
                  ),
                ),
                child: i <= current
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : const SizedBox(),
              ),
              const SizedBox(height: 6),
              Text(
                steps[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: i <= current ? kPrimary : kTextGrey,
                ),
              ),
            ],
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.only(bottom: 20),
                color: i < current ? kPrimary : kBorder,
              ),
            ),
        ],
      ],
    );
  }
}
