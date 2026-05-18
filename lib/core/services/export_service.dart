import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import 'hive_service.dart';

/// Export Service for CSV and PDF generation
class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  final _hiveService = HiveService.instance;

  /// Export transactions to CSV file
  Future<File?> exportToCSV({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    try {
      // Get transactions
      List<TransactionModel> transactions =
          _hiveService.transactionsBox.values.toList();

      // Apply filters
      if (startDate != null) {
        transactions = transactions
            .where((t) =>
                t.dateTime.isAfter(startDate) ||
                t.dateTime.isAtSameMomentAs(startDate))
            .toList();
      }
      if (endDate != null) {
        transactions = transactions
            .where((t) =>
                t.dateTime.isBefore(endDate) ||
                t.dateTime.isAtSameMomentAs(endDate))
            .toList();
      }
      if (type != null) {
        transactions = transactions.where((t) => t.type == type).toList();
      }

      // Sort by date (newest first)
      transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      // Create CSV data
      final List<List<dynamic>> csvData = [
        // Header row
        [
          'Date',
          'Time',
          'Type',
          'Category',
          'Amount',
          'Account',
          'Notes',
          'Tags',
        ],
      ];

      // Data rows
      final dateFormat = DateFormat('yyyy-MM-dd');
      final timeFormat = DateFormat('HH:mm');

      for (final transaction in transactions) {
        final category = _hiveService.categoriesBox.get(transaction.categoryId);
        final account = _hiveService.accountsBox.get(transaction.accountId);

        csvData.add([
          dateFormat.format(transaction.dateTime),
          timeFormat.format(transaction.dateTime),
          transaction.type.name.toUpperCase(),
          category?.name ?? 'Unknown',
          transaction.amount.toStringAsFixed(2),
          account?.name ?? 'Unknown',
          transaction.notes ?? '',
          transaction.tags.join(', '),
        ]);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(csvData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/spendora_export_$timestamp.csv');
      await file.writeAsString(csvString);

      return file;
    } catch (e) {
      debugPrint('Error exporting to CSV: $e');
      return null;
    }
  }

  /// Share CSV file
  Future<bool> shareCSV({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    final file = await exportToCSV(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );

    if (file != null) {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Spendora Transactions Export',
        text: 'Exported transactions from Spendora',
      );
      return true;
    }
    return false;
  }

  /// Generate PDF report
  Future<File?> generatePDFReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Default to current month if no dates provided
      final now = DateTime.now();
      final start = startDate ?? DateTime(now.year, now.month, 1);
      final end = endDate ?? DateTime(now.year, now.month + 1, 0);

      // Get transactions for the period
      List<TransactionModel> transactions =
          _hiveService.transactionsBox.values.where((t) {
        return (t.dateTime.isAfter(start) ||
                t.dateTime.isAtSameMomentAs(start)) &&
            (t.dateTime.isBefore(end) || t.dateTime.isAtSameMomentAs(end));
      }).toList();

      transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      // Calculate summary
      double totalIncome = 0;
      double totalExpense = 0;
      final Map<String, double> categoryTotals = {};

      for (final t in transactions) {
        if (t.type == TransactionType.income) {
          totalIncome += t.amount;
        } else if (t.type == TransactionType.expense) {
          totalExpense += t.amount;
          categoryTotals[t.categoryId] =
              (categoryTotals[t.categoryId] ?? 0) + t.amount;
        }
      }

      final balance = totalIncome - totalExpense;

      // Create PDF document
      final pdf = pw.Document();
      final dateFormat = DateFormat('MMM dd, yyyy');
      final currencyFormat =
          NumberFormat.currency(symbol: '\$', decimalDigits: 2);

      // Add pages
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _buildPDFHeader(start, end, dateFormat),
          footer: (context) => _buildPDFFooter(context),
          build: (context) => [
            // Summary Section
            _buildSummarySection(
              totalIncome,
              totalExpense,
              balance,
              currencyFormat,
            ),
            pw.SizedBox(height: 20),

            // Category Breakdown
            _buildCategorySection(categoryTotals, currencyFormat),
            pw.SizedBox(height: 20),

            // Transactions List
            _buildTransactionsSection(transactions, dateFormat, currencyFormat),
          ],
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/spendora_report_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      return null;
    }
  }

  pw.Widget _buildPDFHeader(
      DateTime start, DateTime end, DateFormat dateFormat) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Spendora',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0D4A3E'),
              ),
            ),
            pw.Text(
              'Financial Report',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          '${dateFormat.format(start)} - ${dateFormat.format(end)}',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.Divider(thickness: 2, color: PdfColor.fromHex('#0D4A3E')),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildPDFFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }

  pw.Widget _buildSummarySection(
    double income,
    double expense,
    double balance,
    NumberFormat currencyFormat,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total Income',
                currencyFormat.format(income),
                PdfColors.green,
              ),
              _buildSummaryItem(
                'Total Expenses',
                currencyFormat.format(expense),
                PdfColors.red,
              ),
              _buildSummaryItem(
                'Net Balance',
                currencyFormat.format(balance),
                balance >= 0 ? PdfColors.green : PdfColors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildCategorySection(
    Map<String, double> categoryTotals,
    NumberFormat currencyFormat,
  ) {
    if (categoryTotals.isEmpty) {
      return pw.SizedBox();
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Spending by Category',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Category',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Amount',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            ...sortedCategories.take(10).map((entry) {
              final category = _hiveService.categoriesBox.get(entry.key);
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(category?.name ?? 'Unknown'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(currencyFormat.format(entry.value)),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTransactionsSection(
    List<TransactionModel> transactions,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
  ) {
    if (transactions.isEmpty) {
      return pw.Text('No transactions for this period.');
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Recent Transactions',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text('Date',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text('Category',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text('Type',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text('Amount',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            ...transactions.take(50).map((t) {
              final category = _hiveService.categoriesBox.get(t.categoryId);
              final isIncome = t.type == TransactionType.income;
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(dateFormat.format(t.dateTime),
                        style: const pw.TextStyle(fontSize: 9)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(category?.name ?? 'Unknown',
                        style: const pw.TextStyle(fontSize: 9)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(t.type.name,
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: isIncome ? PdfColors.green : PdfColors.red,
                        )),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      '${isIncome ? '+' : '-'}${currencyFormat.format(t.amount)}',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: isIncome ? PdfColors.green : PdfColors.red,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        if (transactions.length > 50)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              '... and ${transactions.length - 50} more transactions',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
      ],
    );
  }

  /// Share PDF report
  Future<bool> sharePDFReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final file = await generatePDFReport(
      startDate: startDate,
      endDate: endDate,
    );

    if (file != null) {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Spendora Financial Report',
        text: 'Financial report generated by Spendora',
      );
      return true;
    }
    return false;
  }
}
