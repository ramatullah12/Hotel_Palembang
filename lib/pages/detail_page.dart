import 'package:flutter/material.dart';
import 'dart:convert';

class DetailPage extends StatelessWidget {
  final Map data;

  const DetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(data['name'])),
      body: ListView(
        children: [
          (data['image'] ?? "").startsWith('http')
              ? Image.network(data['image'])
              : Image.memory(base64Decode(data['image'])),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(data['desc']),
          ),
        ],
      ),
    );
  }
}