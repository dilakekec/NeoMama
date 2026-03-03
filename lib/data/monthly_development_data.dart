class DevelopmentTip {
  final int month;
  final String area;
  final String title;
  final String description;
  final String? leapNote;

  const DevelopmentTip({
    required this.month,
    required this.area,
    required this.title,
    required this.description,
    this.leapNote,
  });
}

class MonthlyDevelopment {
  final String title;
  final String physical;
  final String sleep;
  final String feeding;
  final String note;

  const MonthlyDevelopment({
    required this.title,
    required this.physical,
    required this.sleep,
    required this.feeding,
    required this.note,
  });
}

Map<int, MonthlyDevelopment> monthlyDevelopmentDataFor(String code) {
  final lang = _lang(code);
  return _monthlyDevelopmentData[lang] ?? _monthlyDevelopmentData['en']!;
}

List<DevelopmentTip> developmentTipsFor(String code) {
  final lang = _lang(code);
  return _developmentTips[lang] ?? _developmentTips['en']!;
}

String _lang(String code) => _monthlyDevelopmentData.containsKey(code) ? code : 'en';

final Map<String, Map<int, MonthlyDevelopment>> _monthlyDevelopmentData = {
  'en': {
    0: const MonthlyDevelopment(
      title: 'Newborn (0–1 month)',
      physical:
          'Newborns are born with reflexes such as grasping and rooting. They can lift their head briefly when lying on their stomach.',
      sleep:
          'Newborns sleep 14–17 hours a day, waking every 2–3 hours to feed.',
      feeding:
          'Breastfeeding or formula feeding is recommended. Newborns typically feed every 2–3 hours.',
      note:
          'Skin-to-skin contact is important for bonding and breastfeeding success.',
    ),
    1: const MonthlyDevelopment(
      title: '1 Month',
      physical:
          'Babies can lift their head to a 45-degree angle when lying on their stomach. They may start to follow moving objects with their eyes.',
      sleep: 'Sleep 14–17 hours a day, with slightly longer night stretches.',
      feeding: 'Continue breastfeeding or formula feeding every 2–3 hours.',
      note: 'Talk and sing to your baby to promote language development.',
    ),
    2: const MonthlyDevelopment(
      title: '2 Months',
      physical:
          'Can hold head up at a 90-degree angle and push down on legs when feet touch a surface.',
      sleep: 'About 14–17 hours, more consolidated at night.',
      feeding: 'Continue breastfeeding or formula feeding every 2–3 hours.',
      note: 'Introduce tummy time to strengthen neck and shoulder muscles.',
    ),
    3: const MonthlyDevelopment(
      title: '3 Months',
      physical:
          'Head control improves, may reach for toys, push up on elbows during tummy time.',
      sleep: '14–17 hours a day, night stretches getting longer.',
      feeding: 'Continue breastfeeding or formula feeding every 3–4 hours.',
      note: 'Encourage reaching and grasping by placing toys within reach.',
    ),
    4: const MonthlyDevelopment(
      title: '4 Months',
      physical:
          'Can roll tummy-to-back, start to sit with support, grasp toys and shake them.',
      sleep: 'About 14–16 hours a day.',
      feeding:
          'Continue breastfeeding or formula feeding. Some may be ready for solids (4–6 months).',
      note: 'Introduce solid foods when developmentally ready.',
    ),
    6: const MonthlyDevelopment(
      title: '6 Months',
      physical:
          'Sits without support, may crawl, transfers toys between hands.',
      sleep: '13–15 hours a day, with naps.',
      feeding:
          'Continue breastfeeding/formula. Introduce solid foods gradually.',
      note: 'Encourage crawling by placing toys just out of reach.',
    ),
    9: const MonthlyDevelopment(
      title: '9 Months',
      physical:
          'May crawl well, pull up to stand, use pincer grasp to pick objects.',
      sleep: '13–15 hours including naps.',
      feeding: 'Breast milk/formula + 2–3 solid meals a day.',
      note: 'Offer finger foods to develop self-feeding skills.',
    ),
    12: const MonthlyDevelopment(
      title: '12 Months',
      physical:
          'Stands alone, may take first steps, uses pincer grasp with small items.',
      sleep: '12–14 hours including naps.',
      feeding: 'Breast milk/formula + 3 solid meals a day.',
      note: 'Encourage walking by providing safe spaces and support.',
    ),
    18: const MonthlyDevelopment(
      title: '18 Months',
      physical:
          'Walks independently, may run, climbs onto furniture, stacks blocks.',
      sleep: '11–14 hours including naps.',
      feeding: 'Eats a variety of solid foods; whole milk may replace formula.',
      note: 'Encourage active play and vocabulary growth.',
    ),
    24: const MonthlyDevelopment(
      title: '24 Months',
      physical:
          'Runs, climbs, kicks a ball, begins to scribble, uses 2-word phrases.',
      sleep: '11–14 hours including naps.',
      feeding: 'Eats family foods; encourage self-feeding with utensils.',
      note: 'Support independence and language development.',
    ),
  },
  'tr': {
    0: const MonthlyDevelopment(
      title: 'Yenidoğan (0–1 ay)',
      physical:
          'Yenidoğanlar kavrama ve emme gibi reflekslerle doğar. Karın üstü yatarken kısa süreliğine başını kaldırabilir.',
      sleep:
          'Yenidoğanlar günde 14–17 saat uyur, beslenmek için her 2–3 saatte bir uyanır.',
      feeding:
          'Anne sütü veya mama önerilir. Yenidoğanlar genelde 2–3 saatte bir beslenir.',
      note:
          'Cilt tene temas, bağlanma ve emzirme başarısı için önemlidir.',
    ),
    1: const MonthlyDevelopment(
      title: '1 Ay',
      physical:
          'Karın üstü yatarken başını yaklaşık 45 derece kaldırabilir. Gözleriyle hareket eden nesneleri takip etmeye başlayabilir.',
      sleep: 'Günde 14–17 saat uyur, gece uykuları biraz uzar.',
      feeding: '2–3 saatte bir anne sütü veya mama ile devam.',
      note: 'Konuşmak ve şarkı söylemek dil gelişimini destekler.',
    ),
    2: const MonthlyDevelopment(
      title: '2 Ay',
      physical:
          'Başını 90 dereceye kadar kaldırabilir ve ayakları zemine değince bacaklarıyla itebilir.',
      sleep: 'Yaklaşık 14–17 saat, gece daha düzenli.',
      feeding: '2–3 saatte bir anne sütü veya mama.',
      note: 'Boyun ve omuzları güçlendirmek için karın zamanı.',
    ),
    3: const MonthlyDevelopment(
      title: '3 Ay',
      physical:
          'Baş kontrolü artar, oyuncaklara uzanabilir, karın üstünde dirseklerine yaslanabilir.',
      sleep: 'Günde 14–17 saat, gece uykuları uzar.',
      feeding: '3–4 saatte bir anne sütü veya mama.',
      note: 'Oyuncakları ulaşabileceği yere koyarak uzanmayı teşvik et.',
    ),
    4: const MonthlyDevelopment(
      title: '4 Ay',
      physical:
          'Karından sırt üstüne dönebilir, destekle oturmaya başlar, oyuncakları kavrayıp sallayabilir.',
      sleep: 'Günde 14–16 saat.',
      feeding:
          'Anne sütü/mama devam. Bazı bebekler ek gıdaya hazır olabilir (4–6 ay).',
      note: 'Gelişimsel olarak hazır olduğunda ek gıdaya geçiş.',
    ),
    6: const MonthlyDevelopment(
      title: '6 Ay',
      physical:
          'Desteksiz oturur, emekleyebilir, oyuncakları el değiştirir.',
      sleep: 'Şekerlemelerle günde 13–15 saat.',
      feeding:
          'Anne sütü/mama devam. Ek gıdaları kademeli artır.',
      note: 'Oyuncakları biraz uzağa koyup emeklemeyi teşvik et.',
    ),
    9: const MonthlyDevelopment(
      title: '9 Ay',
      physical:
          'İyi emekler, tutunup ayağa kalkabilir, kıskaç kavrama gelişir.',
      sleep: 'Şekerlemelerle 13–15 saat.',
      feeding: 'Anne sütü/mama + günde 2–3 öğün ek gıda.',
      note: 'Parmak gıdalarla kendi kendine beslenmeyi destekle.',
    ),
    12: const MonthlyDevelopment(
      title: '12 Ay',
      physical:
          'Tek başına durabilir, ilk adımlarını atabilir, küçük nesneleri kavrar.',
      sleep: 'Şekerlemelerle 12–14 saat.',
      feeding: 'Anne sütü/mama + günde 3 öğün.',
      note: 'Güvenli alanlar oluşturarak yürümeyi destekle.',
    ),
    18: const MonthlyDevelopment(
      title: '18 Ay',
      physical:
          'Bağımsız yürür, koşabilir, mobilyalara tırmanır, blokları dizer.',
      sleep: 'Şekerlemelerle 11–14 saat.',
      feeding:
          'Çeşitli katı gıdalar yer; tam yağlı süt mamaya alternatif olabilir.',
      note: 'Aktif oyun ve kelime dağarcığını destekle.',
    ),
    24: const MonthlyDevelopment(
      title: '24 Ay',
      physical:
          'Koşar, tırmanır, topa vurur, karalamaya başlar, 2 kelimelik ifadeler kullanır.',
      sleep: 'Şekerlemelerle 11–14 saat.',
      feeding:
          'Aile yemeklerini yer; çatal/kaşıkla kendi kendine beslenmeyi destekle.',
      note: 'Bağımsızlığı ve dil gelişimini destekle.',
    ),
  },
};

