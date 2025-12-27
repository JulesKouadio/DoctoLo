import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/size_config.dart';
import 'custom_card.dart';

class AgendaSlotCard extends StatelessWidget {
  final String time;
  final String patientName;
  final String appointmentType;
  final String? patientAvatarUrl;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onMarkComplete;

  const AgendaSlotCard({
    super.key,
    required this.time,
    required this.patientName,
    required this.appointmentType,
    this.patientAvatarUrl,
    this.isCompleted = false,
    this.onTap,
    this.onMarkComplete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      color: isCompleted ? AppColors.success.withOpacity(0.05) : Colors.white,
      child: Row(
        children: [
          // Time Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(12), vertical: getProportionateScreenHeight(8)),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  time.split(':')[0],
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(20),
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
                Text(
                  time.split(':')[1],
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(12),
                    color: isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Patient Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: patientAvatarUrl != null
                          ? NetworkImage(patientAvatarUrl!)
                          : null,
                      child: patientAvatarUrl == null
                          ? Icon(
                              CupertinoIcons.person,
                              size: 15,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        patientName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getAppointmentIcon(),
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointmentType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Button
          if (!isCompleted && onMarkComplete != null)
            IconButton(
              icon: Icon(
                CupertinoIcons.check_mark_circled,
                color: AppColors.success,
              ),
              onPressed: onMarkComplete,
            ),
          if (isCompleted)
            Icon(CupertinoIcons.checkmark_circle, color: AppColors.success),
        ],
      ),
    );
  }

  IconData _getAppointmentIcon() {
    switch (appointmentType.toLowerCase()) {
      case 'téléconsultation':
        return CupertinoIcons.videocam_fill;
      case 'urgence':
        return CupertinoIcons.alarm;
      case 'suivi':
        return CupertinoIcons.arrow_2_circlepath;
      default:
        return CupertinoIcons.bag_badge_plus;
    }
  }
}
