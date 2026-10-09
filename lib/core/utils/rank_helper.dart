class RankHelper {
  /// Returns the asset path for the rank image PNG if the [rank] string corresponds
  /// to Air Force ranks E-2 through E-9, O-1 through O-6, or General Officer.
  /// Returns null otherwise.
  static String? getRankImageAsset(String? rank) {
    if (rank == null || rank.trim().isEmpty) return null;
    final r = rank.toLowerCase().trim();

    // General Officer (Single star)
    if (r.contains('general') ||
        r.contains('flag officer') ||
        r.contains('o-7') ||
        r.contains('o7') ||
        r.contains('o-8') ||
        r.contains('o8') ||
        r.contains('o-9') ||
        r.contains('o9') ||
        r.contains('o-10') ||
        r.contains('o10')) {
      return 'assets/images/general.png';
    }

    // Officers O-1 to O-6
    if (r.contains('o-6') ||
        r.contains('o6') ||
        (r.contains('colonel') && !r.contains('lieutenant colonel'))) {
      return 'assets/images/o6.png';
    }
    if (r.contains('o-5') ||
        r.contains('o5') ||
        r.contains('lieutenant colonel') ||
        r.contains('lt col')) {
      return 'assets/images/o5.png';
    }
    if (r.contains('o-4') ||
        r.contains('o4') ||
        (r.contains('major') && !r.contains('sergeant'))) {
      return 'assets/images/o4.png';
    }
    if (r.contains('o-3') || r.contains('o3') || r.contains('captain')) {
      return 'assets/images/o3.png';
    }
    if (r.contains('o-2') ||
        r.contains('o2') ||
        r.contains('1st lieutenant') ||
        r.contains('first lieutenant')) {
      return 'assets/images/o2.png';
    }
    if (r.contains('o-1') ||
        r.contains('o1') ||
        r.contains('2nd lieutenant') ||
        r.contains('second lieutenant')) {
      return 'assets/images/o1.png';
    }

    // Enlisted Ranks E-2 to E-9
    if (r.contains('e-9') || r.contains('e9') || r.contains('chief master sergeant')) {
      return 'assets/images/e9.png';
    }
    if (r.contains('e-8') || r.contains('e8') || r.contains('senior master sergeant')) {
      return 'assets/images/e8.png';
    }
    if (r.contains('e-7') || r.contains('e7') || r.contains('master sergeant')) {
      return 'assets/images/e7.png';
    }
    if (r.contains('e-6') || r.contains('e6') || r.contains('technical sergeant')) {
      return 'assets/images/e6.png';
    }
    if (r.contains('e-5') || r.contains('e5') || r.contains('staff sergeant')) {
      return 'assets/images/e5.png';
    }
    if (r.contains('e-4') || r.contains('e4') || r.contains('senior airman')) {
      return 'assets/images/e4.png';
    }
    if (r.contains('e-3') || r.contains('e3') || r.contains('airman first class')) {
      return 'assets/images/e3.png';
    }
    if (r.contains('e-2') ||
        r.contains('e2') ||
        (r.contains('airman') && !r.contains('basic'))) {
      return 'assets/images/e2.png';
    }

    return null;
  }
}
