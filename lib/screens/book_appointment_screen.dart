import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_widgets.dart';
import '../auth_service.dart';
import '../colors.dart';
import '../notifications_helper.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _notes = TextEditingController();

  String? _date; // yyyy-MM-dd
  String _time = '9:30 AM';
  String _reason = 'General check-up';
  bool _remind = true;
  bool _loading = false;

  final List<String> _times = [
    '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM',
    '1:30 PM', '2:00 PM', '2:30 PM', '3:00 PM',
  ];

  final List<String> _reasons = [
    'General check-up',
    'Dental',
    'Vaccine',
    'Medical certificate',
    'Other',
  ];

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      String m = picked.month.toString().padLeft(2, '0');
      String d = picked.day.toString().padLeft(2, '0');
      setState(() => _date = '${picked.year}-$m-$d');
    }
  }

  Future<void> _book() async {
    if (_date == null) {
      showSnack(context, 'Please select a date.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.instance
          .appointmentsRef(AuthService.instance.uid)
          .add({
        'date': _date,
        'time': _time,
        'reason': _reason,
        'notes': _notes.text.trim(),
        'remind': _remind,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Local notification reminder
      if (_remind) {
        DateTime appointment = appointmentDateTime(_date!, _time);
        DateTime reminder = appointment.subtract(const Duration(hours: 1));
        NotificationsHelper.schedule(
          'Clinic reminder',
          'Your $_reason appointment is at $_time. Please arrive 10 minutes early.',
          reminder,
        );
      }

      if (mounted) {
        showSnack(context, 'Appointment booked. Waiting for approval.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, 'Failed to book appointment. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const WhiteHeader(title: 'Book appointment'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            const Text(
              'Date',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextGrey,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, color: kPrimary),
                    const SizedBox(width: 10),
                    Text(
                      _date == null
                          ? 'Select date'
                          : formatDate(_date!),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kTextDark,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down, color: kTextGrey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Time
            const Text(
              'Choose a time',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextGrey,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _times.map((time) {
                return _choiceChip(time, _time == time, () {
                  setState(() => _time = time);
                });
              }).toList(),
            ),

            const SizedBox(height: 18),

            // Reason
            const Text(
              'Reason',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextGrey,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _reasons.map((reason) {
                return _choiceChip(reason, _reason == reason, () {
                  setState(() => _reason = reason);
                });
              }).toList(),
            ),

            const SizedBox(height: 18),

            AppTextField(
              controller: _notes,
              label: 'Notes (optional)',
              icon: Icons.notes,
              hint: 'Describe how you feel...',
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, color: kPrimary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Remind me 1 hour before',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextDark,
                      ),
                    ),
                  ),
                  Switch(
                    value: _remind,
                    activeThumbColor: kPrimary,
                    onChanged: (value) => setState(() => _remind = value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            AppButton(
              label: 'Book appointment',
              loading: _loading,
              onPressed: _book,
            ),

            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Only you can see this information',
                style: TextStyle(fontSize: 12, color: kTextGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? kPrimary : kBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : kTextDark,
          ),
        ),
      ),
    );
  }
}
