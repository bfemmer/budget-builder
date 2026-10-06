import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.navySurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications_active, color: AppColors.usafGold),
                  SizedBox(width: 8),
                  Text(
                    'Budget Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (vm.notifications.isNotEmpty)
                TextButton(
                  onPressed: () => vm.clearAllNotifications(),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: AppColors.statusRed),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: vm.notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: AppColors.statusGreen,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No active budget alerts',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: vm.notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = vm.notifications[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: item.isRead
                              ? AppColors.navyCard
                              : AppColors.navyDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: item.isRead
                                ? AppColors.cardBorder
                                : AppColors.statusYellow,
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.warning_amber,
                            color: AppColors.statusYellow,
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            item.message,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: item.isRead
                              ? null
                              : IconButton(
                                  icon: const Icon(
                                    Icons.mark_email_read,
                                    size: 18,
                                    color: AppColors.accentBlue,
                                  ),
                                  onPressed: () {
                                    if (item.id != null) {
                                      vm.markAsRead(item.id!);
                                    }
                                  },
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
