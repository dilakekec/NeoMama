import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'edit_baby.dart'; 
import '../models/baby_profile.dart';
import 'dashboard.dart'; // Ensure this file contains the DashboardScreen class

class BabyList extends StatefulWidget {
  const BabyList({Key? key}) : super(key: key);

  @override
  State<BabyList> createState() => _BabyListState();
}

class _BabyListState extends State<BabyList> {
  List babies = [];

  Future<void> fetchBabies() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/babies'),
    );
    if (response.statusCode == 200) {
      setState(() {
        babies = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBabies(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Babies')),
      body: ListView.builder(
        itemCount: babies.length,
        itemBuilder: (context, index) {
          final baby = babies[index];
          return ListTile(
            title: Text(baby['name']),
            subtitle: Text('Birth Date: ${baby['birth_date']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DashboardScreen(
                    baby: BabyProfile.fromJson(baby),
                  )
                ),
              ).then((_) => fetchBabies());
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditBaby(baby: baby['id']),
                      ),
                    ).then((_) => fetchBabies());
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    final res = await http.delete(
                      Uri.parse('http://127.0.0.1:8000/api/baby/${baby['id']}'),
                    );
                    if (res.statusCode == 204) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deleted ${baby['name']}')),
                      );
                      fetchBabies();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting ${baby['name']}')),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
      