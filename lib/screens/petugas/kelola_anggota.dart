import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/anggota.dart';
import '../../providers/app_provider.dart';

class KelolaAnggotaScreen extends StatefulWidget {
  const KelolaAnggotaScreen({super.key});

  @override
  State<KelolaAnggotaScreen> createState() => _KelolaAnggotaScreenState();
}

class _KelolaAnggotaScreenState extends State<KelolaAnggotaScreen> {
  List<Anggota> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _list = await context.read<AppProvider>().db.getAllAnggota();
    setState(() => _loading = false);
  }

  void _showForm({Anggota? anggota}) {
    final namaCtrl = TextEditingController(text: anggota?.nama ?? '');
    final nisCtrl = TextEditingController(text: anggota?.nis ?? '');
    final kelasCtrl = TextEditingController(text: anggota?.kelas ?? '');
    final userCtrl = TextEditingController(text: anggota?.username ?? '');
    final passCtrl = TextEditingController(text: anggota?.password ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(anggota == null ? 'Tambah Anggota' : 'Edit Anggota'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama')),
              TextField(controller: nisCtrl, decoration: const InputDecoration(labelText: 'NIS')),
              TextField(controller: kelasCtrl, decoration: const InputDecoration(labelText: 'Kelas')),
              TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'Username')),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final db = context.read<AppProvider>().db;
              final data = Anggota(
                id: anggota?.id,
                nama: namaCtrl.text,
                nis: nisCtrl.text,
                kelas: kelasCtrl.text,
                username: userCtrl.text,
                password: passCtrl.text,
                role: 'anggota',
              );
              if (anggota == null) {
                await db.insertAnggota(data);
              } else {
                await db.updateAnggota(data);
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

  Future<void> _delete(Anggota a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Anggota'),
        content: Text('Yakin ingin menghapus "${a.nama}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<AppProvider>().db.deleteAnggota(a.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Data Anggota'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _list.length,
              itemBuilder: (_, i) {
                final a = _list[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(a.nama[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(a.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('NIS: ${a.nis} • Kelas: ${a.kelas}\nUsername: ${a.username}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showForm(anggota: a)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(a)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}