class BarangItem {
  final int? id_barang;
  final String kode_barang;
  final int id_departemen;
  final String nama_barang;
  final int satuan_besar;
  final int satuan_tengah;
  final int satuan_kecil;
  final int konversi_besar;
  final int konversi_tengah;
  final String gambar;
  final int is_aktif;


  BarangItem({
    required this.id_barang,
    required this.kode_barang,
    required this.id_departemen,
    required this.nama_barang,
    required this.satuan_besar,
    required this.satuan_tengah,
    required this.satuan_kecil,
    required this.konversi_besar,
    required this.konversi_tengah,
    required this.gambar,
    required this.is_aktif,    
  });

  factory BarangItem.fromJson(Map<String, dynamic> json) {
    return BarangItem(
      id_barang : json['id_barang'],
      kode_barang : json['kode_barang'],
      id_departemen : json['id_departemen'],
      nama_barang : json['nama_barang'],
      satuan_besar : json['satuan_besar'],
      satuan_tengah : json['satuan_tengah'],
      satuan_kecil : json['satuan_kecil'],
      konversi_besar : json['konversi_besar'],
      konversi_tengah : json['konversi_tengah'],
      gambar : json['gambar'],
      is_aktif : json['is_aktif'],
    );
  }
}
