import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Get_Method.dart';
import 'Photo_Details.dart'; // Import the details screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Use GetMaterialApp instead of MaterialApp
      debugShowCheckedModeBanner: false,
      home: CircleAnimationScreen(),
    );
  }
}

class CircleAnimationScreen extends StatefulWidget {
  const CircleAnimationScreen({super.key});

  @override
  _CircleAnimationScreenState createState() => _CircleAnimationScreenState();
}

class _CircleAnimationScreenState extends State<CircleAnimationScreen> {
  List<Photo> photos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    final response = await http.get(Uri.parse('https://reqres.in/api/users?page=2'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];

      setState(() {
        photos = data.map((item) => Photo.fromJson(item)).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image List')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: List.generate(3, (colIndex) {
            return Column(
              children: [
                SizedBox(
                  height: 100, // Increased height to fit text
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                    itemCount: photos.length, // Number of images
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => Details(), arguments: {
                            "id": photos[index].id,
                            "first_name": photos[index].firstName,
                            "last_name": photos[index].lastName,
                            "email": photos[index].email,
                            "avatar": photos[index].avatar,
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 60, // Set your desired size
                              height: 60, // Set your desired size
                              margin: EdgeInsets.symmetric(horizontal: 5), // Space between images
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(photos[index].avatar),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 5), // Space between image and name
                            Text(
                              photos[index].firstName,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20), // Space between rows
              ],
            );
          }),
        ),
      ),
    );
  }
}

class Photo {
  final String id;
  final String avatar;
  final String firstName;
  final String lastName;
  final String email;

  Photo({
    required this.id,
    required this.avatar,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'].toString(),
      avatar: json['avatar'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
    );
  }
}
