import "../models/tip_item.dart";
import "../../../models/baby_profile.dart";

class TodayTipsService {
  const TodayTipsService();

  List<TipItem> getTodayTips(BabyProfile baby) {
    
    return const [
      TipItem(
        title: "Bugünün ipucu",
        body: "Kısa bir öneri metni.",
        type: TipType.health,
      ),
      TipItem(
        title: "Mini oyun",
        body: "Basit bir oyun önerisi.",
        type: TipType.play,
      ),
    ];
  }

  TomorrowPreview getTomorrowPreview(BabyProfile baby) {
    return const TomorrowPreview(
      title: "Yarın",
      body: "Yarın için kısa bir önizleme.",
    );
  }
}
