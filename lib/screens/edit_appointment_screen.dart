import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_widgets.dart';
import '../auth_service.dart';
import '../colors.dart';

class EditAppointmentScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  const EditAppointmentScreen({super.key, required this.doc});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  late String? _date;
  late String _time;
  late String _reason;
  final _notes = TextEditingController();
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
  void initState() {
    super.initState();
    Map<String, dynamic> data = widget.doc.data();
    _date = (data['date'] ?? '').toString();
    _time = (data['time'] ?? '9:30 AM').toString();
    _reason = (data['reason'] ?? 'General check-up').toString();
    _notes.text = (data['notes'] ?? '').toString();
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_date ?? '') ?? DateTime.now(),
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      String m = picked.month.toString().padLeft(2, '0');
      String d = picked.day.toString().padLeft(2, '0');
      setState(() => _date = '${picked.year}-$m-$d');
    }
  }

  Future<void> _save() async {
    if (_date == null || _date!.isEmpty) {
      showSnack(context, 'Please select a date.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.instance
          .appointmentsRef(AuthService.instance.uid)
          .doc(widget.doc.id)
          .update({
        'date': _date,
        'time': _time,
        'reason': _reason,
        'notes': _notes.text.trim(),
      });
      if (mounted) {
        showSnack(context, 'Changes saved.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to save changes.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const WhiteHeader(title: 'Edit appointment'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reminder banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Changes are saved to your booking.',
                      style: TextStyle(
                        fontSize: 13,
                        color: kTextDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

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
                      (_date == null || _date!.isEmpty)
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

            const SizedBox(height: 20),

            AppButton(label: 'Save changes', loading: _loading, onPressed: _save),
            const SizedBox(height: 12),
            AppButton(
              label: 'Discard changes',
              color: kPrimary,
              filled: false,
              onPressed: () => Navigator.pop(context),
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
