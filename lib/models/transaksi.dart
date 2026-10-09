class Transaksi {
  final int? id;
  final int idBuku;
  final int idAnggota;
  final String judulBuku;
  final String namaAnggota;
  final DateTime tanggalPinjam;
  final DateTime batasKembali;
  final DateTime? tanggalKembali;
  final String status; // 'Dipinjam', 'Dikembalikan', 'Menunggu'
  final double denda;

  Transaksi({
    this.id,
    required this.idBuku,
    required this.idAnggota,
    required this.judulBuku,
    required this.namaAnggota,
    required this.tanggalPinjam,
    required this.batasKembali,
    this.tanggalKembali,
    required this.status,
    this.denda = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idBuku': idBuku,
      'idAnggota': idAnggota,
      'judulBuku': judulBuku,
      'namaAnggota': namaAnggota,
      'tanggalPinjam': tanggalPinjam.toIso8601String(),
      'batasKembali': batasKembali.toIso8601String(),
      'tanggalKembali': tanggalKembali?.toIso8601String(),
      'status': status,
      'denda': denda,
    };
  }

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'],
      idBuku: map['idBuku'],
      idAnggota: map['idAnggota'],
      judulBuku: map['judulBuku'],
      namaAnggota: map['namaAnggota'],
      tanggalPinjam: DateTime.parse(map['tanggalPinjam']),
      batasKembali: DateTime.parse(map['batasKembali']),
      tanggalKembali: map['tanggalKembali'] != null
          ? DateTime.parse(map['tanggalKembali'])
          : null,
      status: map['status'],
      denda: (map['denda'] as num).toDouble(),
    );
  }

  // Hitung denda otomatis: Rp 1.000/hari keterlambatan
  static double hitungDenda(DateTime batasKembali, DateTime tanggalKembali) {
    final selisih = tanggalKembali.difference(batasKembali).inDays;
    if (selisih > 0) {
      return selisih * 1000.0;
    }
    return 0;
  }
}