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
  final double harga;
  double qty_besar;
  double qty_tengah;
  double qty_kecil;
  double disc_cash;
  double disc_perc;
  String ket_detail;
  double subtotal;
  double total;
  final String status;

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
    required this.harga,    
    required this.qty_besar,
    required this.qty_tengah,
    required this.qty_kecil,
    required this.disc_cash,
    required this.disc_perc,
    required this.ket_detail,
    required this.subtotal,
    required this.total,
    required this.status
  });

  factory BarangItem.fromJson(Map<String, dynamic> json) {
    if (json['harga'] is int) {
      // Jika harga bertipe int, ubah menjadi double
      json['harga'] = json['harga'].toDouble();
    }
    if (json['satuan_kecil'] is double) json['satuan_kecil'] = json['satuan_kecil'].toInt();
    if (json['satuan_tengah'] is double) json['satuan_tengah'] = json['satuan_tengah'].toInt();
    if (json['satuan_besar'] is double) json['satuan_besar'] = json['satuan_besar'].toInt();
    if (json['konversi_besar'] is double) json['konversi_besar'] = json['konversi_besar'].toInt();
    if (json['konversi_tengah'] is double) json['konversi_tengah'] = json['konversi_tengah'].toInt();
    // if (json['qty'] is int) json['qty'] = json['qty'].toDouble();
    if (json['qty_besar'] is int) json['qty_besar'] = json['qty_besar'].toDouble();
    if (json['qty_tengah'] is int) json['qty_tengah'] = json['qty_tengah'].toDouble();
    if (json['qty_kecil'] is int) json['qty_kecil'] = json['qty_kecil'].toDouble();
    if (json['disc_cash'] is int) json['disc_cash'] = json['disc_cash'].toDouble();
    if (json['disc_perc'] is int) json['disc_perc'] = json['disc_perc'].toDouble();
    if (json['subtotal'] is int) json['subtotal'] = json['subtotal'].toDouble();
    if (json['total'] is int) json['total'] = json['total'].toDouble();
    if (json['status'] == null) json['status'] = '';
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
      gambar : json['gambar'] ?? '',
      is_aktif : json['is_aktif'],
      harga : json['harga'],
      qty_besar : json['qty_besar'] ?? 0,
      qty_tengah : json['qty_tengah'] ?? 0,
      qty_kecil : json['qty_kecil'] ?? 0,
      disc_cash : json['disc_cash'] ?? 0,
      disc_perc : json['disc_perc'] ?? 0,
      ket_detail : json['ket_detail'] ?? '',
      subtotal : json['subtotal'] ?? 0,
      total : json['total'] ?? 0,
      status: json['status']
    );
  }
}

List<BarangItem> barangList = [
  BarangItem(
    id_barang: 1,
    kode_barang: 'B001',
    id_departemen: 101,
    nama_barang: 'Barang A',
    satuan_besar: 10,
    satuan_tengah: 5,
    satuan_kecil: 1,
    konversi_besar: 100,
    konversi_tengah: 10,
    gambar: 'not-found.png',
    is_aktif: 1,
    harga: 90000,
    qty_besar: 0,
    qty_tengah: 0,
    qty_kecil: 0,
    disc_cash: 0,
    disc_perc: 0,
    ket_detail: '',
    subtotal: 0,
    total: 0,
    status: ''
  ),
  BarangItem(
    id_barang: 2,
    kode_barang: 'B002',
    id_departemen: 102,
    nama_barang: 'Barang B',
    satuan_besar: 20,
    satuan_tengah: 10,
    satuan_kecil: 2,
    konversi_besar: 200,
    konversi_tengah: 20,
    gambar: 'not-found.png',
    is_aktif: 1,
    harga: 120000,
    qty_besar: 0,
    qty_tengah: 0,
    qty_kecil: 0,
    disc_cash: 0,
    disc_perc: 0,
    ket_detail: '',
    subtotal: 0,
    total: 0,
    status: ''
  ),
  BarangItem(
    id_barang: 3,
    kode_barang: 'B003',
    id_departemen: 103,
    nama_barang: 'Barang C',
    satuan_besar: 30,
    satuan_tengah: 15,
    satuan_kecil: 3,
    konversi_besar: 300,
    konversi_tengah: 30,
    gambar: 'not-found.png',
    is_aktif: 0,
    harga: 98000,
    qty_besar: 0,
    qty_tengah: 0,
    qty_kecil: 0,
    disc_cash: 0,
    disc_perc: 0,
    ket_detail: '',
    subtotal: 0,
    total: 0,
    status: ''
  ),
  BarangItem(
    id_barang: 3,
    kode_barang: 'B003',
    id_departemen: 103,
    nama_barang: 'Barang C',
    satuan_besar: 30,
    satuan_tengah: 15,
    satuan_kecil: 3,
    konversi_besar: 300,
    konversi_tengah: 30,
    gambar: 'not-found.png',
    is_aktif: 0,
    harga: 98000,
    qty_besar: 0,
    qty_tengah: 0,
    qty_kecil: 0,
    disc_cash: 0,
    disc_perc: 0,
    ket_detail: '',
    subtotal: 0,
    total: 0,
    status: ''
  ),
  BarangItem(
    id_barang: 3,
    kode_barang: 'B003',
    id_departemen: 103,
    nama_barang: 'Barang C',
    satuan_besar: 30,
    satuan_tengah: 15,
    satuan_kecil: 3,
    konversi_besar: 300,
    konversi_tengah: 30,
    gambar: 'not-found.png',
    is_aktif: 0,
    harga: 98000,
    qty_besar: 0,
    qty_tengah: 0,
    qty_kecil: 0,
    disc_cash: 0,
    disc_perc: 0,
    ket_detail: '',
    subtotal: 0,
    total: 0,
    status: ''
  ),
  BarangItem(
    id_barang: 3,
    kode_barang: 'B003',
    id_departemen: 103,
    nama_barang: 'Barang C',
    satuan_besar: 30,
    satuan_tengah: 15,
    satuan_kecil: 3,
    konversi_besar: 300,
    konversi_tengah: 30,
    gambar: 'not-found.png',
    is_aktif: 0,
    harga: 98000,
    qty_besar: 0,
    qty_tengah: 0,
    qty_kecil: 0,
    disc_cash: 0,
    disc_perc: 0,
    ket_detail: '',
    subtotal: 0,
    total: 0,
    status: ''
  ),
];
