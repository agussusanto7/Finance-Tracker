import 'dart:io';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';

class FullScreenImageScreen extends StatelessWidget {
  final String imagePath;
  final TransactionModel transaction;

  const FullScreenImageScreen({
    super.key,
    required this.imagePath,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = imagePath.startsWith('http');
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detail Bukti', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: isNetwork
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 64, color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Gambar tidak dapat dimuat',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          );
                        },
                      )
                    : Image.file(
                        File(imagePath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 64, color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Gambar tidak dapat dimuat',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.05),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusLarge),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.category,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.02),
                          Text(
                            DateFormatter.formatDateTime(transaction.date),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenWidth * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: transaction.type == TransactionType.expense
                            ? AppConstants.errorColor
                            : AppConstants.successColor,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      child: Text(
                        transaction.type.displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                  SizedBox(height: screenWidth * 0.03),
                  Text(
                    'Catatan: ${transaction.note}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
                SizedBox(height: screenWidth * 0.03),
                Text(
                  CurrencyFormatter.formatCurrency(transaction.amount),
                  style: TextStyle(
                    color: AppConstants.primaryOrange,
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
