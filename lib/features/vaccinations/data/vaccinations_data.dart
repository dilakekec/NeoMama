import 'package:neomama/l10n/app_strings.dart';
import '../models/vaccination_models.dart';

class _VaccinationSeed {
  final String id;
  final int dueMonth;
  final String title;
  final String descKey;

  const _VaccinationSeed({
    required this.id,
    required this.dueMonth,
    required this.title,
    required this.descKey,
  });
}

List<VaccinationItem> vaccinationsDataFor(String code) {
  final lang = _lang(code);
  return _seeds
      .map((s) => VaccinationItem(
            id: s.id,
            dueMonth: s.dueMonth,
            monthLabel: s.dueMonth == 0
                ? AppStrings.byCode(lang, 'vacc_month_birth')
                : AppStrings.byCode(
                    lang,
                    'vacc_months',
                    vars: {'months': '${s.dueMonth}'},
                  ),
            title: s.title,
            description: AppStrings.byCode(lang, s.descKey),
          ))
      .toList();
}

String _lang(String code) => (code == 'tr' || code == 'en') ? code : 'en';

const List<_VaccinationSeed> _seeds = [
  _VaccinationSeed(
    id: 'hep_b_birth',
    dueMonth: 0,
    title: 'Hep B',
    descKey: 'vacc_desc_hep_b_birth',
  ),
  _VaccinationSeed(
    id: 'dtap_2',
    dueMonth: 2,
    title: 'DTaP',
    descKey: 'vacc_desc_dtap_2',
  ),
  _VaccinationSeed(
    id: 'ipv_2',
    dueMonth: 2,
    title: 'IPV',
    descKey: 'vacc_desc_ipv_2',
  ),
  _VaccinationSeed(
    id: 'hib_2',
    dueMonth: 2,
    title: 'Hib',
    descKey: 'vacc_desc_hib_2',
  ),
  _VaccinationSeed(
    id: 'pcv_2',
    dueMonth: 2,
    title: 'PCV',
    descKey: 'vacc_desc_pcv_2',
  ),
  _VaccinationSeed(
    id: 'rota_2',
    dueMonth: 2,
    title: 'Rotavirus',
    descKey: 'vacc_desc_rota_2',
  ),
  _VaccinationSeed(
    id: 'dtap_6',
    dueMonth: 6,
    title: 'DTaP',
    descKey: 'vacc_desc_dtap_6',
  ),
  _VaccinationSeed(
    id: 'ipv_6',
    dueMonth: 6,
    title: 'IPV',
    descKey: 'vacc_desc_ipv_6',
  ),
  _VaccinationSeed(
    id: 'hep_b_6',
    dueMonth: 6,
    title: 'Hep B',
    descKey: 'vacc_desc_hep_b_6',
  ),
  _VaccinationSeed(
    id: 'pcv_6',
    dueMonth: 6,
    title: 'PCV',
    descKey: 'vacc_desc_pcv_6',
  ),
  _VaccinationSeed(
    id: 'mmr_12',
    dueMonth: 12,
    title: 'MMR',
    descKey: 'vacc_desc_mmr_12',
  ),
  _VaccinationSeed(
    id: 'varicella_12',
    dueMonth: 12,
    title: 'Varicella',
    descKey: 'vacc_desc_varicella_12',
  ),
  _VaccinationSeed(
    id: 'hep_a_12',
    dueMonth: 12,
    title: 'Hep A',
    descKey: 'vacc_desc_hep_a_12',
  ),
];
