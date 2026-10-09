import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/buku.dart';
import '../../models/transaksi.dart';
import '../../providers/app_provider.dart';

class KatalogBukuScreen extends StatefulWidget {
  const KatalogBukuScreen({super.key});

  @override
  State<KatalogBukuScreen> createState() => _KatalogBukuScreenState();
}

class _KatalogBukuScreenState extends State<KatalogBukuScreen> {
  List<Buku> _all = [];
  List<Buku> _filtered = [];
  String _keyword = '';
  String _kategori = 'Semua';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _all = await context.read<AppProvider>().db.getAllBuku();
    _applyFilter();
    setState(() => _loading = false);
  }

  void _applyFilter() {
    _filtered = _all.where((b) {
      final matchKeyword = b.judul.toLowerCase().contains(_keyword.toLowerCase()) ||
          b.pengarang.toLowerCase().contains(_keyword.toLowerCase());
      final matchKategori = _kategori == 'Semua' || b.kategori == _kategori;
      return matchKeyword && matchKategori;
    }).toList();
  }

  Future<void> _ajukanPinjam(Buku b) async {
    if (b.stok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok buku habis!')),
      );
      return;
    }
    final user = context.read<AppProvider>().currentUser;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajukan Peminjaman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buku: ${b.judul}'),
            Text('Pengarang: ${b.pengarang}'),
            const SizedBox(height: 8),
            const Text('Durasi peminjaman: 7 hari'),
            const SizedBox(height: 8),
            const Text('Pengajuan akan diproses petugas.',
                style: TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ajukan')),
        ],
      ),
    );

    if (confirm == true) {
      final db = context.read<AppProvider>().db;
      final now = DateTime.now();
      final t = Transaksi(
        idBuku: b.id!,
        idAnggota: user!.id!,
        judulBuku: b.judul,
        namaAnggota: user.nama,
        tanggalPinjam: now,
        batasKembali: now.add(const Duration(days: 7)),
        status: 'Menunggu',
      );
      await db.insertTransaksi(t);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan berhasil dikirim!')),
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final kategoriList = ['Semua', ..._all.map((e) => e.kategori).toSet()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Buku'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari judul atau pengarang...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                setState(() {
                  _keyword = v;
                  _applyFilter();
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: kategoriList
                  .map((k) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(k),
                          selected: _kategori == k,
                          onSelected: (_) {
                            setState(() {
                              _kategori = k;
                              _applyFilter();
                            });
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('Buku tidak ditemukan'))
                    : ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final b = _filtered[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal,
                                child: Text(b.judul[0], style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(b.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${b.pengarang} • ${b.penerbit}\n${b.kategori} • Rak ${b.rak} • Stok: ${b.stok}',
                              ),
                              isThreeLine: true,
                              trailing: ElevatedButton(
                                onPressed: b.stok > 0 ? () => _ajukanPinjam(b) : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Pinjam', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}