import 'package:flutter/material.dart';
// import 'package:google_maps_webservice/places.dart';
import 'package:realm/realm.dart';
import 'package:yumify/utilities/localdb.dart';

class ListPage extends StatefulWidget {
  // constructor
  const ListPage({super.key});

  @override
  State<ListPage> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  //read from localdb
  List<Map<String, dynamic>> items = [];
  RestHelper restHelper = RestHelper();
  void _refreshData() async {
    final data = await restHelper.getAllRest();
    setState(() {
      items = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _restName = TextEditingController();

  void showBottomSheet(ObjectId? id) async {
    if (id != null) {
      final existingData = items.firstWhere((element) => element['id'] == id);
      _restName.text = existingData['name'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          //prevent keyboard from blocking textfield
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, //align column
          mainAxisSize: MainAxisSize.min, //align rows
          children: [
            TextField(
              controller: _restName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Fill your desire restaurant",
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addRest();
                  }
                  if (id != null) {
                    await _updateRest(id);
                  }

                  _restName.text = "";

                  //after create update, bottom sheet drop
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Add Restaurant" : "Update Restaurant",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //add restaurant
  Future<void> _addRest() async {
    if (_restName.text.isNotEmpty) {
      await restHelper.addRest(_restName.text);
      _refreshData();
    }
  }

// update restaurant
  Future<void> _updateRest(ObjectId id) async {
    if (_restName.text.isNotEmpty) {
      await restHelper.updateRest(id, _restName.text);
      //pop up after update data
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Successfully Updated"),
      ));
      _refreshData();
    }
  }

  Future<void> _deleteRest(ObjectId id) async {
    await restHelper.deleteRest(id);
    //pop after dlt data
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.red,
      content: Text("Restaurant Deleted"),
    ));
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Build Your List',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final restaurantName = items[index]['name'] as String;

          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 5,
            child: ListTile(
              title: Text(
                restaurantName,
                style: TextStyle(color: Colors.black87),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showBottomSheet(items[index]['id']);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteRest(items[index]['id']);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.grey[900], // Changed background color
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet(null);
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
}
