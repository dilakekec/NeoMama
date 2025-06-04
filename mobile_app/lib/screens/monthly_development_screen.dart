import 'package:flutter/material.dart';
import'../data/monthly_development_data.dart';

class MonthlyDevelopmentScreen extends StatefulWidget {
  const MonthlyDevelopmentScreen({super.key});

  @override
  State<MonthlyDevelopmentScreen> createState() => _MonthlyDevelopmentScreenState();
}

class _MonthlyDevelopmentScreenState extends State<MonthlyDevelopmentScreen> {
  int? selectedMonth; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Development')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(  
          children: [
            DropdownButton<int>(  
              hint: const Text('Select Month'),
              value: selectedMonth,
              items: List.generate(25, (index) => index).map((month) {
                return DropdownMenuItem(
                  value: month,
                  child: Text('$month Month${month == 0 ? ' (Newborn)' : ''}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMonth = value;
                });
              },
            ),
            const SizedBox(height: 16),
            if (selectedMonth != null && monthlyDevelopmentData.containsKey(selectedMonth))
              Expanded(  
                child: SingleChildScrollView(  
                  child: Card(  
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(  
                      padding: const EdgeInsets.all(16),
                      child: Column(  
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(monthlyDevelopmentData[selectedMonth]!['title']!,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Text('🧠 Physical:\n${monthlyDevelopmentData[selectedMonth]!['physical']}'),
                            const SizedBox(height: 12),
                            Text('😴 Sleep:\n${monthlyDevelopmentData[selectedMonth]!['sleep']}'),
                            const SizedBox(height: 12),
                            Text('🍽 Feeding:\n${monthlyDevelopmentData[selectedMonth]!['feeding']}'),
                            const SizedBox(height: 12),
                            Text('📝 Note:\n${monthlyDevelopmentData[selectedMonth]!['note']}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Divider(),
            const Align(  
              alignment: Alignment.centerLeft,
              child: Text('All Months', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(  
              child: ListView.builder(  
                itemCount: monthlyDevelopmentData.length,
                itemBuilder: (context, index) {
                  final month = monthlyDevelopmentData.keys.elementAt(index);
                  final title = monthlyDevelopmentData[month]!['title']!;
                  return ListTile(  
                    title: Text(title),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      setState(() {
                        selectedMonth = month;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}