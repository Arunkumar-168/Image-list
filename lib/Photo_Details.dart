import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text("Details of ${data['first_name']}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Display Image
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(data['avatar']),
                ),
                SizedBox(height: 10),
                Text(
                  "${data['first_name']} ${data['last_name']}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Email: ${data['email']}",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
