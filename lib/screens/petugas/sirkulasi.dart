import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/anggota.dart';
import '../../models/buku.dart';
import '../../models/transaksi.dart';
import '../../providers/app_provider.dart';

class SirkulasiScreen extends StatefulWidget {
  const SirkulasiScreen({super.key});

  @override
  State<SirkulasiScreen> createState() => _SirkulasiScreenState();
}

class _SirkulasiScreenState extends State<SirkulasiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Transaksi> _transaksi = [];
  List<Buku> _buku = [];
  List<Anggota> _anggota = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final db = context.read<AppProvider>().db;
    _transaksi = await db.getAllTransaksi();
    _buku = await db.getAllBuku();
    _anggota = await db.getAllAnggota();
    setState(() => _loading = false);
  }

  Future<void> _pinjam() async {
    Buku? selectedBuku;
    Anggota? selectedAnggota;
    int durasi = 7;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Transaksi Peminjaman'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Anggota>(
                  decoration: const InputDecoration(labelText: 'Pilih Anggota'),
                  items: _anggota
                      .map((a) => DropdownMenuItem(value: a, child: Text('${a.nama} (${a.nis})')))
                      .toList(),
                  onChanged: (v) => setSt(() => selectedAnggota = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Buku>(
                  decoration: const InputDecoration(labelText: 'Pilih Buku'),
                  items: _buku
                      .where((b) => b.stok > 0)
                      .map((b) => DropdownMenuItem(value: b, child: Text('${b.judul} (Stok: ${b.stok})')))
                      .toList(),
                  onChanged: (v) => setSt(() => selectedBuku = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Durasi Pinjam (hari)'),
                  value: durasi,
                  items: [3, 7, 14, 30]
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e hari')))
                      .toList(),
                  onChanged: (v) => setSt(() => durasi = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (selectedBuku == null || selectedAnggota == null) return;
                final db = context.read<AppProvider>().db;
                final now = DateTime.now();
                final t = Transaksi(
                  idBuku: selectedBuku!.id!,
                  idAnggota: selectedAnggota!.id!,
                  judulBuku: selectedBuku!.judul,
                  namaAnggota: selectedAnggota!.nama,
                  tanggalPinjam: now,
                  batasKembali: now.add(Duration(days: durasi)),
                  status: 'Dipinjam',
                );
                await db.insertTransaksi(t);
                await db.updateBuku(selectedBuku!.copyWith(stok: selectedBuku!.stok - 1));
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _load();
              },
              child: const Text('Pinjam'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _kembalikan(Transaksi t) async {
    final now = DateTime.now();
    final denda = Transaksi.hitungDenda(t.batasKembali, now);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Pengembalian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buku: ${t.judulBuku}'),
            Text('Peminjam: ${t.namaAnggota}'),
            Text('Batas Kembali: ${DateFormat('dd/MM/yyyy').format(t.batasKembali)}'),
            Text('Tanggal Kembali: ${DateFormat('dd/MM/yyyy').format(now)}'),
            const Divider(),
            Text(
              'Denda: Rp ${denda.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: denda > 0 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Konfirmasi')),
        ],
      ),
    );
    if (confirm == true) {
      final db = context.read<AppProvider>().db;
      final updated = Transaksi(
        id: t.id,
        idBuku: t.idBuku,
        idAnggota: t.idAnggota,
        judulBuku: t.judulBuku,
        namaAnggota: t.namaAnggota,
        tanggalPinjam: t.tanggalPinjam,
        batasKembali: t.batasKembali,
        tanggalKembali: now,
        status: 'Dikembalikan',
        denda: denda,
      );
      await db.updateTransaksi(updated);
      // Kembalikan stok
      final buku = _buku.firstWhere((b) => b.id == t.idBuku);
      await db.updateBuku(buku.copyWith(stok: buku.stok + 1));
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dipinjam = _transaksi.where((t) => t.status == 'Dipinjam').toList();
    final selesai = _transaksi.where((t) => t.status == 'Dikembalikan').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sirkulasi'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Dipinjam (${dipinjam.length})'),
            Tab(text: 'Selesai (${selesai.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pinjam,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: const Text('Pinjam'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [
                _buildList(dipinjam, true),
                _buildList(selesai, false),
              ],
            ),
    );
  }

  Widget _buildList(List<Transaksi> list, bool isDipinjam) {
    if (list.isEmpty) {
      return const Center(child: Text('Tidak ada data'));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final t = list[i];
        final terlambat = isDipinjam && DateTime.now().isAfter(t.batasKembali);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: terlambat ? Colors.red : (isDipinjam ? Colors.orange : Colors.green),
              child: Icon(isDipinjam ? Icons.book : Icons.check, color: Colors.white),
            ),
            title: Text(t.judulBuku, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Peminjam: ${t.namaAnggota}'),
                Text('Pinjam: ${DateFormat('dd/MM/yyyy').format(t.tanggalPinjam)}'),
                Text(
                  isDipinjam
                      ? 'Batas: ${DateFormat('dd/MM/yyyy').format(t.batasKembali)}${terlambat ? " (TERLAMBAT)" : ""}'
                      : 'Kembali: ${DateFormat('dd/MM/yyyy').format(t.tanggalKembali!)}',
                  style: TextStyle(color: terlambat ? Colors.red : null),
                ),
                if (t.denda > 0)
                  Text('Denda: Rp ${t.denda.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            isThreeLine: true,
            trailing: isDipinjam
                ? ElevatedButton(
                    onPressed: () => _kembalikan(t),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Kembalikan', style: TextStyle(color: Colors.white, fontSize: 12)),
                  )
                : null,
          ),
        );
      },
    );
  }
}