import 'package:drift/drift.dart' hide Column;

import '../../commons.dart';

part 'add_edit_recipe_controller.dart';

class AddOrEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;
  final List<Product> allProducts;

  const AddOrEditRecipeScreen({super.key, this.recipe, required this.allProducts});

  @override
  State<AddOrEditRecipeScreen> createState() => _AddOrEditRecipeScreenState();
}

class _AddOrEditRecipeScreenState extends AddEditRecipeController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: BackButton(
          onPressed: backBtnPressed,
        ),
        centerTitle: true,
        title: Text(
            widget.recipe == null ? 'Dodaj przepis' : 'Edytuj przepis',
            style: GoogleFonts.poppins()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if(widget.recipe != null)
            IconButton(
                onPressed: () => deleteRecipe(widget.recipe!),
                icon: Icon(Icons.delete)
            ),
          IconButton(onPressed: saveRecipe, icon: const Icon(Icons.check)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Tytuł',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return "Wprowadź tytuł";
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Liczba porcji'),
                    IconButton(
                        onPressed: (){
                          if(_servings > 1){
                            setState(() {
                              _servings--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle)
                    ),
                    Text(_servings.toString()),
                    IconButton(
                        onPressed: (){
                          setState(() {
                            _servings++;
                          });
                        },
                        icon: const Icon(Icons.add_circle)
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                        'Składniki',
                        style: TextStyle(fontSize: 24)
                    ),
                    IconButton(
                        onPressed: showAddProductDialog,
                        icon: const Icon(Icons.add_circle_outline))
                  ],
                ),
                if (_recipeProductsCompanion.isEmpty) const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Text('Dodaj składniki', style: TextStyle(color: Colors.grey)),
                  ),
                ) else ListView.builder(
                    shrinkWrap: true, //aby ListView zajmował minimalną ilość miejsca
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recipeProductsCompanion.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                                widget.allProducts
                                    .firstWhere((Product product){
                                      return product.id == _recipeProductsCompanion[index].productId.value;})
                                    .name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                                '${formatter.format(_recipeProductsCompanion[index].quantity.value)} '
                                    '${widget.allProducts.firstWhere((product) => product.id == _recipeProductsCompanion[index].productId.value).unit}'
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () => deleteRecipeProduct(index),
                            icon: Icon(Icons.close),
                          ),
                        ],
                      );
                    }
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _instructionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Instrukcje...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}