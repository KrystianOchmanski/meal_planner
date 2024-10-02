import 'package:flutter/material.dart';
import 'package:meal_planner/widgets/meal_row.dart';
import 'package:meal_planner/widgets/weekly_date_picker.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Column(
        children: [
          WeeklyDatePicker(),
          Padding(padding: EdgeInsets.only(top: 20)),
          MealRow(title: 'Śniadanie'),
          Padding(padding: EdgeInsets.only(top: 5)),
          MealRow(title: 'II Śniadanie'),
          Padding(padding: EdgeInsets.only(top: 5)),
          MealRow(title: 'Obiad'),
          Padding(padding: EdgeInsets.only(top: 5)),
          MealRow(title: 'Przekąska'),
          Padding(padding: EdgeInsets.only(top: 5)),
          MealRow(title: 'Kolacja')
        ],
      ),
    );
  }
}
