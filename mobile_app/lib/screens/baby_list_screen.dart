import 'package:flutter/material.dart';
import '../services/baby_service.dart';
import '../utils/date_utils.dart';


class BabyListScreen extends StatefulWidget {
  const BabyListScreen({super.key});

  @override
  State<BabyListScreen> createState() => _BabyListScreenState();
}

class _BabyListScreenState extends State<BabyListScreen> {
  List<Map<String, dynamic>> _babyList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBabies();
  }

  Future<void> loadBabies() async {
    final babies = await BabyService().fetchBabyProfiles();
    setState(() {
      _babyList = babies;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(title: const Text("My Babies")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _babyList.length,
              itemBuilder: (context, index) {
                final baby = _babyList[index];
                return ListTile(
                  title: Text(baby['name'] ?? 'Unknown'),
                  subtitle: Column(  
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Birth Date: ${baby['birthDate']}"),
                      Text("Age: ${calculateAge(baby['birthDate'])}"),
                    ],
                  ),
                  trailing: Text(baby['feedingPreferences'] ?? ''),
                );
              },
          ),
    );
  }
}
