import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => CommunityPageState();
}

class CommunityPageState extends State<CommunityPage> {
  // text fiedl controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final CollectionReference _items =
      FirebaseFirestore.instance.collection("Upload_Items");
  bool isLiked = false;
  // collection name must be same as firebase collection name

  String imageUrl = '';

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                right: 20,
                left: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text("Share your food review with us!"),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Name', hintText: 'eg Elon'),
                ),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                      labelText: 'Content', hintText: 'eg Leave a comment'),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                    child: IconButton(
                        onPressed: () async {
                          // add the package image_picker
                          final file = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (file == null) return;

                          String fileName =
                              DateTime.now().microsecondsSinceEpoch.toString();

                          // Get the reference to storage root
                          // We create the image folder first and insider folder we upload the image
                          Reference referenceRoot =
                              FirebaseStorage.instance.ref();
                          Reference referenceDireImages =
                              referenceRoot.child('images');

                          // we have creata reference for the image to be stored
                          Reference referenceImageaToUpload =
                              referenceDireImages.child(fileName);

                          // For errors handled and/or success
                          try {
                            await referenceImageaToUpload
                                .putFile(File(file.path));

                            // We have successfully upload the image now
                            // make this upload image link in firebase database

                            imageUrl =
                                await referenceImageaToUpload.getDownloadURL();
                          } catch (error) {
                            //some error
                          }
                        },
                        icon: const Icon(Icons.camera_alt))),
                Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          if (imageUrl.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Please select and upload image")));
                            return;
                          }
                          final String name = _nameController.text;
                          final String content = _contentController.text;
                          await _items.add({
                            // Add items in you firebase firestore
                            "name": name,
                            "content": content,
                            "image": imageUrl,
                          });
                          _nameController.text = '';
                          _contentController.text = '';
                          Navigator.of(context).pop();
                        },
                        child: const Text('Create')))
              ],
            ),
          );
        });
  }

  late Stream<QuerySnapshot> _stream;
  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance.collection('Upload_Items').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Community",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Some error occured${snapshot.error}"),
              );
            }
            // Now , Cheeck if datea arrived?
            if (snapshot.hasData) {
              QuerySnapshot querySnapshot = snapshot.data;
              List<QueryDocumentSnapshot> document = querySnapshot.docs;

              // We need to Convert your documnets to Maps to display
              List<Map> items = document.map((e) => e.data() as Map).toList();

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  Map thisItem = items[index];
                  return Card(
                    // Use a Card for better UI
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                              // Display the avatar image from the 'image' field
                              backgroundImage:
                                  AssetImage('assets/images/profile.jpg')),
                          title: Text(
                            thisItem['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // If there is a 'content' field in your items, use it here. Otherwise, replace it with appropriate data.
                          subtitle: Text(
                              thisItem['content'] ?? 'No content available'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            thisItem[
                                'image'], // The main image URL from your item data
                            fit: BoxFit.cover,
                            // you can set the height if you want to limit how large the image is
                            // height: 200.0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: isLiked
                                    ? Colors.red
                                    : null, // Change color to red if liked
                              ),
                              onPressed: () {
                                setState(() {
                                  isLiked = !isLiked; // Toggle the liked state
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.comment),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
      backgroundColor: Colors.grey[900],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _create();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
