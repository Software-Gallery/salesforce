# Alur dan API Kunjungan (tambah_kunjungan.dart)

Dokumen ini berisi alur aplikasi dan API yang dijalankan dari setiap tombol pada layar **Tambah Kunjungan**.

## 1. Tombol: Mulai (Check-In)
Tombol ini muncul ketika sales belum memulai kunjungan (jam masuk masih kosong).

### Alur:
1. Menjalankan API `addHeader` untuk membuat header order.
2. Menjalankan API `addAbsen` untuk mencatat kehadiran.
3. Menjalankan API `getCurrentNoVisit` untuk memperbarui status rute di aplikasi.

### API Details:

#### A. Create Sales Order Header
- **Service:** `TrmSalesOrderDetailServices().addHeader()`
- **Endpoint:** `/api/sales-order-header`
- **Method:** `POST`
- **Parameters (Body):**
```json
{
  "id_departemen": 1,
  "id_customer": 123,
  "id_karyawan": 45,
  "keterangan": "Keterangan dari input",
  "tgl_sales_order": "2024-03-06"
}
```
- **Response Data:** `response.data['data']['kode_sales_order']`

#### B. Add Absen (Check-In)
- **Service:** `RuteServices.addAbsen()`
- **Endpoint:** `/api/absen`
- **Method:** `POST`
- **Parameters (Body):**
```json
{
  "id_karyawan": 45,
  "id_customer": 123,
  "id_departemen": 1,
  "tgl": "2024-03-06",
  "jam_masuk": "08:30:00",
  "latitude": "-6.123456",
  "longitude": "106.123456",
  "keterangan": "Keterangan",
  "alamat": "Alamat lokasi saat ini",
  "tipe": "RUTE",
  "kode_sales_order": 789
}
```

---

## 2. Tombol: Kirim (Check-Out / Selesai)
Tombol ini muncul setelah kunjungan dimulai (sales sudah Check-In).

### Alur:
1. Menjalankan API `selesaiAbsen` untuk mencatat jam keluar.
2. Menjalankan API `sendImageToServer` untuk mengunggah foto kunjungan.

### API Details:

#### A. Selesai Absen (Check-Out)
- **Service:** `RuteServices.selesaiAbsen()`
- **Endpoint:** `/api/selesaiabsen`
- **Method:** `POST`
- **Parameters (Body):**
```json
{
  "id_absen": 111,
  "kode_sales_order": 789,
  "keterangan": "Keterangan akhir"
}
```

#### B. Upload Foto Kunjungan
- **Service:** `RuteServices().sendImageToServer()`
- **Endpoint:** `/api/upload-image`
- **Method:** `POST`
- **Content-Type:** `multipart/form-data`
- **Parameters:**
  - `image`: [File]
  - `kode_sales_order`: "789"

---

## 3. Kelola Produk (Cart Actions)

### A. Tambah / Update Produk ke Keranjang
Dijalankan saat menekan tombol **Update** pada modal input quantity.
- **Service:** `TrmSalesOrderDetailServices().addDetail()`
- **Endpoint:** `/api/sales-order-detail/add`
- **Method:** `POST`
- **Parameters (Body):**
```json
{
  "kode_sales_order": 789,
  "id_barang": 10,
  "qty": "1.0.0",
  "disc_cash": 0,
  "disc_perc": 0,
  "ket": "Catatan item",
  "status": "REGULAR"
}
```

### B. Hapus Produk dari Keranjang
Dijalankan saat menekan tombol **Hapus** pada modal.
- **Service:** `BarangService().removeBarangKeranjang()`
- **Endpoint:** `/api/sales-order-detail/delete`
- **Method:** `POST`
- **Parameters (Body):**
```json
{
  "kode_sales_order": 789,
  "id_barang": 10,
  "status": "REGULAR"
}
```

---

## 4. API Pendukung (Background/Auto)

### A. Load Data Keranjang
Dijalankan saat layar dibuka atau setelah update produk.
- **Endpoint:** `/api/keranjang?id={kode_sales_order}` (GET)

### B. Check Status Absen Terakhir
- **Endpoint:** `/api/checkAbsen?id={id_karyawan}` (GET)

### C. Ambil Tanggal Aktif Sales
- **Endpoint:** `/api/customer-rute-tgl-aktif?id={id_karyawan}` (GET)
