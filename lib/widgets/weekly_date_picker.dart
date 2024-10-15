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
  late DateTime _selectedDay;
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
      child: SizedBox(
        height: 85,
        //color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                getMonthName(weekDates).toUpperCase(),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w300, fontSize: 13),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDates.map((date) {
                bool isSelected = _isSameDay(date, _selectedDay);
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDay = date;
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //const Padding(padding: EdgeInsets.only(top: 8)),
                              Text(DateFormat.EEEEE('pl_PL').format(date).toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: isSelected ? Colors.white : Colors.black
                                  )
                              ), // Dzień tygodnia
                              Text(DateFormat.d().format(date),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 15,
                                    color: isSelected ? Colors.white : Colors.black
                                  )
                              ), // Dzień miesiąca
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
    _selectedDay = DateTime.now();
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

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
