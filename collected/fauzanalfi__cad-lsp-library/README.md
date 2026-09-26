# CAD LSP Library

Kumpulan script AutoLISP untuk membantu otomasi pekerjaan di AutoCAD.

## Daftar Script

### 1) CTEXTALL.lsp
Command utama: `CTEXTALL`

Fungsi:
- Menyalin teks dari objek sumber lalu menerapkannya ke banyak objek target.
- Mendukung objek teks seperti TEXT, MTEXT, ATTRIB/ATTDEF, DIMENSION, MULTILEADER, dan atribut pada block INSERT.
- Memiliki error handling dan undo mark agar proses lebih aman.

Alur singkat:
1. Jalankan command `CTEXTALL`.
2. Masukkan teks baru, atau kosongkan input untuk mengambil teks dari objek sumber.
3. Klik objek-objek target untuk diubah.
4. Tekan Enter untuk selesai.

### 2) EXPLODETOTAL.lsp
Command utama: `EXPLODETOTAL`

Command tambahan:
- `EXPLODETOTALSAFE` (mode aman)

Fungsi:
- Melakukan bind XRef top-level.
- Mengeksekusi explode block secara menyeluruh dengan pendekatan ActiveX.
- Membuka lock semua layer sebelum proses.
- Menjalankan purge definisi block (khusus `EXPLODETOTAL`).

Perbedaan mode:
- `EXPLODETOTAL`: Mode penuh, termasuk pembersihan/purge.
- `EXPLODETOTALSAFE`: Mode lebih aman untuk menjaga elemen tertentu (misalnya anotasi) dan tanpa purge agresif.

## Cara Pakai

1. Buka AutoCAD.
2. Ketik `APPLOAD`.
3. Pilih file LSP yang ingin digunakan (`CTEXTALL.lsp` atau `EXPLODETOTAL.lsp`).
4. Jalankan command sesuai kebutuhan:
- `CTEXTALL`
- `EXPLODETOTAL`
- `EXPLODETOTALSAFE`

## Struktur Repository

- `CTEXTALL.lsp`
- `EXPLODETOTAL.lsp`

## Catatan

- Disarankan menyimpan backup drawing sebelum menjalankan proses explode massal.
- Untuk project besar, gunakan `EXPLODETOTALSAFE` terlebih dahulu untuk verifikasi hasil.

## Lisensi

Belum ditentukan. Tambahkan informasi lisensi sesuai kebutuhan project.
