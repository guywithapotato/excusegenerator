import '../models/excuse.dart';

class ExcuseRepository {
  ExcuseRepository() : all = [..._build(AppLanguage.tr), ..._build(AppLanguage.en)];

  final List<Excuse> all;

  List<Excuse> byLanguage(AppLanguage language) =>
      all.where((excuse) => excuse.language == language).toList(growable: false);

  List<String> categories(AppLanguage language) =>
      byLanguage(language).map((excuse) => excuse.category).toSet().toList();

  Excuse byId(String id) => all.firstWhere((excuse) => excuse.id == id);

  List<Excuse> search(AppLanguage language, String query, String? category) {
    final q = query.trim().toLowerCase();
    return byLanguage(language).where((excuse) {
      final categoryMatches = category == null || excuse.category == category;
      final textMatches = q.isEmpty || excuse.text.contains(q) || excuse.category.contains(q);
      return categoryMatches && textMatches;
    }).toList(growable: false);
  }
}

List<Excuse> _build(AppLanguage language) {
  final data = language == AppLanguage.tr ? _tr : _en;
  final result = <Excuse>[];
  var global = 0;
  for (final category in data.keys) {
    final pieces = data[category]!;
    for (var i = 0; i < 32; i++) {
      final rarity = _rarityFor(global);
      final legendary = rarity == ExcuseRarity.legendary;
      final text = legendary
          ? pieces.legendary[global % pieces.legendary.length]
          : '${pieces.openers[i % pieces.openers.length]} ${pieces.causes[(i ~/ 4) % pieces.causes.length]} ${pieces.endings[(i ~/ 16) % pieces.endings.length]}';
      result.add(Excuse(
        id: '${language.name}-$category-$i',
        language: language,
        category: category,
        text: text.toLowerCase(),
        rarity: rarity,
      ));
      global++;
    }
  }
  return result;
}

ExcuseRarity _rarityFor(int index) {
  final bucket = index % 100;
  if (bucket < 75) return ExcuseRarity.common;
  if (bucket < 95) return ExcuseRarity.rare;
  if (bucket < 99) return ExcuseRarity.epic;
  return ExcuseRarity.legendary;
}

class _Pieces {
  const _Pieces(this.openers, this.causes, this.endings, this.legendary);
  final List<String> openers;
  final List<String> causes;
  final List<String> endings;
  final List<String> legendary;
}

