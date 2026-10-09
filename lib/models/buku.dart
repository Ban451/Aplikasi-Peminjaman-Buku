class Buku {
  final int? id;
  final String judul;
  final String pengarang;
  final String penerbit;
  final String kategori;
  final int stok;
  final String rak;

  Buku({
    this.id,
    required this.judul,
    required this.pengarang,
    required this.penerbit,
    required this.kategori,
    required this.stok,
    required this.rak,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'pengarang': pengarang,
      'penerbit': penerbit,
      'kategori': kategori,
      'stok': stok,
      'rak': rak,
    };
  }

  factory Buku.fromMap(Map<String, dynamic> map) {
    return Buku(
      id: map['id'],
      judul: map['judul'],
      pengarang: map['pengarang'],
      penerbit: map['penerbit'],
      kategori: map['kategori'],
      stok: map['stok'],
      rak: map['rak'],
    );
  }

  Buku copyWith({
    int? id,
    String? judul,
    String? pengarang,
    String? penerbit,
    String? kategori,
    int? stok,
    String? rak,
  }) {
    return Buku(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      pengarang: pengarang ?? this.pengarang,
      penerbit: penerbit ?? this.penerbit,
      kategori: kategori ?? this.kategori,
      stok: stok ?? this.stok,
      rak: rak ?? this.rak,
    );
  }
}