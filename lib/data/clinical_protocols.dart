class ClinicalProtocol {
  final String id;
  final String title;
  final String summary;
  final String emoji;
  final List<String> homeSteps;
  final List<String> riskThresholds;
  final List<String> doctorThresholds;
  final List<String> sources;

  const ClinicalProtocol({
    required this.id,
    required this.title,
    required this.summary,
    required this.emoji,
    required this.homeSteps,
    required this.riskThresholds,
    required this.doctorThresholds,
    required this.sources,
  });
}

List<ClinicalProtocol> clinicalProtocolsFor(String code) {
  return code == 'tr' ? _tr : _en;
}

const List<ClinicalProtocol> _en = [
  ClinicalProtocol(
    id: 'fever',
    title: 'Fever',
    summary: 'Track temperature, behavior, and hydration.',
    emoji: '🌡️',
    homeSteps: [
      'Check temperature with a reliable method.',
      'Keep clothing light and the room comfortable.',
      'Offer fluids more often.',
      'Observe activity, feeding, and wet diapers.',
    ],
    riskThresholds: [
      'Fever keeps rising or does not improve.',
      'Less intake or fewer wet diapers.',
      'Marked lethargy or unusual fussiness.',
    ],
    doctorThresholds: [
      'Very young infant with fever.',
      'Breathing difficulty, stiff neck, or seizure.',
      'Not responsive or hard to wake.',
    ],
    sources: [
      'Summary of pediatric warning signs used in clinical triage.',
      'Cross-checked with general child health guidance.',
    ],
  ),
  ClinicalProtocol(
    id: 'dehydration',
    title: 'Dehydration',
    summary: 'Focus on fluids and signs of hydration.',
    emoji: '💧',
    homeSteps: [
      'Offer small, frequent sips.',
      'Continue breast milk or formula.',
      'Monitor wet diapers and energy.',
    ],
    riskThresholds: [
      'Dry mouth, no tears, or fewer wet diapers.',
      'Very sleepy or hard to soothe.',
      'Repeated vomiting or diarrhea.',
    ],
    doctorThresholds: [
      'No urine for a long period.',
      'Unable to keep fluids down.',
      'Signs of severe lethargy.',
    ],
    sources: [
      'Summary of dehydration warning signs for infants and toddlers.',
    ],
  ),
  ClinicalProtocol(
    id: 'breathing',
    title: 'Breathing Difficulty',
    summary: 'Observe breathing effort and feeding.',
    emoji: '🫁',
    homeSteps: [
      'Keep the baby upright and calm.',
      'Clear the nose gently if congested.',
      'Watch feeding and breathing together.',
    ],
    riskThresholds: [
      'Fast breathing or chest pulling in.',
      'Noisy breathing that is worsening.',
      'Feeding becomes difficult.',
    ],
    doctorThresholds: [
      'Blue lips or pauses in breathing.',
      'Severe distress or exhaustion.',
      'Breathing issues in very young infants.',
    ],
    sources: [
      'Summary of pediatric respiratory red flags.',
    ],
  ),
  ClinicalProtocol(
    id: 'new_food_rash',
    title: 'New Food + Rash',
    summary: 'Stop the new food and observe.',
    emoji: '🥄',
    homeSteps: [
      'Pause the new food and note the time.',
      'Watch for spreading rash or swelling.',
      'Take a photo to track changes.',
    ],
    riskThresholds: [
      'Rash spreads quickly or becomes widespread.',
      'Swelling around eyes or lips.',
      'Vomiting or diarrhea after the food.',
    ],
    doctorThresholds: [
      'Breathing difficulty or facial swelling.',
      'Repeated vomiting or collapse.',
      'Any severe reaction after a new food.',
    ],
    sources: [
      'Summary of allergic reaction warning signs.',
    ],
  ),
  ClinicalProtocol(
    id: 'vomit_diarrhea',
    title: 'Vomiting / Diarrhea',
    summary: 'Hydration and monitoring are key.',
    emoji: '🤢',
    homeSteps: [
      'Offer small, frequent fluids.',
      'Let the stomach rest between feeds.',
      'Monitor wet diapers and energy.',
    ],
    riskThresholds: [
      'Blood in stool or vomit.',
      'Signs of dehydration.',
      'Symptoms persist or worsen.',
    ],
    doctorThresholds: [
      'Severe belly pain or extreme lethargy.',
      'Unable to keep fluids down.',
      'Very young infant with symptoms.',
    ],
    sources: [
      'Summary of gastrointestinal warning signs in children.',
    ],
  ),
  ClinicalProtocol(
    id: 'rash',
    title: 'Widespread Rash',
    summary: 'Check fever, behavior, and spread.',
    emoji: '🧴',
    homeSteps: [
      'Note fever or recent illness.',
      'Keep skin cool and avoid scratching.',
      'Track spread and color changes.',
    ],
    riskThresholds: [
      'Rash spreads fast or is purple/dusky.',
      'Fever with low energy.',
      'Rash with swelling.',
    ],
    doctorThresholds: [
      'Rash with breathing trouble.',
      'Rash plus high fever or stiff neck.',
      'Any rapid decline in condition.',
    ],
    sources: [
      'Summary of rash red flags used in pediatric assessment.',
    ],
  ),
];

