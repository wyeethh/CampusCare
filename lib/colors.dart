import 'package:flutter/material.dart';

// CampusCare color palette
const kPrimary = Color(0xFF0F766E);
const kPrimaryDark = Color(0xFF0B5F59);
const kPrimarySoft = Color(0xFFD8EFEC);
const kBg = Color(0xFFF4FAF9);
const kCard = Colors.white;
const kBorder = Color(0xFFE3EDEB);
const kTextDark = Color(0xFF0F1B2D);
const kTextGrey = Color(0xFF6B7B8A);
const kDanger = Color(0xFFDC2626);
const kDangerSoft = Color(0xFFFEE2E2);

// Status colors
Color statusColor(String status) {
  switch (status) {
    case 'Approved':
      return const Color(0xFF2563EB);
    case 'Completed':
      return const Color(0xFF16A34A);
    case 'Cancelled':
      return kDanger;
    default:
      return const Color(0xFFF59E0B); // Pending
  }
}

Color statusBackground(String status) {
  switch (status) {
    case 'Approved':
      return const Color(0xFFDBEAFE);
    case 'Completed':
      return const Color(0xFFDCFCE7);
    case 'Cancelled':
      return kDangerSoft;
    default:
      return const Color(0xFFFEF3C7);
  }
}
