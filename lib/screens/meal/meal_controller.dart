part of 'meal_screen.dart';

abstract class MealController extends State<MealScreen>{
  final AppDatabase db = AppDatabase.instance;
  DateTime _selectedDay = DateTime.now();
  Map<MealType, MealWithRecipe> _mealsWithRecipe = {};
  bool _isLoading = true;

  @override
  void initState() {
    _loadMealsForSelectedDay();
    super.initState();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDay = date;
      _isLoading = true;
    });
    _loadMealsForSelectedDay();
  }

  void _loadMealsForSelectedDay() async {
    final meals = await db.getMealsWithRecipeTitleForDate(_selectedDay);
    setState(() {
      _mealsWithRecipe = {
        for (var meal in meals) meal.mealType: meal
      };
      _isLoading = false;
    });
  }
}