import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BabyAvatar extends StatefulWidget {
  final String babyKey; 
  final double size;

  const BabyAvatar({
    super.key,
    required this.babyKey,
    this.size = 84,
  });

  @override
  State<BabyAvatar> createState() => _BabyAvatarState();
}

class _BabyAvatarState extends State<BabyAvatar> {
  String? _path;

  String get _prefKey => 'baby_avatar_${widget.babyKey}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _path = prefs.getString(_prefKey));
  }

  Future<void> _pick() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'avatar_${widget.babyKey}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final saved = await File(picked.path).copy('${dir.path}/$fileName');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, saved.path);

    if (!mounted) return;
    setState(() => _path = saved.path);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.size / 2;
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: _pick,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: cs.primary.withValues(alpha: 0.18),
        backgroundImage: (_path != null && File(_path!).existsSync())
            ? FileImage(File(_path!))
            : null,
        child: (_path == null)
            ? Icon(Icons.tag_faces_rounded, size: 40, color: cs.primary)
            : null,
      ),
    );
  }
}
