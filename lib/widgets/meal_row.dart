import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/data/database.dart';
import 'package:meal_planner/models/meal_with_recipe.dart';

import '../data/tables.dart';
import '../utils.dart';

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
  List<Recipe>? _allRecipes;
  List<Recipe>? _filteredRecipes;
  final TextEditingController _filterController = TextEditingController();

  @override
  void initState() {
    _loadAllRecipes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
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
                widget.mealWithRecipe!.recipeTitle,
                style: GoogleFonts.poppins(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                  fontSize: 16
                )
              )
            ],
          ),
        ),
        widget.mealWithRecipe == null
        ? IconButton(
          onPressed: _showSelectRecipeDialog,
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

  void _loadAllRecipes() async {
    var recipes = await AppDatabase.instance.getAllRecipes();
    setState(() {
      _allRecipes = recipes;
      _filteredRecipes = recipes;
    });
  }



  void _showSelectRecipeDialog() {
    _loadAllRecipes(); // todo zrobic to lepiej
    Recipe? selectedRecipe;
    int servings = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void filterRecipes(String query) {
              setState(() {
                _filteredRecipes = _allRecipes?.where((recipe) =>
                    recipe.title.toLowerCase().contains(query.toLowerCase())).toList();
              });
            }

            return AlertDialog(
              title: Text('Wybierz przepis', style: GoogleFonts.poppins()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text('Liczba porcji'),
                        IconButton(
                          onPressed: () {
                            if (servings > 1) {
                              setState(() {
                                servings--;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove_circle),
                        ),
                        Text(servings.toString()),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              servings++;
                            });
                          },
                          icon: const Icon(Icons.add_circle),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _filterController,
                      decoration: InputDecoration(
                        labelText: 'Filtruj przepisy',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: filterRecipes,
                    ),
                    SizedBox(height: 10),
                    _filteredRecipes != null
                        ? SizedBox(
                          height: 200,
                          child: SingleChildScrollView(
                            child: Column(
                              children: _filteredRecipes!.map((recipe){
                                return ListTile(
                                  title: Text(recipe.title, style: GoogleFonts.poppins()),
                                  selected: selectedRecipe == recipe,
                                  onTap: () {
                                    setState(() {
                                      selectedRecipe = recipe;
                                    });
                                  },
                                );
                              }).toList(),
                            )
                          ),
                        )
                        : CircularProgressIndicator(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Anuluj', style: GoogleFonts.poppins(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: selectedRecipe != null
                      ? () async {
                        await AppDatabase.instance.insertMeal(MealsCompanion(
                            date: Value(widget.selectedDay),
                            mealType: Value(widget.mealType),
                            recipeId: Value(selectedRecipe!.id),
                            servings: Value(servings)
                          )
                        );
                        widget.mealCallback();
                        Navigator.of(context).pop();
                      }
                      : null,
                  child: Text('Dodaj', style: GoogleFonts.poppins()),
                ),
              ],
            );
          },
        );
      },
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
                  onPressed: () async {
                    await AppDatabase.instance.deleteMeal(widget.mealWithRecipe!.id);
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
