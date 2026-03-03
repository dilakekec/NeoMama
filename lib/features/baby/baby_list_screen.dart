import 'package:flutter/material.dart';

import '../../models/baby_profile.dart';
import '../../services/baby_service.dart';
import 'baby_form.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/config/route_names.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class BabyListScreen extends StatefulWidget {
  const BabyListScreen({super.key});

  @override
  State<BabyListScreen> createState() => _BabyListScreenState();
}

class _BabyListScreenState extends State<BabyListScreen> {
  final service = BabyService();

  List<BabyProfile> babies = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchBabies();
  }

  Future<void> fetchBabies() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await service.fetchBabyProfiles();
      if (!mounted) return;
      setState(() => babies = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString());
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  String _dobLabel(Object? d) {
    if (d == null) return '-';
    if (d is DateTime) {
      String two(int n) => n.toString().padLeft(2, '0');
      return '${d.year}-${two(d.month)}-${two(d.day)}';
    }
    final s = d.toString().trim();
    return s.isEmpty ? '-' : s;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  Future<void> _openActions(BabyProfile baby) async {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: NeoCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: cs.primary.o(0.18),
                        child: Text(
                          _initials(baby.name),
                          style: t.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          baby.name,
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _SheetButton(
                    icon: Icons.open_in_new,
                    label: AppStrings.t(context, 'open_dashboard'),
                    onTap: () => Navigator.pop(context, 'open'),
                  ),
                  const SizedBox(height: 10),
                  _SheetButton(
                    icon: Icons.edit_outlined,
                    label: AppStrings.t(context, 'edit'),
                    onTap: () => Navigator.pop(context, 'edit'),
                  ),
                  const SizedBox(height: 10),
                  _SheetButton(
                    icon: Icons.delete_outline,
                    label: AppStrings.t(context, 'delete'),
                    isDanger: true,
                    onTap: () => Navigator.pop(context, 'delete'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (action == null) return;

    if (action == 'open') {
      if (!mounted) return;
      Navigator.pushNamed(context, RouteNames.dashboard, arguments: baby);
      return;
    }

    if (action == 'edit') {
      
      
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BabyFormScreen(baby: baby)),
      );
      await fetchBabies();
      return;
    }

    if (action == 'delete') {
      await _confirmDelete(baby);
    }
  }

  Future<void> _confirmDelete(BabyProfile baby) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.t(context, 'delete_baby_title')),
        content: Text(AppStrings.t(context, 'delete_baby_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.t(context, 'cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.t(context, 'delete')),
          ),
        ],
      ),
    );

    if (ok == true) {
      await deleteBaby(baby);
    }
  }

  Future<void> deleteBaby(BabyProfile baby) async {
    try {
      final id = baby.id;
      await service.deleteBaby(id);
      await fetchBabies();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.t(context, 'delete_failed', vars: {'error': '$e'}),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    Widget content;

    if (loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      content = Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: NeoCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: cs.primary),
                const SizedBox(height: 10),
                Text(
                  AppStrings.t(context, 'error_generic'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  error!,
                  style: t.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: fetchBabies,
                  child: Text(AppStrings.t(context, 'try_again')),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (babies.isEmpty) {
      content = Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: NeoCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.child_care, color: cs.primary),
                const SizedBox(height: 10),
                Text(
                  AppStrings.t(context, 'add_baby_profile'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.t(context, 'add_baby_profile_sub'),
                  style: t.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BabyFormScreen()),
                  ).then((_) => fetchBabies()),
                  icon: const Icon(Icons.add),
                  label: Text(AppStrings.t(context, 'add_baby')),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      content = RefreshIndicator(
        onRefresh: fetchBabies,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          itemCount: babies.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final baby = babies[i];
            final subtitle =
                '${AppStrings.t(context, 'birth_date_short')} • ${_dobLabel(baby.birthDate)}';

            return NeoCard(
              onTap: () => Navigator.pushNamed(
                context,
                RouteNames.dashboard,
                arguments: baby,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: cs.primary.o(0.18),
                    child: Text(
                      _initials(baby.name),
                      style: t.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          baby.name,
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: t.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.o(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: AppStrings.t(context, 'more'),
                    onPressed: () => _openActions(baby),
                    icon: const Icon(Icons.more_horiz),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'my_babies'), style: t.titleLarge),
          actions: [
            IconButton(
              tooltip: AppStrings.t(context, 'refresh'),
              onPressed: fetchBabies,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: content,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BabyFormScreen()),
          ).then((_) => fetchBabies()),
          icon: const Icon(Icons.add),
          label: Text(AppStrings.t(context, 'add_baby')),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  const _SheetButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final color = isDanger ? Colors.red : cs.onSurface;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: color),
          ),
        ),
      ),
    );
  }
}
