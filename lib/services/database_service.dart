import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/buku.dart';
import '../models/anggota.dart';
import '../models/transaksi.dart';

class DatabaseService {
  static Database? _database;
  static bool _initialized = false;  // ✅ TAMBAHKAN

  // ✅ TAMBAHKAN METHOD INI — INI YANG HILANG
  static void initFactory() {
    if (_initialized) return;
    if (kIsWeb) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _initialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'perpustakaan.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Buku
    await db.execute('''
      CREATE TABLE buku(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT NOT NULL,
        pengarang TEXT NOT NULL,
        penerbit TEXT NOT NULL,
        kategori TEXT NOT NULL,
        stok INTEGER NOT NULL,
        rak TEXT NOT NULL
      )
    ''');

    // Tabel Anggota
    await db.execute('''
      CREATE TABLE anggota(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        nis TEXT NOT NULL,
        kelas TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // Tabel Transaksi
    await db.execute('''
      CREATE TABLE transaksi(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idBuku INTEGER NOT NULL,
        idAnggota INTEGER NOT NULL,
        judulBuku TEXT NOT NULL,
        namaAnggota TEXT NOT NULL,
        tanggalPinjam TEXT NOT NULL,
        batasKembali TEXT NOT NULL,
        tanggalKembali TEXT,
        status TEXT NOT NULL,
        denda REAL DEFAULT 0
      )
    ''');

    // Data awal: Petugas
    await db.insert('anggota', {
      'nama': 'Petugas Perpustakaan',
      'nis': 'P001',
      'kelas': '-',
      'username': 'petugas',
      'password': 'petugas123',
      'role': 'petugas',
    });

    // Data awal: Anggota
    await db.insert('anggota', {
      'nama': 'Budi Santoso',
      'nis': '2024001',
      'kelas': 'XII RPL 1',
      'username': 'budi',
      'password': 'budi123',
      'role': 'anggota',
    });

    // Data awal: Buku
    final bukuAwal = [
      {'judul': 'Pemrograman Dart', 'pengarang': 'Andi', 'penerbit': 'Informatika', 'kategori': 'Teknologi', 'stok': 5, 'rak': 'A1'},
      {'judul': 'Flutter untuk Pemula', 'pengarang': 'Budi', 'penerbit': 'Elex Media', 'kategori': 'Teknologi', 'stok': 3, 'rak': 'A2'},
      {'judul': 'Laskar Pelangi', 'pengarang': 'Andrea Hirata', 'penerbit': 'Bentang', 'kategori': 'Novel', 'stok': 4, 'rak': 'B1'},
      {'judul': 'Bumi Manusia', 'pengarang': 'Pramoedya', 'penerbit': 'Lentera', 'kategori': 'Novel', 'stok': 2, 'rak': 'B2'},
      {'judul': 'Algoritma & Struktur Data', 'pengarang': 'Rinaldi', 'penerbit': 'Andi', 'kategori': 'Teknologi', 'stok': 6, 'rak': 'A3'},
    ];
    for (var b in bukuAwal) {
      await db.insert('buku', b);
    }
  }

  // ===== BUKU =====
  Future<List<Buku>> getAllBuku() async {
    final db = await database;
    final maps = await db.query('buku', orderBy: 'judul ASC');
    return maps.map((e) => Buku.fromMap(e)).toList();
  }

  Future<int> insertBuku(Buku buku) async {
    final db = await database;
    return await db.insert('buku', buku.toMap());
  }

  Future<int> updateBuku(Buku buku) async {
    final db = await database;
    return await db.update('buku', buku.toMap(), where: 'id = ?', whereArgs: [buku.id]);
  }

  Future<int> deleteBuku(int id) async {
    final db = await database;
    return await db.delete('buku', where: 'id = ?', whereArgs: [id]);
  }

  // ===== ANGGOTA =====
  Future<List<Anggota>> getAllAnggota() async {
    final db = await database;
    final maps = await db.query('anggota', where: 'role = ?', whereArgs: ['anggota']);
    return maps.map((e) => Anggota.fromMap(e)).toList();
  }

  Future<Anggota?> login(String username, String password) async {
    final db = await database;
    final maps = await db.query(
      'anggota',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isEmpty) return null;
    return Anggota.fromMap(maps.first);
  }

  Future<int> insertAnggota(Anggota anggota) async {
    final db = await database;
    return await db.insert('anggota', anggota.toMap());
  }

  Future<int> updateAnggota(Anggota anggota) async {
    final db = await database;
    return await db.update('anggota', anggota.toMap(), where: 'id = ?', whereArgs: [anggota.id]);
  }

  Future<int> deleteAnggota(int id) async {
    final db = await database;
    return await db.delete('anggota', where: 'id = ?', whereArgs: [id]);
  }

  // ===== TRANSAKSI =====
  Future<List<Transaksi>> getAllTransaksi() async {
    final db = await database;
    final maps = await db.query('transaksi', orderBy: 'id DESC');
    return maps.map((e) => Transaksi.fromMap(e)).toList();
  }

  Future<List<Transaksi>> getTransaksiByAnggota(int idAnggota) async {
    final db = await database;
    final maps = await db.query(
      'transaksi',
      where: 'idAnggota = ?',
      whereArgs: [idAnggota],
      orderBy: 'id DESC',
    );
    return maps.map((e) => Transaksi.fromMap(e)).toList();
  }

  Future<int> insertTransaksi(Transaksi t) async {
    final db = await database;
    return await db.insert('transaksi', t.toMap());
  }

  Future<int> updateTransaksi(Transaksi t) async {
    final db = await database;
    return await db.update('transaksi', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  // Buku terfavorit (paling sering dipinjam)
  Future<List<Map<String, dynamic>>> getBukuTerfavorit() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT judulBuku, COUNT(*) as jumlah
      FROM transaksi
      GROUP BY judulBuku
      ORDER BY jumlah DESC
      LIMIT 5
    ''');
  }
}