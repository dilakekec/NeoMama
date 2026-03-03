import 'package:neomama/l10n/app_strings.dart';
import 'community_models.dart';

List<CommunityRoom> communityRoomsFor(String code) {
  String t(String key) => AppStrings.byCode(code, key);

  return [
    CommunityRoom(
      id: 'sleep',
      title: t('community_room_sleep_title'),
      question: t('community_room_sleep_q'),
      emoji: '😴',
      tags: [
        t('community_tag_early_bed'),
        t('community_tag_white_noise'),
        t('community_tag_routine'),
      ],
      experiences: [
        CommunityExperience(
          id: 'sleep_early_bed',
          title: t('community_exp_sleep_1_title'),
          body: t('community_exp_sleep_1_body'),
          tags: [
            t('community_tag_early_bed'),
            t('community_tag_routine'),
          ],
          workedCount: 38,
          aiReview: AiReview.pass,
          medicalClaim: false,
        ),
        CommunityExperience(
          id: 'sleep_white_noise',
          title: t('community_exp_sleep_2_title'),
          body: t('community_exp_sleep_2_body'),
          tags: [
            t('community_tag_white_noise'),
            t('community_tag_routine'),
          ],
          workedCount: 24,
          aiReview: AiReview.pass,
          medicalClaim: false,
        ),
      ],
    ),
    CommunityRoom(
      id: 'feeding',
      title: t('community_room_feeding_title'),
      question: t('community_room_feeding_q'),
      emoji: '🥣',
      tags: [
        t('community_tag_short_feeds'),
        t('community_tag_upright'),
        t('community_tag_burp'),
      ],
      experiences: [
        CommunityExperience(
          id: 'feeding_short',
          title: t('community_exp_feeding_1_title'),
          body: t('community_exp_feeding_1_body'),
          tags: [
            t('community_tag_short_feeds'),
            t('community_tag_upright'),
          ],
          workedCount: 19,
          aiReview: AiReview.pass,
          medicalClaim: false,
        ),
        CommunityExperience(
          id: 'feeding_burp',
          title: t('community_exp_feeding_2_title'),
          body: t('community_exp_feeding_2_body'),
          tags: [
            t('community_tag_burp'),
            t('community_tag_upright'),
          ],
          workedCount: 14,
          aiReview: AiReview.pass,
          medicalClaim: false,
        ),
      ],
    ),
    CommunityRoom(
      id: 'teething',
      title: t('community_room_teething_title'),
      question: t('community_room_teething_q'),
      emoji: '🦷',
      tags: [
        t('community_tag_cold_teether'),
        t('community_tag_gum_massage'),
        t('community_tag_short_nap'),
      ],
      experiences: [
        CommunityExperience(
          id: 'teeth_cold',
          title: t('community_exp_teething_1_title'),
          body: t('community_exp_teething_1_body'),
          tags: [
            t('community_tag_cold_teether'),
            t('community_tag_short_nap'),
          ],
          workedCount: 27,
          aiReview: AiReview.pass,
          medicalClaim: false,
        ),
        CommunityExperience(
          id: 'teeth_massage',
          title: t('community_exp_teething_2_title'),
          body: t('community_exp_teething_2_body'),
          tags: [
            t('community_tag_gum_massage'),
            t('community_tag_short_nap'),
          ],
          workedCount: 21,
          aiReview: AiReview.pass,
          medicalClaim: false,
        ),
      ],
    ),
    CommunityRoom(
      id: 'new_food',
      title: t('community_room_new_food_title'),
      question: t('community_room_new_food_q'),
      emoji: '🥕',
      tags: [
        t('community_tag_three_day_watch'),
        t('community_tag_food_journal'),
        t('community_tag_hydration'),
      ],
      experiences: [
        CommunityExperience(
          id: 'new_food_watch',
          title: t('community_exp_new_food_1_title'),
          body: t('community_exp_new_food_1_body'),
          tags: [
            t('community_tag_three_day_watch'),
            t('community_tag_food_journal'),
          ],
          workedCount: 31,
          aiReview: AiReview.caution,
          medicalClaim: true,
        ),
        CommunityExperience(
          id: 'new_food_photos',
          title: t('community_exp_new_food_2_title'),
          body: t('community_exp_new_food_2_body'),
          tags: [
            t('community_tag_food_journal'),
            t('community_tag_hydration'),
          ],
          workedCount: 17,
          aiReview: AiReview.pass,
          medicalClaim: false,
        ),
      ],
    ),
  ];
}
