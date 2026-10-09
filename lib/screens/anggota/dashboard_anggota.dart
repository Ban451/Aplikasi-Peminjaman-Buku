import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../login_screen.dart';
import 'katalog_buku.dart';
import 'riwayat_pinjam.dart';

class DashboardAnggota extends StatelessWidget {
  const DashboardAnggota({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Anggota'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AppProvider>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.teal.shade50,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text('Halo, ${user?.nama ?? ''}'),
                subtitle: Text('NIS: ${user?.nis} • ${user?.kelas}'),
              ),
            ),
            const SizedBox(height: 20),
            _menu(context, Icons.search, 'Cari & Filter Buku',
                'Telusuri katalog perpustakaan', Colors.blue,
                const KatalogBukuScreen()),
            _menu(context, Icons.book, 'Pengajuan Peminjaman',
                'Ajukan peminjaman buku', Colors.orange,
                const KatalogBukuScreen()),
            _menu(context, Icons.history, 'Riwayat & Pengingat',
                'Lihat riwayat dan batas waktu', Colors.purple,
                const RiwayatPinjamScreen()),
          ],
        ),
      ),
    );
  }

  Widget _menu(BuildContext context, IconData icon, String title, String subtitle,
      Color color, Widget screen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }
}