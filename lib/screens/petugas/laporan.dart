import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/transaksi.dart';
import '../../providers/app_provider.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  List<Transaksi> _list = [];
  List<Map<String, dynamic>> _favorit = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final db = context.read<AppProvider>().db;
    _list = await db.getAllTransaksi();
    _favorit = await db.getBukuTerfavorit();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final total = _list.length;
    final dipinjam = _list.where((t) => t.status == 'Dipinjam').length;
    final dikembalikan = _list.where((t) => t.status == 'Dikembalikan').length;
    final totalDenda = _list.fold<double>(0, (sum, t) => sum + t.denda);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Rekapitulasi'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Ringkasan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _statCard('Total Transaksi', '$total', Colors.blue, Icons.list)),
                    const SizedBox(width: 8),
                    Expanded(child: _statCard('Dipinjam', '$dipinjam', Colors.orange, Icons.book)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _statCard('Dikembalikan', '$dikembalikan', Colors.green, Icons.check_circle)),
                    const SizedBox(width: 8),
                    Expanded(child: _statCard('Total Denda', 'Rp ${totalDenda.toStringAsFixed(0)}', Colors.red, Icons.money)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Buku Terfavorit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (_favorit.isEmpty)
                  const Card(child: ListTile(title: Text('Belum ada data')))
                else
                  ..._favorit.asMap().entries.map((e) {
                    final idx = e.key + 1;
                    final data = e.value;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: idx == 1 ? Colors.amber : Colors.grey,
                          child: Text('$idx', style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(data['judulBuku']),
                        trailing: Text('${data['jumlah']}x dipinjam',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
              ],
            ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}