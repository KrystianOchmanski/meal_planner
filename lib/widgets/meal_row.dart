import 'package:meal_planner/commons.dart';

class MealRow extends StatefulWidget {
  const MealRow({super.key, required this.title, required this.mealWithRecipe, required this.mealCallback, required this.selectedDay, required this.mealType, });

  final String title;
  final MealType mealType;
  final MealWithRecipe? mealWithRecipe;
  final VoidCallback mealCallback;
  final DateTime selectedDay;

  @override
  State<MealRow> createState() => _MealRowState();
}

class _MealRowState extends State<MealRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: (){
            if(widget.mealWithRecipe != null){
              _showSelectRecipeDialog(widget.mealWithRecipe);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 22),
                ),
                widget.mealWithRecipe == null
                ? Text(
                    'Nie wybrano',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300, color: Colors.black54)
                )
                : Text(
                  '${widget.mealWithRecipe!.recipeTitle} x ${widget.mealWithRecipe!.servings.toString()}',
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                    fontSize: 18
                  )
                )
              ],
            ),
          ),
        ),
        widget.mealWithRecipe == null
        ? IconButton(
          onPressed: (){
            _showSelectRecipeDialog(null);
          },
          iconSize: 48,
          icon: Icon(
            Icons.add_circle,
            color: Colors.green,
          )
        )
        : IconButton(
          onPressed: _removeMeal,
          iconSize: 48,
          icon: Icon(
            Icons.remove_circle_outline,
            //color: Colors.red,
          )
        )
      ],
    );
  }

  void _showSelectRecipeDialog(MealWithRecipe? meal) {
    showDialog(
      context: context,
      builder: (context) => RecipeSelectionDialog(
        selectedDay: widget.selectedDay,
        mealType: widget.mealType,
        onMealAdded: widget.mealCallback,
      ),
    );
  }

  void _removeMeal() {
    showDialog(
        context: context, 
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(
              'Czy na pewno chcesz usunąć posiłek?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  }, 
                  child: Text('Anuluj', style: GoogleFonts.poppins())
              ),
              ElevatedButton(
                  onPressed: () {
                    AppDatabase.instance.deleteMeal(widget.mealWithRecipe!.id);
                    widget.mealCallback();
                    Navigator.pop(context);
                  }, 
                  child: Text('Usuń', style: GoogleFonts.poppins(color: Colors.red)))
            ],
          );
        }
    );
  }
}
