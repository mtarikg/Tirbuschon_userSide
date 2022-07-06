import 'package:flutter/material.dart';
import '../../../services/firestoreService.dart';

class MenuPage extends StatefulWidget {
  final String venueID;
  final String venueName;

  const MenuPage({Key? key, required this.venueName, required this.venueID})
      : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  var menuCategories = [];
  var categoryItems = [];

  getMenu() async {
    var menuData = await FirestoreService().getMenu(widget.venueID);
    var menuValue = menuData["Menu"];
    setState(() {
      menuValue.keys.toList().forEach((key) => menuCategories.add(key));
      menuValue.values.toList().forEach((value) => categoryItems.add(value));
    });
  }

  @override
  void initState() {
    super.initState();
    getMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.venueName)),
      body: Center(
        child: ListView.builder(
          itemCount: menuCategories.length,
          itemBuilder: (context, int index) {
            return Column(
              children: [
                const SizedBox(height: 15),
                Container(
                  width: MediaQuery.of(context).size.width - 30,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CategoryItems(
                                  categoryName: menuCategories[index],
                                  categoryItems: categoryItems[index])));
                    },
                    child: Text(
                      menuCategories[index].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CategoryItems extends StatelessWidget {
  final String categoryName;
  final dynamic categoryItems;

  const CategoryItems(
      {Key? key, required this.categoryItems, required this.categoryName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: Center(
        child: ListView.builder(
            itemCount: categoryItems.length,
            itemBuilder: (context, int index) {
              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(categoryItems[index]["Name"],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(width: 20),
                    Text(categoryItems[index]["Price"].toString() + "₺"),
                  ],
                ),
              );
            }),
      ),
    );
  }
}