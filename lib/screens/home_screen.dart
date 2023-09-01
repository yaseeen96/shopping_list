import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item_screen.dart';
import 'package:shopping_list/widgets/grocery_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<GroceryItem> _groceryItems = [];
  void _onAddItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItemScreen()));
    if (newItem == null) {
      return null;
    } else {
      setState(() {
        _groceryItems.add(newItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget fallBackWidget = const Center(
      child: Text("No Groceries found. Try adding some groceries"),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your groceries"),
        actions: [
          IconButton(
            onPressed: _onAddItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: _groceryItems.isEmpty
          ? fallBackWidget
          : ListView.builder(
              itemCount: _groceryItems.length,
              itemBuilder: ((context, index) => Dismissible(
                    direction: DismissDirection.endToStart,
                    background: Container(
                      width: double.infinity,
                      color: Colors.red,
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        _groceryItems.remove(_groceryItems[index]);
                      });
                    },
                    key: ValueKey(_groceryItems[index].id),
                    child: SingleGroceryItem(
                      groceryItem: _groceryItems[index],
                    ),
                  ))),
    );
  }
}
