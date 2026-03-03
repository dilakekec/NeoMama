import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/core/config/route_names.dart';
import 'package:neomama/l10n/app_strings.dart';
import '../../models/baby_profile.dart';
import '../../services/baby_service.dart';

class BabyFormScreen extends StatefulWidget {
  final BabyProfile? baby;

  const BabyFormScreen({super.key, this.baby});

  @override
  State<BabyFormScreen> createState() => _BabyFormScreenState();
}

class _BabyFormScreenState extends State<BabyFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _feedingCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  bool get isEdit => widget.baby != null;

  @override
  void initState() {
    super.initState();
    final b = widget.baby;
    if (b != null) {
      _nameCtrl.text = b.name;
      _birthDateCtrl.text = b.birthDate;
      _feedingCtrl.text = b.feedingPreferences ?? '';
      _allergiesCtrl.text = b.allergies ?? '';
      _notesCtrl.text = b.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthDateCtrl.dispose();
    _feedingCtrl.dispose();
    _allergiesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String? _nullIfBlank(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = BabyService();

      final name = _nameCtrl.text.trim();
      final birthDate = _birthDateCtrl.text.trim();

      final feeding = _nullIfBlank(_feedingCtrl.text);
      final allergies = _nullIfBlank(_allergiesCtrl.text);
      final notes = _nullIfBlank(_notesCtrl.text);

      late final BabyProfile saved;

      if (isEdit) {
        final id = widget.baby!.id;
        saved = await service.updateBaby(
          id,
          name: name,
          birthDate: birthDate,
          feeding: feeding,
          allergies: allergies,
          notes: notes,
        );
      } else {
        saved = await service.createBaby(
          name: name,
          birthDate: birthDate,
          feeding: feeding,
          allergies: allergies,
          notes: notes,
        );
      }

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.dashboard,
        (_) => false,
        arguments: saved,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEdit ? AppStrings.t(context, 'edit_baby') : AppStrings.t(context, 'add_baby'),
            style: t.titleLarge,
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                NeoCard(
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              cs.primary.o(0.22),
                              cs.secondary.o(0.30),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(Icons.child_care, color: cs.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit
                                  ? AppStrings.t(context, 'edit_profile_title')
                                  : AppStrings.t(context, 'create_profile'),
                              style: t.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.t(context, 'keep_details'),
                              style: t.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                NeoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t(context, 'basics'), style: t.titleMedium),
                      const SizedBox(height: 12),
                      _field(
                        _nameCtrl,
                        AppStrings.t(context, 'baby_name'),
                        Icons.child_care,
                        required: true,
                      ),
                      _birthDateField(),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                NeoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t(context, 'details'), style: t.titleMedium),
                      const SizedBox(height: 12),
                      _field(
                        _feedingCtrl,
                        AppStrings.t(context, 'feeding_prefs'),
                        Icons.restaurant,
                      ),
                      _field(
                        _allergiesCtrl,
                        AppStrings.t(context, 'allergies'),
                        Icons.warning_amber,
                      ),
                      _field(
                        _notesCtrl,
                        AppStrings.t(context, 'notes'),
                        Icons.notes,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  NeoCard(
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: cs.error),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: t.bodyMedium?.copyWith(color: cs.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEdit
                                ? AppStrings.t(context, 'save_changes')
                                : AppStrings.t(context, 'save_baby'),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _birthDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _birthDateCtrl,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          labelText: AppStrings.t(context, 'birth_date'),
          prefixIcon: const Icon(Icons.cake),
        ),
        validator: (v) {
          final s = (v ?? '').trim();
          if (s.isEmpty) return AppStrings.t(context, 'required');
          final ok = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s);
          return ok ? null : AppStrings.t(context, 'date_format_hint');
        },
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: required
            ? (v) => (v ?? '').trim().isEmpty ? AppStrings.t(context, 'required') : null
            : null,
      ),
    );
  }
}