const _tr = {
  'okul': _Pieces(
    ['okula geliyordum ama', 'tam derse girecekken', 'sıram beni bekliyordu fakat', 'servise bindim sanıyordum ama'],
    ['defterim sabah toplantısı yapmış', 'kantin tostuyla derin bir hesaplaşmaya girdim', 'koridorda zaman yavaşladı', 'çanta fermuarım istifa etti', 'yoklama benden önce pes etti', 'teneffüs kendini fazla uzattı', 'ayakkabım eğitim sistemini sorguladı', 'sınıf kapısı dramatik biçimde kilitlendi'],
    ['o yüzden biraz geciktim', 'bu yüzden olaylar kontrolden çıktı'],
    ['matematik kitabım beni ghostladı', 'okul zili paralel evrende çaldı', 'sıram bugün beni tanımadığını söyledi', 'müdür odası benden imza istedi ama kalemim kehanete daldı'],
  ),
  'ödev': _Pieces(
    ['ödevimi yapacaktım ama', 'tam kalemi elime aldım ki', 'dosyayı açtım fakat', 'ödev planım hazırdı ancak'],
    ['silgim kanıtları yok etti', 'motivasyonum kısa süreliğine tatile çıktı', 'sayfa numaraları kavga etti', 'evdeki sessizlik grev başlattı', 'kalemim sadece şiir yazmak istedi', 'başlık fazla karizmatik geldi', 'internetim vardı ama aklım yoktu', 'defterim bilinçli şekilde saklandı'],
    ['ve teslim saati bana kırıldı', 'bu yüzden sonuç beklenenden sanatsal oldu'],
    ['ödevimi yapacaktım ama zaman çizgisi bozuldu', 'ödevim tamamlandı ama sadece rüyamdaki öğretmen gördü', 'kağıtlarım birbirine aşık olup kaçtı', 'paralel evrendeki ben teslim etmiş, sıra onda sanmışım'],
  ),
  'sınav': _Pieces(
    ['sınava hazırlanmıştım ama', 'tam soruyu okuyordum ki', 'kalemim çalışıyordu fakat', 'cevaplar aklımdaydı ancak'],
    ['beynim bakım moduna geçti', 'şıklar bana fazla samimi geldi', 'silgi stratejik hata yaptı', 'formüller içimde kayboldu', 'saat bana psikolojik baskı yaptı', 'optik form özgüvenimi yedi', 'konular gizli anlaşma yaptı', 'kahvem beklenmedik şekilde taraf değiştirdi'],
    ['o yüzden performansım deneysel kaldı', 'bu nedenle sonuç biraz şiirsel oldu'],
    ['cevap anahtarı beni kıskandığı için saklandı', 'sınav kağıdı kaderimi spoiler verdi', 'beynim sınavı demo sürüm sanmış', 'puanım henüz indirilmeyi bekleyen bir güncelleme'],
  ),
  'geç kalma': _Pieces(
    ['geliyordum ama', 'tam çıkmıştım ki', 'yoldaydım fakat', 'hazırdım ancak'],
    ['alarmım çaldı ama ben kabul etmedim', 'trafik kendi hayatını yaşamaya karar verdi', 'ayakkabım son anda kayboldu', 'asansör kişisel gelişim molasına çıktı', 'otobüs beni uzaktan selamlayıp gitti', 'anahtarlar gizli saklambaç oynadı', 'hava beklenmedik biçimde dramatikti', 'zaman bugün fazla hızlıydı'],
    ['o yüzden gecikme yaşandı', 'bu nedenle dakiklik planı ertelendi'],
    ['ben aslında vaktindeydim ama dünya geç açıldı', 'alternatif zaman çizgisinde tam saatindeydim', 'saatim geleceği gösterdiği için karışıklık oldu', 'yol beni yanlışlıkla yan görev sanmış'],
  ),
  'teknoloji': _Pieces(
    ['bilgisayar açıktı ama', 'telefon elimdeydi fakat', 'dosyayı gönderecektim ancak', 'internet vardı ama'],
    ['wi-fi beni duygusal olarak terk etti', 'şarj kablosu güven sorunları yaşadı', 'güncelleme hayatıma müdahale etti', 'klavye bazı harfleri kıskandı', 'ekran beni sessizce yargıladı', 'bulut dosyamı fazla sahiplendi', 'uygulama kendini yeniden keşfetti', 'bluetooth ilişki istemediğini söyledi'],
    ['o yüzden teknik bir bekleme oluştu', 'bu nedenle dijital süreç hüzünlendi'],
    ['wi-fi ve motivasyonum bu sabah ayrıldı', 'dosyam kuantum klasörüne taşındı', 'şifrem beni tanımayı reddetti', 'internetim vardı ama gerçeklik bağlantısı kopuktu'],
  ),
  'oyun': _Pieces(
    ['oyunu kapatacaktım ama', 'son maç diye girdim fakat', 'tam çıkıyordum ki', 'kontrol bendeydi ancak'],
    ['takımın kaderi bana kaldı', 'boss duygusal konuşma yaptı', 'rank sistemi beni rehin aldı', 'arkadaşlarım stratejik baskı kurdu', 'sunucu vedalaşmama izin vermedi', 'loot kutusu bana göz kırptı', 'görev zinciri yanlışlıkla uzadı', 'klavye savaş moduna geçti'],
    ['o yüzden süre biraz kaydı', 'bu nedenle gerçek hayat bekledi'],
    ['oyun beni npc sanıp bırakmadı', 'rankım aile yadigarı gibi korunmak zorundaydı', 'boss fight resmi mazeret belgesi istedi', 'respawn sürem sosyal hayatımı geçti'],
  ),
  'genel': _Pieces(
    ['yapacaktım ama', 'aslında hazırdım fakat', 'tam başlayacaktım ki', 'planım kusursuzdu ancak'],
    ['çay fazla ikna ediciydi', 'koltuk beni bırakmak istemedi', 'hava görev iptali gibi hissettirdi', 'aklım başka sekmede kaldı', 'enerjim deneme sürümündeydi', 'evren küçük bir güncelleme yaptı', 'çantam sessiz protestoya geçti', 'takvim bana haber vermemiş'],
    ['o yüzden biraz aksadı', 'bu yüzden sonuç beklemeye alındı'],
    ['gerçeklik kısa süreli bakımdaydı', 'ben geldim ama niyetim yolda kaldı', 'planım fazla mükemmel olduğu için uygulanamadı', 'bugünkü ben dünkü bana güvenmiş ve ikisi de gelmemiş'],
  ),
  'tamamen saçma': _Pieces(
    ['gelecektim ama', 'tam harekete geçtim ki', 'niyetim ciddiydi fakat', 'kanıtım vardı ancak'],
    ['uzaylılar ajandamı ödünç aldı', 'buzdolabı felsefe sordu', 'çoraplarım toplantı yaptı', 'ayna bana yan görev verdi', 'kapı kolu dramaya bağladı', 'yer çekimi fazla kişisel davrandı', 'gölge mesaiye kalmadı', 'sandviçim kaderimi değiştirdi'],
    ['o yüzden mantıklı açıklama kalmadı', 'bu nedenle evren şahit gösterilebilir'],
    ['gerçeklik beklenmeyen hata verdi', 'zaman çizgisi fişini çekip yeniden taktı', 'bahanem beni yazmadan önce emekli oldu', 'ay beni görünce rotasını değiştirdi'],
  ),
};

