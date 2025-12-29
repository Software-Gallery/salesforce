import 'package:intl/intl.dart';

class RuteItem {
  final int id_departemen;
  final int id_customer;
  final int id_karyawan;
  final int day1;
  final int day2;
  final int day3;
  final int day4;
  final int day5;
  final int day6;
  final int day7;
  final int week_ganjil;
  final int week_genap;
  final String nama_customer;
  final String nama_departemen;
  final String kode_sales_order;
  final String tgl;
  final String jam_masuk;
  final String jam_keluar;
  final double latitude;
  final double longitude;
  final String keterangan;
  final String alamat;
  final int id_absen;
  final int week;
  final DateTime tgl_aktif;
  final String tipe;
  final String status;
  final String kode_customer;
  final String latlong_customer;
  final String alamat_customer;
  final int jumlah_nota;  
  final int value_nota;  
  final int sisa_piutang;  
  final int jml_absen;  
  final double totalSKU;  
  final double totalValue;  

  RuteItem({
  required this.id_departemen,
  required this.id_customer,
  required this.id_karyawan,
  required this.day1,
  required this.day2,
  required this.day3,
  required this.day4,
  required this.day5,
  required this.day6,
  required this.day7,
  required this.week_ganjil,
  required this.week_genap,
  required this.nama_customer,
  required this.nama_departemen,
  required this.kode_sales_order,
  required this.tgl,
  required this.jam_masuk,
  required this.jam_keluar,
  required this.latitude,
  required this.longitude,
  required this.keterangan,
  required this.alamat,
  required this.id_absen,
  required this.week,
  required this.tgl_aktif,
  required this.tipe,
  required this.status,
  required this.kode_customer,
  required this.latlong_customer,
  required this.alamat_customer,
  required this.jumlah_nota, 
  required this.value_nota,  
  required this.sisa_piutang,
  required this.jml_absen,
  required this.totalSKU,
  required this.totalValue
  });

  factory RuteItem.fromJson(Map<String, dynamic> json) {
    if (json['totalSKU'] is int) json['totalSKU'] = json['totalSKU'].toDouble();    
    if (json['totalValue'] is int) json['totalValue'] = json['totalValue'].toDouble();    
    return RuteItem(
      id_departemen: json['id_departemen'],
      id_customer: json['id_customer'],
      id_karyawan: json['id_karyawan'],
      day1: json['day1'] ?? -1,
      day2: json['day2'] ?? -1,
      day3: json['day3'] ?? -1,
      day4: json['day4'] ?? -1,
      day5: json['day5'] ?? -1,
      day6: json['day6'] ?? -1,
      day7: json['day7'] ?? -1,
      week_ganjil: json['week_ganjil'] ?? -1,
      week_genap: json['week_genap'] ?? -1,
      nama_customer: json['nama_customer'],
      nama_departemen: json['nama_departemen'],
      kode_sales_order: json['kode_sales_order'] ?? '',
      tgl: json['tgl'] ?? '',
      jam_masuk: json['jam_masuk'] ?? '',
      jam_keluar: json['jam_keluar'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) ?? 0.00 : 0.00,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) ?? 0.00 : 0.00,
      keterangan: json['keterangan'] ?? '',
      alamat: json['alamat'] ?? '',
      id_absen: json['id_absen'] ?? -1,
      week: json['week'] ?? -1,
      tipe: json['tipe'] ?? '',
      status: json['status'] ?? '',
      tgl_aktif : json['tgl_aktif'] == null ? DateTime.now() : DateFormat("yyyy-MM-dd").parse(json['tgl_aktif']),
      kode_customer: json['kode_customer'] ?? '',
      latlong_customer: json['latlong_customer'] ?? '',
      alamat_customer: json['alamat_customer'] ?? '',
      jumlah_nota: json['jml_nota'] ?? 0,
      value_nota: json['value_nota'] ?? 0,
      sisa_piutang: json['sisa_piutang'] ?? 0,
      jml_absen: json['jml_absen'] ?? 0,
      totalSKU: json['totalSKU'] ?? 0,
      totalValue: json['totalValue'] ?? 0,
    );
  }
}

List<RuteItem> ruteList = [
  RuteItem(
    id_departemen: 1,
    id_customer: 1001,
    id_karyawan: 2001,
    day1: 1,
    day2: 0,
    day3: 1,
    day4: 0,
    day5: 1,
    day6: 0,
    day7: 1,
    week_ganjil: 1,
    week_genap: 0,
    nama_customer: 'Customer A',
    nama_departemen: 'Dept A',
    kode_sales_order: 'SO12345',
    tgl: '2025-10-17',
    jam_masuk: '08:00',
    jam_keluar: '17:00',
    latitude: -6.200000,
    longitude: 106.800000,
    keterangan: 'Visit for sales',
    alamat: 'Jl. ABC No. 123',
    id_absen: 3001,
    week: -1,
    tgl_aktif: DateTime.now(),
    tipe: '',
    status: '',
    kode_customer: '00001',
    latlong_customer: '700, 800',
    alamat_customer: '',
    jumlah_nota: 0,
    value_nota: 0,
    sisa_piutang: 0,
    jml_absen: 0,
    totalSKU: 0,
    totalValue: 0
  ),
];
