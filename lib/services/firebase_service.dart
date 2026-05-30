import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  FirebaseService._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Instance Supabase Storage
  final _supabaseStorage = Supabase.instance.client.storage;

  // Mendapatkan UID pengguna yang sedang login
  String? get currentUserId => _auth.currentUser?.uid;

  // Referensi ke koleksi transaksi milik user
  CollectionReference<Map<String, dynamic>>? get _userTransactions {
    final uid = currentUserId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('transactions');
  }

  // ==== TRANSACTION METHODS ====

  Future<void> createTransaction(TransactionModel transaction) async {
    final collection = _userTransactions;
    if (collection == null) return;

    // Jika ada gambar (path lokal), upload dulu ke Storage
    String? finalImagePath = transaction.imagePath;
    if (finalImagePath != null && !finalImagePath.startsWith('http')) {
      finalImagePath = await uploadReceiptImage(finalImagePath);
    }

    final newDoc = collection.doc();
    final data = transaction.copyWith(id: newDoc.id).toMap();
    
    // Paksa update image_path (karena copyWith akan mengabaikan nilai null)
    data['image_path'] = finalImagePath;

    await newDoc.set(data);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final collection = _userTransactions;
    if (collection == null || transaction.id == null) return;

    String? finalImagePath = transaction.imagePath;
    // Jika gambar baru (berupa path lokal), upload dulu
    if (finalImagePath != null && !finalImagePath.startsWith('http')) {
      finalImagePath = await uploadReceiptImage(finalImagePath);
    }

    final data = transaction.toMap();
    data['image_path'] = finalImagePath; // Paksa update untuk hindari copyWith null bug

    await collection.doc(transaction.id).update(data);
  }

  Future<void> deleteTransaction(String id) async {
    final collection = _userTransactions;
    if (collection == null) return;

    // Optional: Kita juga bisa menghapus gambar dari storage jika ingin
    // Namun untuk sekarang cukup menghapus dokumen di Firestore
    await collection.doc(id).delete();
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final collection = _userTransactions;
    if (collection == null) return [];

    final snapshot = await collection.orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => TransactionModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<double> getTotalBalance() async {
    final transactions = await getAllTransactions();
    double balance = 0;
    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return balance;
  }

  Future<double> getExpenseByCategory(String category, DateTime month) async {
    final transactions = await getAllTransactions();
    
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    double total = 0.0;
    for (var t in transactions) {
      if (t.type == TransactionType.expense && 
          t.category == category &&
          t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) && 
          t.date.isBefore(endOfMonth)) {
        total += t.amount;
      }
    }
    return total;
  }

  // ==== STORAGE METHODS (Menggunakan Supabase Storage) ====

  Future<String?> uploadReceiptImage(String localPath) async {
    final uid = currentUserId;
    if (uid == null) return null;

    try {
      final file = File(localPath);
      if (!await file.exists()) return null;

      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = '$uid/receipts/$fileName';

      // 'receipts' adalah nama bucket di Supabase Anda
      await _supabaseStorage.from('receipts').upload(storagePath, file);
      
      // Ambil public URL dari gambar yang baru diupload
      final publicUrl = _supabaseStorage.from('receipts').getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading receipt image to Supabase: $e');
      return null;
    }
  }

  Future<String?> uploadProfileImage(String localPath) async {
    final uid = currentUserId;
    if (uid == null) return null;

    try {
      final file = File(localPath);
      if (!await file.exists()) return null;

      final fileName = 'profile_$uid.jpg'; // Selalu timpa foto lama
      
      // 'profiles' adalah nama bucket di Supabase Anda
      // Gunakan upsert: true agar foto lama tertimpa dengan foto baru
      await _supabaseStorage.from('profiles').upload(
        fileName, 
        file,
        fileOptions: const FileOptions(upsert: true)
      );
      
      final publicUrl = _supabaseStorage.from('profiles').getPublicUrl(fileName);
      
      // Update juga di data user auth / firestore
      await _auth.currentUser?.updatePhotoURL(publicUrl);
      
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading profile image to Supabase: $e');
      return null;
    }
  }
}
