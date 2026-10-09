import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/buku.dart';
import '../../providers/app_provider.dart';

class KelolaBukuScreen extends StatefulWidget {
  const KelolaBukuScreen({super.key});

  @override
  State<KelolaBukuScreen> createState() => _KelolaBukuScreenState();
}

class _KelolaBukuScreenState extends State<KelolaBukuScreen> {
  List<Buku> _bukuList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final db = context.read<AppProvider>().db;
    _bukuList = await db.getAllBuku();
    setState(() => _loading = false);
  }

  void _showForm({Buku? buku}) {
    final judulCtrl = TextEditingController(text: buku?.judul ?? '');
    final pengarangCtrl = TextEditingController(text: buku?.pengarang ?? '');
    final penerbitCtrl = TextEditingController(text: buku?.penerbit ?? '');
    final kategoriCtrl = TextEditingController(text: buku?.kategori ?? '');
    final stokCtrl = TextEditingController(text: buku?.stok.toString() ?? '');
    final rakCtrl = TextEditingController(text: buku?.rak ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(buku == null ? 'Tambah Buku' : 'Edit Buku'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: judulCtrl, decoration: const InputDecoration(labelText: 'Judul')),
              TextField(controller: pengarangCtrl, decoration: const InputDecoration(labelText: 'Pengarang')),
              TextField(controller: penerbitCtrl, decoration: const InputDecoration(labelText: 'Penerbit')),
              TextField(controller: kategoriCtrl, decoration: const InputDecoration(labelText: 'Kategori')),
              TextField(controller: stokCtrl, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
              TextField(controller: rakCtrl, decoration: const InputDecoration(labelText: 'Rak')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final db = context.read<AppProvider>().db;
              final data = Buku(
                id: buku?.id,
                judul: judulCtrl.text,
                pengarang: pengarangCtrl.text,
                penerbit: penerbitCtrl.text,
                kategori: kategoriCtrl.text,
                stok: int.tryParse(stokCtrl.text) ?? 0,
                rak: rakCtrl.text,
              );
              if (buku == null) {
                await db.insertBuku(data);
              } else {
                await db.updateBuku(data);
              }
              if (!mounted) return;
              Navigator.pop(context);
              _load();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(Buku b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text('Yakin ingin menghapus "${b.judul}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<AppProvider>().db.deleteBuku(b.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Data Buku'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _bukuList.length,
              itemBuilder: (_, i) {
                final b = _bukuList[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.book, color: Colors.white),
                    ),
                    title: Text(b.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${b.pengarang} • ${b.kategori}\nRak ${b.rak} • Stok: ${b.stok}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showForm(buku: b)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(b)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}