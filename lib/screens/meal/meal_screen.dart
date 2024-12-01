import 'package:meal_planner/commons.dart';

part 'meal_controller.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MealScreenState();
}

class _MealScreenState extends MealController {
  final List<Map<String, dynamic>> _mealTypes = [
    {'title': 'Śniadanie', 'mealType': MealType.breakfast},
    {'title': 'II Śniadanie', 'mealType': MealType.brunch},
    {'title': 'Obiad', 'mealType': MealType.lunch},
    {'title': 'Przekąska', 'mealType': MealType.snack},
    {'title': 'Kolacja', 'mealType': MealType.dinner},
  ];

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
            children: _mealTypes.map((meal) {
              final mealType = meal['mealType'] as MealType;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: MealRow(
                  title: meal['title'] as String,
                  mealWithRecipe: _mealsWithRecipe[mealType],
                  mealCallback: _loadMealsForSelectedDay,
                  selectedDay: _selectedDay,
                  mealType: mealType,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}