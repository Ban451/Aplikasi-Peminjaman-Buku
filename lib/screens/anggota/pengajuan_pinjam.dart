// lib/screens/anggota/pengajuan_pinjam.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaksi.dart';
import '../../providers/app_provider.dart';

class PengajuanPinjamScreen extends StatefulWidget {
  const PengajuanPinjamScreen({super.key});

  @override
  State<PengajuanPinjamScreen> createState() => _PengajuanPinjamScreenState();
}

class _PengajuanPinjamScreenState extends State<PengajuanPinjamScreen> {
  final _judulCtrl = TextEditingController();

  Future<void> _ajukan() async {
    if (_judulCtrl.text.isEmpty) return;
    final user = context.read<AppProvider>().currentUser!;
    final db = context.read<AppProvider>().db;
    final now = DateTime.now();

    await db.insertTransaksi(Transaksi(
      idBuku: 0,
      idAnggota: user.id!,
      judulBuku: _judulCtrl.text,
      namaAnggota: user.nama,
      tanggalPinjam: now,
      batasKembali: now.add(const Duration(days: 7)),
      status: 'Menunggu',
    ));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengajuan berhasil dikirim!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Peminjaman'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul Buku yang Diajukan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Durasi: 7 hari (default)'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _ajukan,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Ajukan', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}