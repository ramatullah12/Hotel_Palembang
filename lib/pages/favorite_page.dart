import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class FavoritePage extends StatelessWidget {
  final service = FirestoreService();

  FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorite")),
      body: StreamBuilder(
        stream: service.getFavorite(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              var f = data[i].data() as Map<String, dynamic>;

              return ListTile(
                leading: Image.network(f['image']),
                title: Text(f['hotel']),
              );
            },
          );
        },
      ),
    );
  }
}