import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/sqlite/database_helper.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_viewmodel.dart';

// Profile
import 'features/profile/data/datasources/profile_local_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/viewmodels/profile_viewmodel.dart';

// Categories
import 'features/categories/data/datasources/category_local_datasource.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/presentation/screens/categories_screen.dart';
import 'features/categories/presentation/viewmodels/category_viewmodel.dart';

// Transactions
import 'features/transactions/data/datasources/transaction_local_datasource.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/presentation/screens/transactions_screen.dart';
import 'features/transactions/presentation/viewmodels/transaction_viewmodel.dart';

// Dashboard & Notifications
import 'features/dashboard/data/datasources/notification_local_datasource.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';

// Track
import 'features/track/presentation/screens/track_screen.dart';

// Reports
import 'features/reports/presentation/screens/reports_screen.dart';
import 'features/reports/presentation/viewmodels/reports_viewmodel.dart';

// Data Transfer
import 'features/data_transfer/data/datasources/backup_restore_datasource.dart';
import 'features/data_transfer/presentation/screens/backup_restore_screen.dart';
import 'features/data_transfer/presentation/viewmodels/backup_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences prior to UI rendering to eliminate mode flickering
  final prefs = await SharedPreferences.getInstance();

  // Initialize SQLite database
  final dbHelper = DatabaseHelper.instance;

  // Initialize DataSources
  final profileDataSource = ProfileLocalDataSourceImpl(dbHelper: dbHelper);
  final categoryDataSource = CategoryLocalDataSourceImpl(dbHelper: dbHelper);
  final txDataSource = TransactionLocalDataSourceImpl(dbHelper: dbHelper);
  final notificationDataSource = NotificationLocalDataSource(
    dbHelper: dbHelper,
  );
  final backupDataSource = BackupRestoreDataSource(dbHelper: dbHelper);

  // Initialize Repositories
  final profileRepo = ProfileRepositoryImpl(localDataSource: profileDataSource);
  final categoryRepo = CategoryRepositoryImpl(
    localDataSource: categoryDataSource,
  );
  final txRepo = TransactionRepositoryImpl(localDataSource: txDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel(prefs: prefs, dbHelper: dbHelper),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(repository: profileRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryViewModel(repository: categoryRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionViewModel(
            repository: txRepo,
            notificationDataSource: notificationDataSource,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(
            notificationDataSource: notificationDataSource,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportsViewModel(repository: txRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => BackupViewModel(dataSource: backupDataSource),
        ),
      ],
      child: const BudgetBuilderApp(),
    ),
  );
}

class BudgetBuilderApp extends StatelessWidget {
  const BudgetBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeVm, child) {
        return MaterialApp(
          title: 'Budget Builder',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeVm.themeMode,
          home: const MainNavigationWrapper(),
        );
      },
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onNavigateTab: _onTabSelected),
      const TransactionsScreen(),
      const TrackScreen(),
      const ReportsScreen(),
      const SettingsTabMenu(),
    ];

    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Track'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class SettingsTabMenu extends StatelessWidget {
  const SettingsTabMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVm = Provider.of<ThemeViewModel>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Settings'),
          actions: [
            IconButton(
              icon: Icon(
                themeVm.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: AppColors.usafGold,
              ),
              tooltip: themeVm.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
              onPressed: () => themeVm.toggleTheme(),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.accentBlue,
            labelColor: AppColors.accentBlue,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.tune), text: 'Spend Limits'),
              Tab(icon: Icon(Icons.swap_vert), text: 'Backup'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProfileScreen(),
            CategoriesScreen(),
            BackupRestoreScreen(),
          ],
        ),
      ),
    );
  }
}