const List<ClinicalProtocol> _tr = [
  ClinicalProtocol(
    id: 'fever',
    title: 'Ateş',
    summary: 'Ateş, davranış ve sıvı alımını izle.',
    emoji: '🌡️',
    homeSteps: [
      'Ateşi güvenilir bir yöntemle ölç.',
      'İnce giydir ve ortamı serin tut.',
      'Sıvı alımını sıklaştır.',
      'Aktivite, beslenme ve idrarı gözle.',
    ],
    riskThresholds: [
      'Ateş yükselmeye devam eder veya düşmez.',
      'Beslenme azalır ya da daha az idrar.',
      'Belirgin halsizlik veya aşırı huzursuzluk.',
    ],
    doctorThresholds: [
      'Çok küçük bebekte ateş.',
      'Nefes darlığı, ense sertliği veya nöbet.',
      'Yanıt vermeme veya zor uyanma.',
    ],
    sources: [
      'Pediatrik triyajda kullanılan uyarı işaretleri özeti.',
      'Genel çocuk sağlığı rehberleriyle uyumlu içerik.',
    ],
  ),
  ClinicalProtocol(
    id: 'dehydration',
    title: 'Sıvı Kaybı',
    summary: 'Sıvı alımı ve hidrasyon bulgularına odaklan.',
    emoji: '💧',
    homeSteps: [
      'Az az ve sık sıvı ver.',
      'Anne sütü veya mamaya devam et.',
      'İdrar sayısı ve enerjiyi izle.',
    ],
    riskThresholds: [
      'Ağız kuruluğu, gözyaşı yokluğu.',
      'İdrar azalması.',
      'Tekrarlayan kusma ya da ishal.',
    ],
    doctorThresholds: [
      'Uzun süre idrar olmaması.',
      'Sıvı tutamama.',
      'Belirgin halsizlik.',
    ],
    sources: [
      'Bebek ve küçük çocuklarda sıvı kaybı uyarı işaretleri özeti.',
    ],
  ),
  ClinicalProtocol(
    id: 'breathing',
    title: 'Solunum Zorluğu',
    summary: 'Solunum eforu ve beslenmeyi birlikte izle.',
    emoji: '🫁',
    homeSteps: [
      'Bebeği dik tutup sakinleştir.',
      'Burun tıkanıklığını nazikçe temizle.',
      'Solunum ve beslenmeyi birlikte gözle.',
    ],
    riskThresholds: [
      'Hızlı nefes veya göğüs çekilmeleri.',
      'Kötüleşen hırıltı ya da gürültülü solunum.',
      'Beslenmede zorlanma.',
    ],
    doctorThresholds: [
      'Morarma veya nefes durmaları.',
      'Şiddetli zorlanma.',
      'Çok küçük bebekte solunum sorunu.',
    ],
    sources: [
      'Pediatrik solunum uyarı işaretleri özeti.',
    ],
  ),
  ClinicalProtocol(
    id: 'new_food_rash',
    title: 'Yeni Gıda + Döküntü',
    summary: 'Yeni gıdayı durdur ve gözlemle.',
    emoji: '🥄',
    homeSteps: [
      'Yeni gıdayı kes ve zamanını not et.',
      'Döküntü yayılımını ve şişliği izle.',
      'Değişimi takip etmek için fotoğraf çek.',
    ],
    riskThresholds: [
      'Döküntü hızla yayılır.',
      'Göz/ dudak çevresinde şişlik.',
      'Kusma veya ishal eşlik eder.',
    ],
    doctorThresholds: [
      'Nefes darlığı veya yüz şişliği.',
      'Tekrarlayan kusma veya bayılma.',
      'Şiddetli reaksiyon.',
    ],
    sources: [
      'Alerjik reaksiyon uyarı işaretleri özeti.',
    ],
  ),
  ClinicalProtocol(
    id: 'vomit_diarrhea',
    title: 'Kusma / İshal',
    summary: 'Hidrasyon ve takip öncelikli.',
    emoji: '🤢',
    homeSteps: [
      'Az az ve sık sıvı ver.',
      'Beslenme arasında dinlenme ver.',
      'İdrar ve enerjiyi izle.',
    ],
    riskThresholds: [
      'Dışkıda veya kusmukta kan.',
      'Sıvı kaybı bulguları.',
      'Şikayetlerin sürmesi ya da artması.',
    ],
    doctorThresholds: [
      'Şiddetli karın ağrısı veya çok halsiz.',
      'Sıvı tutamama.',
      'Çok küçük bebekte belirtiler.',
    ],
    sources: [
      'Çocuklarda sindirim sistemi uyarı işaretleri özeti.',
    ],
  ),
  ClinicalProtocol(
    id: 'rash',
    title: 'Yaygın Döküntü',
    summary: 'Ateş, davranış ve yayılımı izle.',
    emoji: '🧴',
    homeSteps: [
      'Ateş veya yakın dönemde hastalık var mı not et.',
      'Cildi serin tut ve kaşıntıyı azalt.',
      'Yayılım ve renk değişimini takip et.',
    ],
    riskThresholds: [
      'Döküntü hızla yayılır veya morumsu.',
      'Ateş + halsizlik.',
      'Döküntüyle şişlik.',
    ],
    doctorThresholds: [
      'Döküntü + nefes darlığı.',
      'Döküntü + yüksek ateş veya ense sertliği.',
      'Hızlı kötüleşme.',
    ],
    sources: [
      'Pediatrik döküntü uyarı işaretleri özeti.',
    ],
  ),
];
