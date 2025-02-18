import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Photo_Details.dart'; // Import the details screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
    final response =
    await http.get(Uri.parse('https://reqres.in/api/users?page=2'));
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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Image List')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<Photo> firstColumn = List.from(photos); // Unchanged
    List<Photo> secondColumn = List.from(photos)
      ..sort((a, b) => a.firstName.compareTo(b.firstName)); // A → Z
    List<Photo> thirdColumn = List.from(photos)
      ..sort((b, a) => a.firstName.compareTo(b.firstName)); // Z → A

    return Scaffold(
      appBar: AppBar(title: Text('Image List')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            buildRow(firstColumn, "Default Order"), // First column (original order)
            buildRow(secondColumn, "A → Z Order"), // Second column (A → Z)
            buildRow(thirdColumn, "Z → A Order"), // Third column (Z → A)
          ],
        ),
      ),
    );
  }

  Widget buildRow(List<Photo> photoList, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 100, // Increased height to fit text
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photoList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => Details(), arguments: {
                    "id": photoList[index].id,
                    "first_name": photoList[index].firstName,
                    "last_name": photoList[index].lastName,
                    "email": photoList[index].email,
                    "avatar": photoList[index].avatar,
                  });
                },
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(photoList[index].avatar),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      photoList[index].firstName,
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
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
