class DbTables {
  static const String profile = 'profile';
  static const String categories = 'categories';
  static const String transactions = 'transactions';
  static const String notifications = 'notifications';

  static const String createProfileTable = '''
    CREATE TABLE $profile (
      id INTEGER PRIMARY KEY DEFAULT 1,
      first_name TEXT NOT NULL,
      last_name TEXT NOT NULL,
      rank TEXT NOT NULL,
      duty_station TEXT NOT NULL,
      gender TEXT NOT NULL,
      date_of_birth TEXT NOT NULL,
      family_size TEXT NOT NULL,
      email TEXT NOT NULL
    );
  ''';

  static const String createCategoriesTable = '''
    CREATE TABLE $categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      monthly_limit REAL NOT NULL DEFAULT 0.0,
      icon_name TEXT NOT NULL DEFAULT 'category',
      color_value INTEGER NOT NULL DEFAULT 0xFF0066FF,
      is_income INTEGER NOT NULL DEFAULT 0
    );
  ''';

  static const String createTransactionsTable = '''
    CREATE TABLE $transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      description TEXT NOT NULL,
      category_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      amount REAL NOT NULL,
      vendor TEXT NOT NULL,
      payment_type TEXT NOT NULL,
      need_or_want TEXT NOT NULL,
      FOREIGN KEY (category_id) REFERENCES $categories (id) ON DELETE CASCADE
    );
  ''';

  static const String createNotificationsTable = '''
    CREATE TABLE $notifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      message TEXT NOT NULL,
      category_id INTEGER,
      timestamp TEXT NOT NULL,
      is_read INTEGER NOT NULL DEFAULT 0
    );
  ''';

  // Seed default USAF Categories as detailed in AFAS Manual
  static const List<Map<String, dynamic>> defaultCategories = [
    {
      'name': 'Food & Dining',
      'monthly_limit': 600.0,
      'icon_name': 'fastfood',
      'color_value': 0xFF10B981, // Emerald Green
      'is_income': 0,
    },
    {
      'name': 'Bills & Utilities',
      'monthly_limit': 450.0,
      'icon_name': 'receipt_long',
      'color_value': 0xFF3B82F6, // Blue
      'is_income': 0,
    },
    {
      'name': 'Auto & Transport',
      'monthly_limit': 500.0,
      'icon_name': 'directions_car',
      'color_value': 0xFF8B5CF6, // Purple
      'is_income': 0,
    },
    {
      'name': 'Shopping',
      'monthly_limit': 250.0,
      'icon_name': 'shopping_bag',
      'color_value': 0xFFEC4899, // Pink
      'is_income': 0,
    },
    {
      'name': 'Entertainment',
      'monthly_limit': 150.0,
      'icon_name': 'movie',
      'color_value': 0xFFF59E0B, // Amber
      'is_income': 0,
    },
    {
      'name': 'Education',
      'monthly_limit': 200.0,
      'icon_name': 'school',
      'color_value': 0xFF06B6D4, // Cyan
      'is_income': 0,
    },
    {
      'name': 'Health & Fitness',
      'monthly_limit': 120.0,
      'icon_name': 'fitness_center',
      'color_value': 0xFF14B8A6, // Teal
      'is_income': 0,
    },
    {
      'name': 'Personal Care',
      'monthly_limit': 100.0,
      'icon_name': 'spa',
      'color_value': 0xFFA855F7, // Violet
      'is_income': 0,
    },
    {
      'name': 'Travel',
      'monthly_limit': 300.0,
      'icon_name': 'flight',
      'color_value': 0xFF6366F1, // Indigo
      'is_income': 0,
    },
    {
      'name': 'Military Pay / Income',
      'monthly_limit': 0.0,
      'icon_name': 'account_balance_wallet',
      'color_value': 0xFF10B981, // Green
      'is_income': 1,
    },
  ];

  static const Map<String, dynamic> defaultProfile = {
    'id': 1,
    'first_name': 'Senior Airman',
    'last_name': 'Brooke',
    'rank': 'Senior Airman (E-4)',
    'duty_station': 'Eglin AFB, FL',
    'gender': 'Female',
    'date_of_birth': '1995-06-29',
    'family_size': 'Single with no children/dependents',
    'email': 'airman.brooke@us.af.mil',
  };
}
