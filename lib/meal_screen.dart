import 'package:flutter/material.dart';
import 'package:meal_planner/data/database.dart';
import 'package:meal_planner/data/tables.dart';
import 'package:meal_planner/models/meal_with_recipe.dart';
import 'package:meal_planner/widgets/meal_row.dart';
import 'package:meal_planner/widgets/weekly_date_picker.dart';

class MealScreen extends StatefulWidget {
  final AppDatabase db = AppDatabase.instance;

  MealScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  DateTime _selectedDay = DateTime.now();
  Map<MealType, MealWithRecipe> _mealsWithRecipe = {};
  bool _isLoading = true;

  @override
  void initState() {
    _loadMealsForSelectedDay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          WeeklyDatePicker(onDateSelected: _onDateSelected),
          const Padding(padding: EdgeInsets.only(top: 20)),
          _isLoading
              ? CircularProgressIndicator()
              : Column(
            children: [
              MealRow(title: 'Śniadanie', mealWithRecipe: _mealsWithRecipe[MealType.breakfast], mealCallback: _loadMealsForSelectedDay, selectedDay: _selectedDay, mealType: MealType.breakfast),
              const Padding(padding: EdgeInsets.only(top: 10)),
              MealRow(title: 'II Śniadanie', mealWithRecipe: _mealsWithRecipe[MealType.brunch], mealCallback: _loadMealsForSelectedDay, selectedDay: _selectedDay, mealType: MealType.brunch),
              const Padding(padding: EdgeInsets.only(top: 10)),
              MealRow(title: 'Obiad', mealWithRecipe: _mealsWithRecipe[MealType.lunch], mealCallback: _loadMealsForSelectedDay, selectedDay: _selectedDay, mealType: MealType.lunch),
              const Padding(padding: EdgeInsets.only(top: 10)),
              MealRow(title: 'Przekąska', mealWithRecipe: _mealsWithRecipe[MealType.snack], mealCallback: _loadMealsForSelectedDay, selectedDay: _selectedDay, mealType: MealType.snack),
              const Padding(padding: EdgeInsets.only(top: 10)),
              MealRow(title: 'Kolacja', mealWithRecipe: _mealsWithRecipe[MealType.dinner], mealCallback: _loadMealsForSelectedDay, selectedDay: _selectedDay, mealType: MealType.dinner),
            ],
          ),
        ],
      ),
    );
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDay = date;
      _isLoading = true;
    });
    _loadMealsForSelectedDay();
  }

  void _loadMealsForSelectedDay() async {
    final meals = await widget.db.getMealsWithRecipeTitleForDate(_selectedDay);
    setState(() {
      _mealsWithRecipe = {
        for (var meal in meals) meal.mealType: meal
      };
      _isLoading = false;
    });
  }
}
