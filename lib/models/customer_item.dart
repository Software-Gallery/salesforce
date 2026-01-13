class CustomerItem {
  final int id;
  final String nama;
  final String alamat;

  CustomerItem({required this.id, required this.nama, required this.alamat});
  factory CustomerItem.fromJson(Map<String, dynamic> json) {
    return CustomerItem(
      id: json['id_customer'],
      nama: json['nama'],
      alamat: json['alamat'],
    );
  }  
}
