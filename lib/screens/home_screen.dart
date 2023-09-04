import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item_screen.dart';
import 'package:shopping_list/widgets/grocery_item.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _error;
  var _isLoading = true;
  List<GroceryItem> _groceryItems = [];

  void _deleteItem(GroceryItem groceryItem) async {
    final index = _groceryItems.indexOf(groceryItem);
    setState(() {
      _groceryItems.remove(groceryItem);
    });

    final url = Uri.https("flutter-prep-c19e7-default-rtdb.firebaseio.com",
        'shopping-list/${groceryItem.id}.json');
    var response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, groceryItem);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        "flutter-prep-c19e7-default-rtdb.firebaseio.com", 'shopping-list.json');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch data. Please try again later";
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final _category = categories.entries.firstWhere(
            (catItem) => catItem.value.category == item.value['category']);
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: _category.value,
          ),
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = "Something went wrong. Please try again later";
      });
    }
  }

  void _onAddItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItemScreen()));
    // _loadItems();
    if (newItem == null) {
      return;
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

    if (_isLoading) {
      fallBackWidget = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      fallBackWidget = Center(
        child: Text(_error!),
      );
    }
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
                      _deleteItem(_groceryItems[index]);
                    },
                    key: ValueKey(_groceryItems[index].id),
                    child: SingleGroceryItem(
                      groceryItem: _groceryItems[index],
                    ),
                  ))),
    );
  }
}
