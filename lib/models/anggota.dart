class Anggota {
  final int? id;
  final String nama;
  final String nis;
  final String kelas;
  final String username;
  final String password;
  final String role; // 'petugas' atau 'anggota'

  Anggota({
    this.id,
    required this.nama,
    required this.nis,
    required this.kelas,
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'nis': nis,
      'kelas': kelas,
      'username': username,
      'password': password,
      'role': role,
    };
  }

  factory Anggota.fromMap(Map<String, dynamic> map) {
    return Anggota(
      id: map['id'],
      nama: map['nama'],
      nis: map['nis'],
      kelas: map['kelas'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
    );
  }
}