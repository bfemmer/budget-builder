import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:budget/core/utils/currency_formatter.dart';
import 'package:budget/features/categories/presentation/viewmodels/category_viewmodel.dart';
import 'package:budget/features/transactions/data/models/transaction_model.dart';

class PdfReportGenerator {
  static Future<Uint8List> generate({
    required String timeframeLabel,
    required double totalIncome,
    required double totalExpenses,
    required double netCashFlow,
    required double needsSpent,
    required double wantsSpent,
    required Map<int, double> expenseCategoryMap,
    required Map<int, double> incomeCategoryMap,
    required List<TransactionModel> transactions,
    required CategoryViewModel catVm,
  }) async {
    final pdf = pw.Document();

    final navyPrimary = PdfColor.fromInt(0xFF0F2A4A);
    final goldAccent = PdfColor.fromInt(0xFFFFC72C);
    final greenColor = PdfColors.green700;
    final greyBackground = PdfColors.grey100;
    final textDark = PdfColors.grey900;
    final textMuted = PdfColors.grey700;

    final now = DateTime.now();
    final generatedDateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(now);

    final expenseCount = transactions.where((t) {
      final cat = catVm.getCategoryById(t.categoryId);
      return cat == null || !cat.isIncome;
    }).length;

    final incomeCount = transactions.where((t) {
      final cat = catVm.getCategoryById(t.categoryId);
      return cat != null && cat.isIncome;
    }).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BUDGET BUILDER',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: goldAccent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    pw.Text(
                      'Financial & Spending Report',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: navyPrimary,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: navyPrimary,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        timeframeLabel.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated: $generatedDateStr',
                      style: pw.TextStyle(fontSize: 8, color: textMuted),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 16),
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Budget Builder Financial System',
                  style: pw.TextStyle(fontSize: 8, color: textMuted),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(fontSize: 8, color: textMuted),
                ),
              ],
            ),
          );
        },
        build: (context) => [
          pw.SizedBox(height: 12),

          // Executive Cash Flow Summary Block
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: navyPrimary,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'CASH FLOW SUMMARY',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: goldAccent,
                        letterSpacing: 1.0,
                      ),
                    ),
                    pw.Text(
                      netCashFlow >= 0 ? 'NET SURPLUS' : 'NET DEFICIT',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color:
                            netCashFlow >= 0
                                ? PdfColors.green300
                                : PdfColors.red300,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'TOTAL INCOME',
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey300,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            CurrencyFormatter.format(totalIncome),
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      height: 28,
                      width: 1,
                      color: PdfColors.grey600,
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'TOTAL EXPENSES',
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey300,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            CurrencyFormatter.format(totalExpenses),
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      height: 28,
                      width: 1,
                      color: PdfColors.grey600,
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'NET CASH FLOW',
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey300,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            '${netCashFlow >= 0 ? '+' : ''}${CurrencyFormatter.format(netCashFlow)}',
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                              color:
                                  netCashFlow >= 0
                                      ? PdfColors.green300
                                      : PdfColors.red300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '$expenseCount Expense Transactions | $incomeCount Income Records',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // Need vs Want Analysis Section
          pw.Text(
            'FINANCIAL AWARENESS (NEED VS WANT EXPENSES)',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: navyPrimary,
              letterSpacing: 1.0,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: greyBackground,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'NEEDS (Essential Expenses)',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        CurrencyFormatter.format(needsSpent),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      pw.Text(
                        '${totalExpenses > 0 ? ((needsSpent / totalExpenses) * 100).toStringAsFixed(1) : '0.0'}% of expenses',
                        style: pw.TextStyle(fontSize: 8, color: textMuted),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'WANTS (Discretionary Expenses)',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orange800,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        CurrencyFormatter.format(wantsSpent),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      pw.Text(
                        '${totalExpenses > 0 ? ((wantsSpent / totalExpenses) * 100).toStringAsFixed(1) : '0.0'}% of expenses',
                        style: pw.TextStyle(fontSize: 8, color: textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // Spending by Category Table
          pw.Text(
            'SPENDING BY CATEGORY',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: navyPrimary,
              letterSpacing: 1.0,
            ),
          ),
          pw.SizedBox(height: 8),

          expenseCategoryMap.isEmpty
              ? pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: greyBackground,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  'No expense transactions in this timeframe.',
                  style: pw.TextStyle(fontSize: 9, color: textMuted),
                ),
              )
              : pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                headerStyle: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0F2A4A),
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellHeight: 24,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                },
                headers: ['Category', 'Amount', '% of Total Expenses'],
                data:
                    expenseCategoryMap.entries.map((entry) {
                      final cat = catVm.getCategoryById(entry.key);
                      final spent = entry.value;
                      final pct =
                          totalExpenses > 0
                              ? (spent / totalExpenses) * 100
                              : 0.0;
                      return [
                        cat?.name ?? 'Category #${entry.key}',
                        CurrencyFormatter.format(spent),
                        '${pct.toStringAsFixed(1)}%',
                      ];
                    }).toList(),
              ),

          if (incomeCategoryMap.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'INCOME SOURCES',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: greenColor,
                letterSpacing: 1.0,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.green800,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellHeight: 24,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
              },
              headers: ['Income Source / Category', 'Amount'],
              data:
                  incomeCategoryMap.entries.map((entry) {
                    final cat = catVm.getCategoryById(entry.key);
                    final amount = entry.value;
                    return [
                      cat?.name ?? 'Income Category',
                      CurrencyFormatter.format(amount),
                    ];
                  }).toList(),
            ),
          ],

          if (transactions.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'TRANSACTION RECORD LOG (${transactions.length} ITEMS)',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: navyPrimary,
                letterSpacing: 1.0,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF0F2A4A),
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellHeight: 20,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.centerRight,
              },
              headers: ['Date', 'Description', 'Category', 'Tag', 'Amount'],
              data:
                  transactions.map<List<String>>((t) {
                    final cat = catVm.getCategoryById(t.categoryId);
                    final isInc = cat?.isIncome ?? false;
                    final dateStr = DateFormat('MMM dd, yyyy').format(
                      DateTime.tryParse(t.date) ?? DateTime.now(),
                    );
                    return [
                      dateStr,
                      t.description,
                      cat?.name ?? '-',
                      t.needOrWant,
                      '${isInc ? '+' : ''}${CurrencyFormatter.format(t.amount)}',
                    ];
                  }).toList(),
            ),
          ],
        ],
      ),
    );

    return pdf.save();
  }
}
