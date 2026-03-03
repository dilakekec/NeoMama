import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final contacts = <({
      String label,
      String name,
      String phone,
      IconData icon,
      bool isEmergency,
    })>[
      (
        label: AppStrings.t(context, 'contact_pediatrician'),
        name: AppStrings.t(context, 'contact_doctor_name'),
        phone: '0 555 000 00 00',
        icon: Icons.medical_services_outlined,
        isEmergency: false,
      ),
      (
        label: AppStrings.t(context, 'contact_emergency'),
        name: AppStrings.t(context, 'contact_emergency_sub'),
        phone: '112',
        icon: Icons.emergency_outlined,
        isEmergency: true,
      ),
    ];

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'contacts'), style: t.titleLarge),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: contacts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final c = contacts[index];

            return NeoCard(
              onTap: () {
                
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (c.isEmergency ? cs.error : cs.primary).o(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: (c.isEmergency ? cs.error : cs.primary).o(0.18),
                      ),
                    ),
                    child: Icon(
                      c.icon,
                      color: c.isEmergency ? cs.error : cs.primary,
                    ),
                  ),
                  const SizedBox(width: 14),

                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.label.toUpperCase(),
                          style: t.labelMedium?.copyWith(
                            color: c.isEmergency ? cs.error : cs.primary,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.name,
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.phone,
                          style: t.bodyMedium?.copyWith(
                            color: cs.onSurface.o(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  
                  IconButton(
                    tooltip: AppStrings.t(context, 'call'),
                    onPressed: () {
                      
                    },
                    icon: Icon(
                      Icons.call,
                      color: c.isEmergency ? cs.error : cs.primary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
