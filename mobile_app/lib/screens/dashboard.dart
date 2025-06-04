import 'package:flutter/material.dart';
import '../models/baby_profile.dart';

class DashboardScreen extends StatelessWidget {
  final BabyProfile baby;
  
  const DashboardScreen({Key? key, required this.baby}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F5),
      body: SafeArea(  
        child: Container(  
          decoration: const BoxDecoration(  
            gradient: LinearGradient(  
              colors: [Color(0xFFFFF1F5), Color(0xFFE5DFF7), Color(0xFFD2E3FC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(  
            children: [
              const SizedBox(height: 20),
              _buildBabyHeader(baby),
              const SizedBox(height: 20),
              _buildReminderPanel(),
              const SizedBox(height: 20),
              Expanded(child: _buildMainButtons(context)),
              _buildBottomMenu(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBabyHeader(BabyProfile baby) {
    return Column(  
      children: [
        const CircleAvatar(  
          radius: 40,
          backgroundImage: AssetImage('assets/images/icons/baby_avatar.png'),
        ),
        const SizedBox(height: 8),
        Text(baby.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text('DOB: ${baby.birthDate.split("T")[0]}', style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
  
  Widget _buildReminderPanel() {
    return Card(  
      margin: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(  
        padding: const EdgeInsets.all(16.0),
        child: Column(  
          children: const [
            Text("Today's Tips", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("🍼 Feed at 10:00, 14:00, 18:00"),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMainButtons(BuildContext context) {
    return Padding(  
      padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap( 
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,  
          children: [ 
            _buildNavButton(context, Icons.chat, "AI Chat", '/chat'),
            _buildNavButton(context, Icons.restaurant, "Feeding", '/feeding'),
            _buildNavButton(context, Icons.games, "Activities", '/play'),
            _buildNavButton(context, Icons.music_note, "Music", '/music'),
            _buildNavButton(context, Icons.forum, "Mama Forum", '/forum'),
          ],
        ),
    );
  }
      
  Widget _buildNavButton(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow( 
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.pinkAccent),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomMenu(BuildContext context) {
    return Padding(  
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(  
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _menuButton(context, Icons.home, 'Home', '/dashboard'),
          _menuButton(context, Icons.favorite, 'Favorites', '/favorites'),
          _menuButton(context, Icons.settings, 'Settings', '/settings'),
        ],
      ),
    );
  }
  
  Widget _menuButton(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(  
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(  
        children: [
          Icon(icon, color: Colors.pink, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}