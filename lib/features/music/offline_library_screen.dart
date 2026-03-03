import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/data/clinical_protocols.dart';
import 'package:neomama/l10n/app_strings.dart';

class OfflineLibraryScreen extends StatelessWidget {
  const OfflineLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final code = Localizations.localeOf(context).languageCode;

    final protocols = clinicalProtocolsFor(code);

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'clinical_library_title'), style: t.titleLarge),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            NeoCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: cs.primary.o(0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: cs.primary.o(0.18),
                        width: 1,
                      ),
                    ),
                    child: Icon(Icons.offline_bolt_rounded, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.t(context, 'clinical_library_title'),
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.t(context, 'clinical_library_desc'),
                          style: t.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _Badge(
                          label: AppStrings.t(
                            context,
                            'protocols_count',
                            vars: {'count': '${protocols.length}'},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            ...protocols.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ProtocolCard(
                  protocol: p,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClinicalProtocolScreen(protocol: p),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              AppStrings.t(context, 'protocol_disclaimer'),
              style: t.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProtocolCard extends StatelessWidget {
  final ClinicalProtocol protocol;
  final VoidCallback? onTap;

  const _ProtocolCard({
    required this.protocol,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: NeoCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(protocol.emoji, style: t.headlineSmall),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            protocol.title,
                            style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded,
                            color: cs.onSurfaceVariant),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      protocol.summary,
                      style: t.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.fact_check_rounded, color: cs.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          AppStrings.t(context, 'protocol_open'),
                          style: t.bodySmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.o(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.o(0.18), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cs.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class ClinicalProtocolScreen extends StatelessWidget {
  final ClinicalProtocol protocol;

  const ClinicalProtocolScreen({super.key, required this.protocol});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(protocol.title, style: t.titleLarge),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            NeoCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(protocol.emoji, style: t.headlineMedium),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          protocol.title,
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          protocol.summary,
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

            _SectionCard(
              title: AppStrings.t(context, 'protocol_home_steps'),
              items: protocol.homeSteps,
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: AppStrings.t(context, 'protocol_risk_threshold'),
              items: protocol.riskThresholds,
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: AppStrings.t(context, 'protocol_doctor_threshold'),
              items: protocol.doctorThresholds,
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: AppStrings.t(context, 'protocol_source_summary'),
              items: protocol.sources,
            ),
            const SizedBox(height: 14),
            Text(
              AppStrings.t(context, 'protocol_disclaimer'),
              style: t.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _SectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (it) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      it,
                      style: t.bodyMedium?.copyWith(height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
