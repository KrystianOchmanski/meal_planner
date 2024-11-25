import 'package:meal_planner/commons.dart';

part 'meal_controller.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MealScreenState();
}

class _MealScreenState extends MealController {
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
}
