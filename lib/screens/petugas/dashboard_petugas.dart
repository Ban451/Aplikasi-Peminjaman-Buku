import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../login_screen.dart';
import 'kelola_buku.dart';
import 'kelola_anggota.dart';
import 'sirkulasi.dart';
import 'laporan.dart';

class DashboardPetugas extends StatelessWidget {
  const DashboardPetugas({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Petugas'),
        backgroundColor: Colors.indigo,
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
              color: Colors.indigo.shade50,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text('Selamat datang, ${user?.nama ?? ''}'),
                subtitle: const Text('Petugas Perpustakaan'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Menu Utama',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _menuCard(context, Icons.book, 'Kelola Buku', Colors.blue,
                    const KelolaBukuScreen()),
                _menuCard(context, Icons.people, 'Kelola Anggota', Colors.green,
                    const KelolaAnggotaScreen()),
                _menuCard(context, Icons.swap_horiz, 'Sirkulasi', Colors.orange,
                    const SirkulasiScreen()),
                _menuCard(context, Icons.bar_chart, 'Laporan', Colors.purple,
                    const LaporanScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, IconData icon, String title,
      Color color, Widget screen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => screen)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}