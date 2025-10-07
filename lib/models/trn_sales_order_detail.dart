class TrmSalesOrderDetail {
  final String? kode_sales_order;
  final int id_barang;
  final int qty_besar;
  final int qty_tengah;
  final int qty_kecil;
  final int harga;
  final int disc_cash;
  final int subtotal;
  final String ket_detail;


  TrmSalesOrderDetail({
    required this.kode_sales_order,
    required this.id_barang,
    required this.qty_besar,
    required this.qty_tengah,
    required this.qty_kecil,
    required this.harga,
    required this.disc_cash,
    required this.subtotal,
    required this.ket_detail,
  });

  factory TrmSalesOrderDetail.fromJson(Map<String, dynamic> json) {
    return TrmSalesOrderDetail(
      kode_sales_order: json['kode_sales_order'],
      id_barang: json['id_barang'],
      qty_besar: json['qty_besar'],
      qty_tengah: json['qty_tengah'],
      qty_kecil: json['qty_kecil'],
      harga: json['harga'],
      disc_cash: json['disc_cash'],
      subtotal: json['subtotal'],
      ket_detail: json['ket_detail'],
    );
  }
}
