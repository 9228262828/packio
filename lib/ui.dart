import 'package:flutter/material.dart';
import 'models.dart';

const forest = Color(0xFF285943);
const terracotta = Color(0xFFD97745);
const ivory = Color(0xFFF7F1E7);
const sand = Color(0xFFE8B86D);
const ink = Color(0xFF18251F);
const softGreen = Color(0xFFE3EEE7);

const packingCategories = <String>[
  'Clothes',
  'Documents',
  'Electronics',
  'Toiletries',
  'Medicines',
  'Work',
  'Other',
];

IconData categoryIcon(String category) {
  switch (category) {
    case 'Clothes':
      return Icons.checkroom_rounded;
    case 'Documents':
      return Icons.description_outlined;
    case 'Electronics':
      return Icons.devices_other_rounded;
    case 'Toiletries':
      return Icons.spa_outlined;
    case 'Medicines':
      return Icons.medication_outlined;
    case 'Work':
      return Icons.work_outline_rounded;
    default:
      return Icons.inventory_2_outlined;
  }
}

ThemeData packioTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: forest,
      brightness: brightness,
      primary: forest,
      secondary: terracotta,
    ),
    scaffoldBackgroundColor: dark ? const Color(0xFF111813) : ivory,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: dark ? const Color(0xFF1C261F) : const Color(0xFFFFFDF8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF1A231D) : const Color(0xFFFFFDF8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: dark ? Colors.white : ink,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: forest,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
  );
}

class PackioMark extends StatelessWidget {
  final double size;

  const PackioMark({super.key, this.size = 62});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: forest,
        borderRadius: BorderRadius.circular(size * .30),
        boxShadow: [
          BoxShadow(
            color: forest.withOpacity(.18),
            blurRadius: size * .28,
            offset: Offset(0, size * .12),
          ),
        ],
      ),
      child: Icon(
        Icons.luggage_rounded,
        size: size * .48,
        color: const Color(0xFFFFF8EC),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 14),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String dateLabel(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String dateRange(Trip trip) {
  if (trip.startDate.year == trip.endDate.year &&
      trip.startDate.month == trip.endDate.month &&
      trip.startDate.day == trip.endDate.day) {
    return dateLabel(trip.startDate);
  }
  return '${dateLabel(trip.startDate)} → ${dateLabel(trip.endDate)}';
}
