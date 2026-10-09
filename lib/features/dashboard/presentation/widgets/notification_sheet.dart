import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final unreadCardColor = isDark ? AppColors.navyDark : AppColors.lightSurface;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = textPrimary.withValues(alpha: 0.65);
    final borderColor = isDark ? AppColors.cardBorder : AppColors.lightCardBorder;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active, color: AppColors.usafGold),
                  const SizedBox(width: 8),
                  Text(
                    'Budget Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: AppColors.statusGreen,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No active budget alerts',
                          style: TextStyle(color: textSecondary),
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
                          color: item.isRead ? cardColor : unreadCardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: item.isRead
                                ? borderColor
                                : AppColors.statusYellow,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            leading: const Icon(
                              Icons.warning_amber,
                              color: AppColors.statusYellow,
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              item.message,
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
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
