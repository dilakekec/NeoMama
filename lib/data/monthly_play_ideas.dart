class PlayIdea {
  final int month;
  final String title;
  final String category;
  final String description;

  const PlayIdea({
    required this.month,
    required this.title,
    required this.category,
    required this.description,
  });
}

List<PlayIdea> monthlyPlayIdeasFor(String code) {
  final lang = _lang(code);
  return _monthlyPlayIdeas[lang] ?? _monthlyPlayIdeas['en']!;
}

String _lang(String code) => _monthlyPlayIdeas.containsKey(code) ? code : 'en';

final Map<String, List<PlayIdea>> _monthlyPlayIdeas = {
  'en': const [
    PlayIdea(
      month: 0,
      title: 'Tummy Time',
      category: 'Gross motor',
      description:
          'Lay your baby on their tummy and encourage them to lift their head and look around. This helps strengthen their neck and shoulder muscles.',
    ),
    PlayIdea(
      month: 1,
      title: 'Sensory Play',
      category: 'Sensory',
      description:
          'Fill a shallow container with water and let your baby splash around. You can add some floating toys for extra fun. Always supervise closely!',
    ),
    PlayIdea(
      month: 2,
      title: 'Mirror Play',
      category: 'Cognitive',
      description:
          'Hold a mirror in front of your baby and let them explore their reflection. Babies love looking at faces!',
    ),
    PlayIdea(
      month: 3,
      title: 'Colorful Toys',
      category: 'Visual',
      description:
          'Provide your baby with colorful toys to stimulate their vision. Bright colors can capture their attention.',
    ),
    PlayIdea(
      month: 4,
      title: 'Music Time',
      category: 'Auditory',
      description:
          'Play some soft music and dance with your baby in your arms. The movement and rhythm can be very soothing.',
    ),
    PlayIdea(
      month: 5,
      title: 'Story Time',
      category: 'Language',
      description:
          'Read a short story to your baby, using different voices for characters. The sound of your voice is comforting and helps with language development.',
    ),
    PlayIdea(
      month: 6,
      title: 'Texture Exploration',
      category: 'Sensory',
      description:
          'Provide different textured fabrics for your baby to touch and explore. Soft, rough, smooth - the variety will engage their sense of touch.',
    ),
    PlayIdea(
      month: 7,
      title: 'Bubble Fun',
      category: 'Visual',
      description:
          'Blow bubbles and let your baby watch them float and pop. Babies are fascinated by bubbles!',
    ),
    PlayIdea(
      month: 8,
      title: 'Nature Walk',
      category: 'Cognitive',
      description:
          'Take your baby for a walk outside and point out different things you see. The fresh air and new sights are stimulating.',
    ),
    PlayIdea(
      month: 9,
      title: 'Play with Shadows',
      category: 'Visual',
      description:
          'Use a flashlight to create shadows on the wall and let your baby watch them move. Babies are often intrigued by light and shadow.',
    ),
    PlayIdea(
      month: 10,
      title: 'Hand and Foot Play',
      category: 'Gross motor',
      description:
          'Gently move your baby\'s hands and feet to the rhythm of a song. This helps with body awareness and coordination.',
    ),
    PlayIdea(
      month: 11,
      title: 'Soft Toy Play',
      category: 'Sensory',
      description:
          'Let your baby explore soft toys with different textures and sounds. Stuffed animals with crinkly parts or rattles can be very engaging.',
    ),
    PlayIdea(
      month: 12,
      title: 'Baby Gym',
      category: 'Gross motor',
      description:
          'Set up a baby gym with hanging toys for your baby to reach for and grab. This encourages motor skills development.',
    ),
    PlayIdea(
      month: 13,
      title: 'Water Play',
      category: 'Sensory',
      description:
          'Fill a shallow basin with water and let your baby splash around with their hands and feet. Always supervise closely!',
    ),
    PlayIdea(
      month: 14,
      title: 'Finger Painting',
      category: 'Fine motor',
      description:
          'Use edible finger paints and let your baby explore colors with their hands. This is a messy but fun activity!',
    ),
    PlayIdea(
      month: 15,
      title: 'Play with Scarves',
      category: 'Sensory',
      description:
          'Use colorful scarves to play peek-a-boo or let your baby explore their texture. Babies love the movement and colors.',
    ),
    PlayIdea(
      month: 16,
      title: 'Rolling Ball',
      category: 'Fine motor',
      description:
          'Roll a soft ball towards your baby and encourage them to reach for it. This helps with hand-eye coordination.',
    ),
    PlayIdea(
      month: 17,
      title: 'Singing Songs',
      category: 'Language',
      description:
          'Sing simple songs and nursery rhymes to your baby, using hand motions. This helps with language development and bonding.',
    ),
    PlayIdea(
      month: 18,
      title: 'Play with Blocks',
      category: 'Cognitive',
      description:
          'Provide soft blocks for your baby to stack and knock down. This encourages motor skills and problem-solving.',
    ),
    PlayIdea(
      month: 19,
      title: 'Animal Sounds',
      category: 'Language',
      description:
          'Make animal sounds and encourage your baby to mimic them. Use stuffed animals or pictures to make it more engaging.',
    ),
    PlayIdea(
      month: 20,
      title: 'Play with Rattles',
      category: 'Auditory',
      description:
          'Shake rattles and let your baby explore the sound and movement. This helps with auditory development and motor skills.',
    ),
    PlayIdea(
      month: 21,
      title: 'Cuddle Time',
      category: 'Emotional',
      description:
          'Spend some quiet time cuddling with your baby, talking softly and making eye contact. This strengthens your bond and provides comfort.',
    ),
    PlayIdea(
      month: 22,
      title: 'Play with Puppets',
      category: 'Cognitive',
      description:
          'Use finger puppets to tell a simple story or sing a song. Babies love watching the movement and listening to different voices.',
    ),
    PlayIdea(
      month: 23,
      title: 'Dance Party',
      category: 'Gross motor',
      description:
          'Hold your baby and dance around the room to some upbeat music. The movement and rhythm are fun and stimulating.',
    ),
    PlayIdea(
      month: 24,
      title: 'Play with Light',
      category: 'Visual',
      description:
          'Use a flashlight or a lamp to create shadows and light patterns for your baby to explore. Babies are often fascinated by light and shadow.',
    ),
  ],
  'tr': const [
    PlayIdea(
      month: 0,
      title: 'Karın Zamanı',
      category: 'Kaba motor',
      description:
          'Bebeğinizi yüzüstü yatırın ve başını kaldırması için teşvik edin. Bu, boyun ve omuz kaslarını güçlendirir.',
    ),
    PlayIdea(
      month: 1,
      title: 'Duyusal Oyun',
      category: 'Duyusal',
      description:
          'Sığ bir kaba su koyup bebeğinizin suyla oynamasına izin verin. Yüzen oyuncaklar ekleyebilirsiniz. Yakından gözetin!',
    ),
    PlayIdea(
      month: 2,
      title: 'Ayna Oyunu',
      category: 'Bilişsel',
      description:
          'Bebeğinizin önünde bir ayna tutun ve yansımasını keşfetmesine izin verin. Bebekler yüzlere bakmayı sever.',
    ),
    PlayIdea(
      month: 3,
      title: 'Renkli Oyuncaklar',
      category: 'Görsel',
      description:
          'Parlak renkli oyuncaklar sunun. Canlı renkler dikkatini çeker ve görsel gelişimi destekler.',
    ),
    PlayIdea(
      month: 4,
      title: 'Müzik Zamanı',
      category: 'İşitsel',
      description:
          'Yumuşak müzik açıp bebeğinizle dans edin. Ritim ve hareket sakinleştiricidir.',
    ),
    PlayIdea(
      month: 5,
      title: 'Hikaye Zamanı',
      category: 'Dil',
      description:
          'Kısa bir hikaye okuyun ve karakterler için farklı sesler kullanın. Sesiniz rahatlatır ve dil gelişimini destekler.',
    ),
    PlayIdea(
      month: 6,
      title: 'Doku Keşfi',
      category: 'Duyusal',
      description:
          'Farklı dokularda kumaşlar verin. Yumuşak, pütürlü, kaygan çeşitlilik dokunma duyusunu geliştirir.',
    ),
    PlayIdea(
      month: 7,
      title: 'Baloncuk Eğlencesi',
      category: 'Görsel',
      description:
          'Baloncuk üfleyin ve bebeğinizin onları izlemesine izin verin. Bebekler baloncuklara bayılır.',
    ),
    PlayIdea(
      month: 8,
      title: 'Doğa Yürüyüşü',
      category: 'Bilişsel',
      description:
          'Dışarıda kısa bir yürüyüş yapın ve gördüklerinizi anlatın. Temiz hava ve yeni görüntüler uyarıcıdır.',
    ),
    PlayIdea(
      month: 9,
      title: 'Gölge Oyunu',
      category: 'Görsel',
      description:
          'Bir ışıkla duvarda gölgeler oluşturun ve hareketlerini izletin. Işık ve gölge bebeklerin ilgisini çeker.',
    ),
    PlayIdea(
      month: 10,
      title: 'El ve Ayak Oyunu',
      category: 'Kaba motor',
      description:
          'Şarkı ritmine göre bebeğinizin ellerini ve ayaklarını nazikçe hareket ettirin. Vücut farkındalığını artırır.',
    ),
    PlayIdea(
      month: 11,
      title: 'Yumuşak Oyuncaklarla Oyun',
      category: 'Duyusal',
      description:
          'Farklı dokulu ve sesli yumuşak oyuncaklar sunun. Hışırtılı veya çıngıraklı oyuncaklar ilgi çeker.',
    ),
    PlayIdea(
      month: 12,
      title: 'Bebek Oyun Halısı',
      category: 'Kaba motor',
      description:
          'Asılı oyuncaklı oyun halısı kurun; uzanma ve kavrama becerileri gelişir.',
    ),
    PlayIdea(
      month: 13,
      title: 'Su Oyunu',
      category: 'Duyusal',
      description:
          'Sığ bir kapta elleriyle ve ayaklarıyla suyla oynamasına izin verin. Yakından gözetin!',
    ),
    PlayIdea(
      month: 14,
      title: 'Parmak Boyama',
      category: 'İnce motor',
      description:
          'Yenilebilir parmak boyalarıyla renkleri keşfettirin. Dağınık ama çok eğlenceli.',
    ),
    PlayIdea(
      month: 15,
      title: 'Şal ile Oyun',
      category: 'Duyusal',
      description:
          'Renkli şallarla ce-ee oynayın veya dokusunu keşfetmesine izin verin.',
    ),
    PlayIdea(
      month: 16,
      title: 'Top Yuvarlama',
      category: 'İnce motor',
      description:
          'Yumuşak bir topu yuvarlayın ve uzanmasını teşvik edin. El-göz koordinasyonuna yardımcı olur.',
    ),
    PlayIdea(
      month: 17,
      title: 'Şarkı Söyleme',
      category: 'Dil',
      description:
          'Basit şarkılar ve ninniler söyleyin, el hareketleri kullanın. Dil gelişimi ve bağ kurma için etkilidir.',
    ),
    PlayIdea(
      month: 18,
      title: 'Bloklarla Oyun',
      category: 'Bilişsel',
      description:
          'Yumuşak bloklarla dizip yıkmasına izin verin. Motor ve problem çözme becerilerini destekler.',
    ),
    PlayIdea(
      month: 19,
      title: 'Hayvan Sesleri',
      category: 'Dil',
      description:
          'Hayvan sesleri çıkarın ve taklit etmesini teşvik edin. Görsellerle destekleyin.',
    ),
    PlayIdea(
      month: 20,
      title: 'Çıngırakla Oyun',
      category: 'İşitsel',
      description:
          'Çıngırağı sallayın; sesi ve hareketi keşfetmesine izin verin. İşitsel gelişimi destekler.',
    ),
    PlayIdea(
      month: 21,
      title: 'Sarılma Zamanı',
      category: 'Duygusal',
      description:
          'Sakin bir şekilde sarılın, yumuşak konuşun ve göz teması kurun. Bağı güçlendirir.',
    ),
    PlayIdea(
      month: 22,
      title: 'Kukla Oyunu',
      category: 'Bilişsel',
      description:
          'Parmak kuklalarıyla kısa bir hikaye anlatın veya şarkı söyleyin. Hareketler ilgisini çeker.',
    ),
    PlayIdea(
      month: 23,
      title: 'Dans Partisi',
      category: 'Kaba motor',
      description:
          'Bebeğinizi kucakta taşıyıp müzikle dans edin. Ritim ve hareket eğlencelidir.',
    ),
    PlayIdea(
      month: 24,
      title: 'Işıkla Oyun',
      category: 'Görsel',
      description:
          'Fener veya lamba ile ışık ve gölge desenleri oluşturun. Bebekler ışığa bayılır.',
    ),
  ],
};