const _en = {
  'school': _Pieces(
    ['i was going to school but', 'right before class', 'my desk was waiting but', 'i thought i was on the bus but'],
    ['my notebook held a morning meeting', 'the hallway slowed down time', 'my backpack zipper resigned', 'attendance gave up before i arrived', 'the bell sounded emotionally unavailable', 'my shoes questioned education', 'the classroom door became dramatic', 'my pencil demanded a lawyer'],
    ['so i arrived a little late', 'and the situation became academic chaos'],
    ['my math book ghosted me', 'the school bell rang in a parallel universe', 'my desk said it did not know me today', 'the principal would believe it if reality cooperated'],
  ),
  'homework': _Pieces(
    ['i was about to do my homework but', 'i picked up my pencil and', 'i opened the file but', 'my homework plan was ready but'],
    ['my eraser destroyed the evidence', 'my motivation took a short vacation', 'the page numbers started arguing', 'the quiet room went on strike', 'my pencil only wanted to write poetry', 'the title became too powerful', 'my wi-fi worked but my brain did not', 'my notebook hid on purpose'],
    ['so the deadline got emotional', 'and the result became unexpectedly artistic'],
    ['my homework was completed in a parallel universe', 'my paper fell in love with another folder', 'the assignment opened a side quest', 'my future self promised to submit it and then vanished'],
  ),
  'exams': _Pieces(
    ['i studied for the exam but', 'i was reading the question when', 'my pencil worked but', 'the answers were in my head but'],
    ['my brain entered maintenance mode', 'the options got too friendly', 'my eraser made a strategic mistake', 'the formulas disappeared inside me', 'the clock applied emotional pressure', 'the answer sheet judged my aura', 'the chapters formed a secret alliance', 'my coffee changed sides'],
    ['so my performance stayed experimental', 'and the result became slightly poetic'],
    ['reality issued an unexpected error', 'the answer key hid because it was jealous', 'my brain thought the exam was a demo version', 'my grade is still downloading'],
  ),
  'being late': _Pieces(
    ['i was on my way but', 'i had just left when', 'i was ready but', 'i was moving fast but'],
    ['my alarm rang and i declined it', 'traffic decided to live its own life', 'my shoes disappeared at the last second', 'the elevator took a self-care break', 'the bus waved from a distance', 'my keys played professional hide and seek', 'the weather became dramatic', 'time was unusually fast today'],
    ['so a delay happened', 'and punctuality had to be postponed'],
    ['i was on time in an alternate timeline', 'the world opened late today', 'my clock showed the future and caused confusion', 'the road mistook me for a side quest'],
  ),
  'technology': _Pieces(
    ['my computer was on but', 'my phone was ready but', 'i was going to send the file but', 'the internet existed but'],
    ['my wi-fi emotionally abandoned me', 'the charger developed trust issues', 'an update interrupted my life', 'the keyboard became jealous of certain letters', 'the screen silently judged me', 'the cloud got possessive with my file', 'the app rediscovered itself', 'bluetooth said it was not ready for commitment'],
    ['so a technical pause occurred', 'and the digital process became sad'],
    ['my wi-fi and motivation broke up this morning', 'my file moved into a quantum folder', 'my password refused to recognize me', 'the internet worked but reality disconnected'],
  ),
  'gaming': _Pieces(
    ['i was going to quit the game but', 'i joined one last match but', 'i was about to log off when', 'i had everything under control but'],
    ['the team destiny depended on me', 'the boss delivered an emotional speech', 'ranked mode took me hostage', 'my friends applied tactical pressure', 'the server refused my goodbye', 'the loot box winked at me', 'the quest chain accidentally expanded', 'the keyboard entered battle mode'],
    ['so the time slipped a little', 'and real life had to wait'],
    ['the game thought i was an npc and kept me', 'my rank had to be protected like family jewelry', 'the boss fight requested an official excuse form', 'my respawn timer outlasted my social life'],
  ),
  'general': _Pieces(
    ['i was going to do it but', 'i was actually ready but', 'i was about to start when', 'my plan was perfect but'],
    ['tea became too convincing', 'the couch refused to release me', 'the weather felt like a cancellation notice', 'my mind stayed in another tab', 'my energy was on a trial version', 'the universe installed a small update', 'my bag started a quiet protest', 'the calendar forgot to warn me'],
    ['so it got delayed a little', 'and the result went into waiting mode'],
    ['reality was briefly under maintenance', 'i arrived but my intention got stuck in traffic', 'the plan was too perfect to be used', 'today me trusted yesterday me and both disappeared'],
  ),
  'completely absurd': _Pieces(
    ['i was going to show up but', 'i started moving but', 'my intention was serious but', 'i had proof but'],
    ['aliens borrowed my schedule', 'the fridge asked a philosophy question', 'my socks held a board meeting', 'the mirror gave me a side quest', 'the door handle became theatrical', 'gravity took things personally', 'my shadow refused overtime', 'my sandwich changed destiny'],
    ['so logic left the room', 'and the universe can be called as a witness'],
    ['physics filed a complaint against my schedule', 'the timeline unplugged itself and rebooted', 'my excuse retired before i could write it', 'the moon changed course after seeing me'],
  ),
};
