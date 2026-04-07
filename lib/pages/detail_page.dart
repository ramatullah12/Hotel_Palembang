import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final Map data;

  const DetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(data['name'])),
      body: ListView(
        children: [
          Image.network(data['image']),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(data['desc']),
          ),
        ],
      ),
    );
  }
}