import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/transaksi.dart';
import '../../providers/app_provider.dart';

class RiwayatPinjamScreen extends StatefulWidget {
  const RiwayatPinjamScreen({super.key});

  @override
  State<RiwayatPinjamScreen> createState() => _RiwayatPinjamScreenState();
}

class _RiwayatPinjamScreenState extends State<RiwayatPinjamScreen> {
  List<Transaksi> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final user = context.read<AppProvider>().currentUser;
    _list = await context.read<AppProvider>().db.getTransaksiByAnggota(user!.id!);
    setState(() => _loading = false);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Dipinjam':
        return Colors.orange;
      case 'Dikembalikan':
        return Colors.green;
      case 'Menunggu':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat & Pengingat'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(child: Text('Belum ada riwayat peminjaman'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _list.length,
                  itemBuilder: (_, i) {
                    final t = _list[i];
                    final selisihHari = t.batasKembali.difference(DateTime.now()).inDays;
                    final perluPengingat =
                        t.status == 'Dipinjam' && selisihHari <= 2;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _statusColor(t.status),
                              child: Icon(
                                t.status == 'Dipinjam'
                                    ? Icons.book
                                    : t.status == 'Dikembalikan'
                                        ? Icons.check
                                        : Icons.hourglass_top,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(t.judulBuku,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: ${t.status}',
                                    style: TextStyle(
                                        color: _statusColor(t.status),
                                        fontWeight: FontWeight.bold)),
                                Text('Pinjam: ${DateFormat('dd/MM/yyyy').format(t.tanggalPinjam)}'),
                                Text('Batas: ${DateFormat('dd/MM/yyyy').format(t.batasKembali)}'),
                                if (t.tanggalKembali != null)
                                  Text('Kembali: ${DateFormat('dd/MM/yyyy').format(t.tanggalKembali!)}'),
                                if (t.denda > 0)
                                  Text('Denda: Rp ${t.denda.toStringAsFixed(0)}',
                                      style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                          if (perluPengingat)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selisihHari < 0
                                          ? 'TERLAMBAT ${-selisihHari} hari! Segera kembalikan.'
                                          : 'Pengingat: ${selisihHari} hari lagi batas pengembalian.',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}