final Map<String, List<DevelopmentTip>> _developmentTips = {
  'en': const [
    DevelopmentTip(
      month: 4,
      area: 'Cognitive',
      title: 'First big leap',
      description:
          'Baby starts noticing patterns in the environment and can be more sensitive to new stimuli.',
      leapNote:
          'Fussiness, frequent waking, and extra clinginess can increase. This is temporary.',
    ),
    DevelopmentTip(
      month: 8,
      area: 'Motor',
      title: 'Movement burst',
      description:
          'Crawling, pulling up, and exploring increase; safety becomes critical.',
      leapNote:
          'Check cords, sharp corners, and unstable items at home.',
    ),
    DevelopmentTip(
      month: 12,
      area: 'Language',
      title: 'First words sprint',
      description:
          'Baby imitates sounds more and communicates with gestures and expressions.',
      leapNote:
          'Lots of repetition, books, and songs support language growth.',
    ),
  ],
  'tr': const [
    DevelopmentTip(
      month: 4,
      area: 'Bilişsel',
      title: 'İlk büyük sıçrama',
      description:
          'Bebek çevredeki kalıpları daha iyi fark etmeye başlar, yeni uyaranlara daha hassas olabilir.',
      leapNote:
          'Huysuzluk, sık uyanma ve anneye yapışıklık artabilir. Geçici bir dönem.',
    ),
    DevelopmentTip(
      month: 8,
      area: 'Motor',
      title: 'Hareket patlaması',
      description:
          'Emekleme, ayağa kalkma ve etrafı keşfetme isteği artar; güvenlik kritik olur.',
      leapNote:
          'Evde kabloları, keskin köşeleri ve devrilebilecek eşyaları kontrol et.',
    ),
    DevelopmentTip(
      month: 12,
      area: 'Dil',
      title: 'İlk kelimeler koşusu',
      description:
          'Bebek daha çok ses taklit eder, jest ve mimiklerle iletişimi güçlenir.',
      leapNote:
          'Bol tekrar, bol kitap, bol şarkı: dil gelişimi için altın üçlü.',
    ),
  ],
};
