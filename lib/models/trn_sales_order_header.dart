import 'package:intl/intl.dart';
import 'package:salesforce/models/trn_sales_order_detail.dart';

class TrmSalesOrderHeader {
  final String? kode_sales_order;
  final DateTime tgl_sales_order;
  final int id_departemen;
  final int id_customer;
  final int id_karyawan;
  final String no_ref;
  final DateTime tgl_ref;
  final String keterangan;
  final String status;
  final double total;
  final String nama_customer;
  List<TrmSalesOrderDetail> listDetail;


  TrmSalesOrderHeader({
    required this.kode_sales_order,
    required this.tgl_sales_order,
    required this.id_departemen,
    required this.id_customer,
    required this.id_karyawan,
    required this.no_ref,
    required this.tgl_ref,
    required this.keterangan,
    required this.status,
    required this.total,
    required this.listDetail,
    required this.nama_customer
  });

  factory TrmSalesOrderHeader.fromJson(Map<String, dynamic> json) {
    return TrmSalesOrderHeader(
      kode_sales_order : json['kode_sales_order'],
      tgl_sales_order : DateFormat("yyyy-MM-dd").parse(json['tgl_sales_order']) ,
      id_departemen : json['id_departemen'],
      id_customer : json['id_customer'],
      id_karyawan : json['id_karyawan'],
      no_ref : json['no_ref'],
      tgl_ref : DateFormat("yyyy-MM-dd").parse(json['tgl_ref']) ,
      keterangan : json['keterangan'],
      status : json['status'],
      total : double.parse(json['total']),
      listDetail: [],
      nama_customer: json['nama_customer']
    );
  }
}

final List<TrmSalesOrderHeader> listSalesOrder = [
  TrmSalesOrderHeader(
    kode_sales_order: "SO20251004-001",
    tgl_sales_order: DateTime(2025, 10, 4),
    id_departemen: 1,
    id_customer: 101,
    id_karyawan: 201,
    no_ref: "REF-0001",
    tgl_ref: DateTime(2025, 10, 1),
    keterangan: "Order rutin dari customer A",
    status: "OPEN",
    total: 1500000,
    nama_customer: '',
    listDetail: [
      TrmSalesOrderDetail(
        kode_sales_order: "SO20251004-001",
        id_barang: 1,
        qty_besar: 2,
        qty_tengah: 0,
        qty_kecil: 0,
        harga: 500000,
        disc_cash: 0,
        subtotal: 1000000,
        ket_detail: "2 dus Produk A",
      ),
      TrmSalesOrderDetail(
        kode_sales_order: "SO20251004-001",
        id_barang: 2,
        qty_besar: 1,
        qty_tengah: 0,
        qty_kecil: 0,
        harga: 500000,
        disc_cash: 50000,
        subtotal: 450000,
        ket_detail: "1 dus Produk B, diskon tunai",
      ),
    ],
  ),
  TrmSalesOrderHeader(
    kode_sales_order: "SO20251004-002",
    tgl_sales_order: DateTime(2025, 10, 4),
    id_departemen: 2,
    id_customer: 102,
    id_karyawan: 202,
    no_ref: "REF-0002",
    tgl_ref: DateTime(2025, 9, 30),
    keterangan: "Order pertama dari customer B",
    status: "PROCESSED",
    total: 900000,
    nama_customer: '',
    listDetail: [
      TrmSalesOrderDetail(
        kode_sales_order: "SO20251004-002",
        id_barang: 3,
        qty_besar: 0,
        qty_tengah: 3,
        qty_kecil: 0,
        harga: 300000,
        disc_cash: 0,
        subtotal: 900000,
        ket_detail: "3 pak Produk C",
      ),
    ],
  ),
  TrmSalesOrderHeader(
    kode_sales_order: "SO20251004-003",
    tgl_sales_order: DateTime(2025, 10, 3),
    id_departemen: 1,
    id_customer: 103,
    id_karyawan: 203,
    no_ref: "REF-0003",
    tgl_ref: DateTime(2025, 9, 29),
    keterangan: "Order urgent dari customer C",
    status: "CLOSED",
    total: 2000000,
    nama_customer: '',
    listDetail: [
      TrmSalesOrderDetail(
        kode_sales_order: "SO20251004-003",
        id_barang: 4,
        qty_besar: 0,
        qty_tengah: 0,
        qty_kecil: 20,
        harga: 100000,
        disc_cash: 0,
        subtotal: 2000000,
        ket_detail: "20 pcs Produk D",
      ),
    ],
  ),
];
