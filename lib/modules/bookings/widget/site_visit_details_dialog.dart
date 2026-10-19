import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/modules/bookings/model/site_visit_model.dart';

class SiteVisitDetailsDialog extends StatelessWidget {
  const SiteVisitDetailsDialog({
    super.key,
    required this.visit,
  });

  final SiteVisitModel visit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 30,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gradientPurpleEnd,
                      AppColors.gradientBlueStart,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Site Visit Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _card(
                            'CABIN DETAILS',
                            visit.spaceName,
                            visit.location,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _card(
                            'SPACE TYPE',
                            visit.spaceType,
                            '',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    _card(
                      'CUSTOMER DETAILS',
                      visit.visitorName,
                      '${visit.visitorEmail}\n${visit.visitorMobile}',
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _card(
                            'VISIT DATE',
                            visit.visitDate,
                            '',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _card(
                            'VISIT TIME',
                            visit.visitTime,
                            '',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    _card(
                      'STATUS',
                      _statusText(visit.status),
                      '',
                    ),

                    const SizedBox(height: 8),

                    _card(
                      'CREATED AT',
                      visit.createdAt,
                      '',
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: Get.back,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.gradientPurpleEnd,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(9),
                          ),
                        ),
                        child: const Text(
                          'Close',
                        ),
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

  Widget _card(
      String title,
      String value,
      String subtitle,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.lightPrimary,
              fontSize: 6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusText(
      SiteVisitStatus status,
      ) {
    switch (status) {
      case SiteVisitStatus.pending:
        return 'Pending';
      case SiteVisitStatus.confirmed:
        return 'Confirmed';
      case SiteVisitStatus.completed:
        return 'Completed';
      case SiteVisitStatus.cancelled:
        return 'Cancelled';
    }
  }
}