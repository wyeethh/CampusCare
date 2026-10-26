import 'dart:io';

import 'package:flutter/material.dart';

import 'colors.dart';

// ---------------------------------------------------------------------------
// Small reusable widgets used in every screen so everything looks aligned
// ---------------------------------------------------------------------------

// Full width rounded button (teal filled by default)
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color color;
  final bool filled;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.color = kPrimary,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? color : Colors.white,
          foregroundColor: filled ? Colors.white : color,
          disabledBackgroundColor: filled ? color : Colors.white,
          side: filled ? null : BorderSide(color: color, width: 1.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

// White card used everywhere
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F1B2D),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Text field with a small label on top (like the mockup)
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final String? hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.hint,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kTextGrey,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && hidden,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: const TextStyle(fontSize: 15, color: kTextDark),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: kTextGrey, fontSize: 14),
            prefixIcon: Icon(widget.icon, size: 20, color: kPrimary),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      hidden ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: kTextGrey,
                    ),
                    onPressed: () => setState(() => hidden = !hidden),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            border: border(kBorder),
            enabledBorder: border(kBorder),
            focusedBorder: border(kPrimary),
            errorBorder: border(kDanger),
            focusedErrorBorder: border(kDanger),
          ),
        ),
      ],
    );
  }
}

// Small pill showing Pending / Approved / Completed / Cancelled
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusBackground(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: statusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: statusColor(status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Small label + value row used in the details / profile screens
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: kPrimarySoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: kPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: kTextGrey),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? "Not set" : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Profile picture: network image, saved file, or initials
Widget profileAvatar(String photo, String name, double size) {
  if (photo.isNotEmpty && photo.startsWith('http')) {
    return ClipOval(
      child: Image.network(photo, width: size, height: size, fit: BoxFit.cover),
    );
  }
  if (photo.isNotEmpty && File(photo).existsSync()) {
    return ClipOval(
      child: Image.file(File(photo), width: size, height: size, fit: BoxFit.cover),
    );
  }
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: Text(
      initials(name),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    ),
  );
}

String initials(String name) {
  List<String> parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || name.trim().isEmpty) return "S";
  if (parts.length == 1) {
    return parts[0].substring(0, 1).toUpperCase();
  }
  return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1))
      .toUpperCase();
}

// Simple date helpers (no extra package needed)
const List<String> monthNames = [
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
];

const List<String> dayNames = [
  "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun",
];

// date stored as "yyyy-MM-dd"
String formatDate(String date) {
  try {
    DateTime d = DateTime.parse(date);
    String day = dayNames[d.weekday - 1];
    return "$day, ${d.day} ${monthNames[d.month - 1]} ${d.year}";
  } catch (e) {
    return date;
  }
}

String monthShort(String date) {
  try {
    DateTime d = DateTime.parse(date);
    return monthNames[d.month - 1].toUpperCase();
  } catch (e) {
    return "";
  }
}

String dayNumber(String date) {
  try {
    return DateTime.parse(date).day.toString();
  } catch (e) {
    return "";
  }
}

String todayString() {
  DateTime now = DateTime.now();
  String m = now.month.toString().padLeft(2, "0");
  String d = now.day.toString().padLeft(2, "0");
  return "${now.year}-$m-$d";
}

// Turns "2026-11-03" + "9:30 AM" into a DateTime
DateTime appointmentDateTime(String date, String time) {
  DateTime day = DateTime.tryParse(date) ?? DateTime.now();
  int hour = 9;
  int minute = 0;

  try {
    List<String> parts = time.split(' ');
    List<String> clock = parts[0].split(':');
    hour = int.parse(clock[0]);
    minute = int.parse(clock[1]);
    if (parts.length > 1 && parts[1] == 'PM' && hour < 12) hour += 12;
    if (parts.length > 1 && parts[1] == 'AM' && hour == 12) hour = 0;
  } catch (e) {
    // Keep the default time when the format is unexpected
  }

  return DateTime(day.year, day.month, day.day, hour, minute);
}

// White top bar used by the pushed screens (matches the mockup)
class WhiteHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const WhiteHeader({super.key, required this.title, this.actions = const []});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: kTextDark,
      elevation: 0,
      centerTitle: false,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: kTextDark,
        ),
      ),
      actions: actions,
    );
  }
}

// Toast message
void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: kTextDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
}
