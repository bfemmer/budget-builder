import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/url_launcher_helper.dart';

class AfasAssistanceScreen extends StatefulWidget {
  const AfasAssistanceScreen({super.key});

  @override
  State<AfasAssistanceScreen> createState() => _AfasAssistanceScreenState();
}

class _AfasAssistanceScreenState extends State<AfasAssistanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategoryIndex = 0;

  final String _afasPortalUrl = 'https://portal.afas.org';
  final String _afasStandardInfoUrl =
      'https://afas.org/how-we-help/standard-assistance/';
  final String _redCrossPhone = '1-877-272-7337';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategoryIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = textPrimary.withValues(alpha: 0.75);
    final borderColor = isDark
        ? AppColors.cardBorder
        : AppColors.lightCardBorder;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.volunteer_activism, color: AppColors.usafRed),
            SizedBox(width: 8),
            Text('AFAS Assistance'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Visit Official AFAS Website',
            onPressed: () => UrlLauncherHelper.openUrl(_afasStandardInfoUrl),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner Card
            _buildHeroBanner(),

            const SizedBox(height: 16),

            // Emergency Red Cross Banner
            _buildEmergencyRedCrossBanner(textPrimary, textSecondary, isDark),

            const SizedBox(height: 24),

            // Category Navigation Header
            Text(
              'Standard Assistance Programs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Interest-free loans and grants tailored for Airmen, Guardians & Families.',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 12),

            // Tab Selector Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip(
                    'Basic Living',
                    0,
                    Icons.home_repair_service,
                    textPrimary,
                    isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    'Emergency Travel',
                    1,
                    Icons.flight_takeoff,
                    textPrimary,
                    isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    'PCS & Logistics',
                    2,
                    Icons.local_shipping,
                    textPrimary,
                    isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    'Education Grants',
                    3,
                    Icons.school,
                    textPrimary,
                    isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    'Family & Child Care',
                    4,
                    Icons.child_friendly,
                    textPrimary,
                    isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Display Content based on Selected Category
            _buildCategoryContent(
              _selectedCategoryIndex,
              cardColor,
              borderColor,
              textPrimary,
              textSecondary,
              isDark,
            ),

            const SizedBox(height: 28),

            // Step-by-Step How to Apply Section
            _buildHowToApplySection(
              cardColor,
              borderColor,
              textPrimary,
              textSecondary,
            ),

            const SizedBox(height: 28),

            // Eligibility & Qualification Quiz Card
            _buildEligibilityCheckerCard(
              cardColor,
              borderColor,
              textPrimary,
              textSecondary,
              isDark,
            ),

            const SizedBox(height: 28),

            // FAQ Expandable Section
            _buildFaqSection(
              cardColor,
              borderColor,
              textPrimary,
              textSecondary,
              isDark,
            ),

            const SizedBox(height: 32),

            // Bottom CTA Callout Card
            _buildBottomApplyCta(textPrimary, textSecondary, isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.airForceBlue, AppColors.navyDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.usafGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.usafGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield,
                  color: AppColors.usafGold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Air & Space Forces Aid Society',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'AFAS Assistance & Relief',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.usafGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'AFAS standard assistance provides zero-interest loans and emergency grants to help Airmen and Guardians overcome temporary financial hardships, unexpected travel, or emergency expenses.',
            style: TextStyle(fontSize: 13.5, color: Colors.white, height: 1.4),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.usafGold,
                    foregroundColor: AppColors.navyDark,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.launch,
                    size: 18,
                    color: AppColors.navyDark,
                  ),
                  label: const Text(
                    'APPLY AT AFAS PORTAL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.navyDark,
                    ),
                  ),
                  onPressed: () => UrlLauncherHelper.openUrl(_afasPortalUrl),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyRedCrossBanner(
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final bannerBg = isDark
        ? AppColors.statusRed.withValues(alpha: 0.2)
        : AppColors.statusRed.withValues(alpha: 0.1);
    final borderColor = isDark
        ? AppColors.statusRed.withValues(alpha: 0.4)
        : AppColors.statusRed.withValues(alpha: 0.3);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone_in_talk, color: AppColors.statusRed, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'After-Hours & Deployed Emergencies',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.statusRed,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '24/7 Red Cross Hero Care Center Assistance',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 13,
                      color: AppColors.statusRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _redCrossPhone,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'CALL 24/7',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: () => UrlLauncherHelper.makePhoneCall(_redCrossPhone),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    int index,
    IconData icon,
    Color textPrimary,
    bool isDark,
  ) {
    final isSelected = _selectedCategoryIndex == index;
    final unselectedBg = isDark ? AppColors.navyCard : AppColors.lightSurface;
    final unselectedBorder = isDark
        ? AppColors.cardBorder
        : AppColors.lightCardBorder;
    final iconColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.usafGold : AppColors.airForceBlue);

    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: iconColor),
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accentBlue,
      backgroundColor: unselectedBg,
      side: BorderSide(
        color: isSelected ? AppColors.accentBlue : unselectedBorder,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12.5,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedCategoryIndex = index;
          });
        }
      },
    );
  }

  Widget _buildCategoryContent(
    int index,
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    switch (index) {
      case 0:
        return _buildProgramCard(
          title: 'Basic Living Expenses',
          icon: Icons.home_repair_service,
          color: isDark ? AppColors.accentBlue : AppColors.airForceBlue,
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          description: 'Assistance for critical living costs when emergency circumstances arise, preventing financial distress.',
          coveredItems: [
            'Rent / Mortgage payments',
            'Food & Grocery essentials',
            'Utility bills (electric, water, heating)',
            'Essential vehicle repairs & maintenance',
            'Medical & Dental expenses not covered by TRICARE',
          ],
        );
      case 1:
        return _buildProgramCard(
          title: 'Emergency Travel Assistance',
          icon: Icons.flight_takeoff,
          color: isDark ? AppColors.usafGold : AppColors.statusYellow,
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          description: 'Immediate funding for urgent travel in the event of severe family illness, injury, or death.',
          coveredItems: [
            'Round-trip airline tickets for service member & spouse',
            'Emergency vehicle fuel & lodging en route',
            'Bereavement & funeral attendance travel costs',
          ],
        );
      case 2:
        return _buildProgramCard(
          title: 'PCS & Logistics Expenses',
          icon: Icons.local_shipping,
          color: AppColors.statusGreen,
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          description: 'Bridge funding during Permanent Change of Station (PCS) relocations to ease out-of-pocket stress.',
          coveredItems: [
            'Temporary lodging expenses beyond TLE cap',
            'Vehicle shipment / transport costs',
            'Security deposits & utility connection fees at new duty station',
            'Unreimbursed moving expenses during unexpected PCS timelines',
          ],
        );
      case 3:
        return _buildProgramCard(
          title: 'Education Grants & Scholarships',
          icon: Icons.school,
          color: AppColors.tagWant,
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          description: 'Educational support programs designed to help spouses and dependents achieve higher education degrees.',
          coveredItems: [
            'General Henry H. Arnold Education Grant (\$500 – \$4,000/yr)',
            'AFAS Merit Awards for outstanding academic performance',
            'Supplemental Education Loans for tuition & textbooks',
          ],
        );
      case 4:
      default:
        return _buildProgramCard(
          title: 'Family & Child Care Support',
          icon: Icons.child_friendly,
          color: AppColors.tagCredit,
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          description: 'Community programs providing free respite, baby bundles, and spouse career training.',
          coveredItems: [
            'Bundles for Babies: Free \$100+ baby gift bundle & parenting class',
            'Give Parents a Break: Free monthly high-quality childcare',
            'Spouse Employment & Licensure Reskill Grants',
            'Car seat safety grants & emergency family assistance',
          ],
        );
    }
  }

  Widget _buildProgramCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required String description,
    required List<String> coveredItems,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: textSecondary, height: 1.35),
          ),
          const SizedBox(height: 14),
          Text(
            'WHAT CAN BE COVERED:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          ...coveredItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 12.5, color: textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToApplySection(
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to Apply (4-Step Process)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Step-by-step path to requesting emergency or standard assistance.',
          style: TextStyle(fontSize: 13, color: textSecondary),
        ),
        const SizedBox(height: 16),
        _buildStepItem(
          stepNumber: '1',
          title: 'Confirm Eligibility',
          subtitle: 'Active Duty Airmen/Guardians, Guard/Reserve on Title 10 (>30 days), Retired, and eligible dependents.',
          icon: Icons.verified_user,
          color: AppColors.accentBlue,
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: 10),
        _buildStepItem(
          stepNumber: '2',
          title: 'Gather Required Documentation',
          subtitle: 'Recent LES (Leave & Earnings Statement), Military ID, bill/repair estimate/quote, or travel orders.',
          icon: Icons.folder_shared,
          color: AppColors.usafGold,
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: 10),
        _buildStepItem(
          stepNumber: '3',
          title: 'Submit Application',
          subtitle: 'Apply online at portal.afas.org or visit your local Military & Family Readiness Center (M&FRC).',
          icon: Icons.send,
          color: AppColors.statusGreen,
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: 10),
        _buildStepItem(
          stepNumber: '4',
          title: 'Review & Rapid Disbursement',
          subtitle: 'Caseworker review & approval. Funds are sent via direct deposit or electronic transfer.',
          icon: Icons.account_balance,
          color: AppColors.tagWant,
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required String stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Text(
              stepNumber,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityCheckerCard(
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.usafGold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fact_check,
                color: isDark ? AppColors.usafGold : AppColors.airForceBlue,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'AFAS Emergency Assistance Checklist',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Check if your expense qualifies under AFAS emergency guidelines:',
            style: TextStyle(fontSize: 12.5, color: textSecondary),
          ),
          const SizedBox(height: 10),
          _buildChecklistRow(
            'Is the expense unexpected and due to emergency circumstances?',
            textPrimary,
          ),
          _buildChecklistRow(
            'Is the expense for essential basic needs (housing, food, utilities, car)?',
            textPrimary,
          ),
          _buildChecklistRow(
            'Do you have supporting documentation (bill, quote, or LES)?',
            textPrimary,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.usafGold.withValues(alpha: 0.1)
                  : AppColors.usafGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.usafGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDark ? AppColors.usafGold : AppColors.airForceBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tip: If you checked yes to these, you are likely eligible to apply for interest-free loan or grant support.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistRow(String text, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_box_outlined,
            color: AppColors.statusGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildFaqItem(
          question: 'Is AFAS assistance a loan or a grant?',
          answer: 'Standard financial assistance is usually provided as an interest-free loan, a grant, or a combination of both depending on individual circumstances and financial hardship.',
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildFaqItem(
          question: 'How long does approval take?',
          answer: 'Routine applications are typically reviewed within 24-48 hours. Emergency travel or critical basic living situations are fast-tracked for immediate same-day processing.',
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildFaqItem(
          question: 'Who is eligible for assistance?',
          answer: 'Active Duty Airmen & Guardians, Air National Guard & Reserve members on active Title 10 orders (>30 days), retired personnel, and surviving spouses.',
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          iconColor: isDark ? AppColors.usafGold : AppColors.accentBlue,
          collapsedIconColor: textSecondary,
          title: Text(
            question,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 12.5,
                  color: textSecondary,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomApplyCta(
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.accentBlue.withValues(alpha: 0.12)
            : AppColors.accentBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.accentBlue.withValues(alpha: 0.3)
              : AppColors.accentBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Submit an Application?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Access the secure Air & Space Forces Aid Society portal directly to get started.',
            style: TextStyle(fontSize: 12, color: textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.open_in_new,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'OPEN PORTAL.AFAS.ORG',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () => UrlLauncherHelper.openUrl(_afasPortalUrl),
            ),
          ),
        ],
      ),
    );
  }
}
