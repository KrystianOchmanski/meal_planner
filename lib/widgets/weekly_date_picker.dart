import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class WeeklyDatePicker extends StatefulWidget {
  const WeeklyDatePicker({super.key});

  @override
  State<WeeklyDatePicker> createState() => _WeeklyDatePickerState();
}

class _WeeklyDatePickerState extends State<WeeklyDatePicker> {
  late DateTime _currentDate;
  late List<DateTime> weekDates;
  double initialX = 0.0;
  double finalX = 0.0;
  double deltaX = 0.0;
  double distanceThreshold = 100.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        initialX = details.globalPosition.dx;
      },
      onHorizontalDragEnd: (details) {
        finalX = details.globalPosition.dx;
        deltaX = initialX - finalX;

        // Sprawdzenie, czy przeciągnięcie przekracza próg
        if (deltaX.abs() > distanceThreshold) {
          setState(() {
            if (deltaX < 0) {
              //Swipe Left
              _currentDate = _currentDate.subtract(const Duration(days: 7));
            } else {
              //Swipe Right
              _currentDate = _currentDate.add(const Duration(days: 7));
            }
            weekDates = _getWeekDates(_currentDate);
          });
        }
      },
      child: Container(
        height: 75,
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(top: 3)),
            Text(
              getMonthName(weekDates).toUpperCase(),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300, fontSize: 13),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDates.map((date) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 8)),
                    Text(DateFormat.EEEEE('pl_PL').format(date).toUpperCase(),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15)), // Dzień tygodnia
                    Text(DateFormat.d().format(date),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w300,
                            fontSize: 15)), // Dzień miesiąca
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    initializeDateFormatting();
    _currentDate = DateTime.now();
    weekDates = _getWeekDates(_currentDate);
    super.initState();
  }

  List<DateTime> _getWeekDates(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String getMonthName(List<DateTime> weekDates) {
    if (weekDates.first.month == weekDates.last.month) {
      return DateFormat.MMMM('pl_PL').format(weekDates.first);
    } else {
      return '${DateFormat.MMMM('pl_PL').format(weekDates.first)}/${DateFormat.MMMM('pl_PL').format(weekDates.last)}';
    }
  }
}
