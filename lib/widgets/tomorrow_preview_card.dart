import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:neomama/models/tomorrow_preview.dart';
import 'package:neomama/core/theme/app_colors.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class TomorrowPreviewCard extends StatelessWidget {
  final TomorrowPreview preview;

  const TomorrowPreviewCard({super.key, required this.preview});

  @override
  Widget build(BuildContext context) {
    final hasReason = (preview.reason ?? '').trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.o(0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.o(0.35)),
            boxShadow: [
              BoxShadow(
                blurRadius: 22,
                offset: const Offset(0, 12),
                color: Colors.black.o(0.08),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.secondary.o(0.16),
                  border: Border.all(
                    color: AppColors.secondary.o(0.22),
                  ),
                ),
                child: const Icon(Icons.wb_twilight_rounded, size: 18, color: Color(0xFF6D6C83)),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview.title,
                            style: const TextStyle(
                              fontSize: 13.4,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2F2E3A),
                            ),
                          ),
                        ),
                        if (hasReason)
                          IconButton(
                            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                            padding: EdgeInsets.zero,
                            tooltip: AppStrings.t(context, 'why_this_preview'),
                            icon: const Icon(Icons.info_outline_rounded, size: 18),
                            onPressed: () => _showReason(context),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview.body,
                      style: const TextStyle(
                        fontSize: 12.8,
                        height: 1.25,
                        color: Color(0xFF3E3D52),
                        fontWeight: FontWeight.w700,
                      ),
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

  void _showReason(BuildContext context) {
    final reason = (preview.reason ?? '').trim();
    if (reason.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.o(0.92),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.o(0.35)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppStrings.t(context, 'why_this_preview'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: Color(0xFF2F2E3A),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reason,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.25,
                          color: Color(0xFF3E3D52),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
