# Tubes-AI-Kelompok7

## Deskripsi
Proyek ini merupakan tugas akhir mata kuliah *Artificial Intelligence* untuk kelompok 7. Implementasi ini menggunakan Godot Engine untuk membuat visualisasi algoritma A* (A-star) dalam game atau simulasi.

## Fitur
- Implementasi algoritma pencarian jalur A*.
- Visualisasi langkah‑langkah pencarian secara real‑time.
- Kontrol interaktif untuk mengatur titik mulai dan tujuan.
- Dukungan export ke berbagai platform melalui Godot.

## Algoritma Pencarian NPC
NPC (Non‑Player Character) dapat mencari jalur terpendek pada grid menggunakan beberapa algoritma:

### Uniform Cost Search (UCS)
Varian Dijkstra yang memperluas node dengan biaya kumulatif terendah terlebih dahulu. Tidak memerlukan heuristik, memastikan solusi optimal bila semua biaya sisi non‑negatif.

### A* Search
Menggabungkan keunggulan UCS dengan heuristik. Nilai f = g + h, dimana **g** adalah biaya dari start ke node saat ini, dan **h** adalah perkiraan biaya ke tujuan.

## Heuristik yang Digunakan
Pengguna dapat memilih tipe heuristik melalui inspector Godot (variabel `HeuristicType` di `Pathfinder.gd`):

- **Manhattan Distance**: `h = |x1 - x2| + |y1 - y2|` – cocok untuk gerakan empat arah.
- **Euclidean Distance**: `h = sqrt((x1 - x2)^2 + (y1 - y2)^2)` – untuk gerakan bebas arah.
- **Diagonal Distance**: `h = max(|dx|, |dy|)` – kombinasi Manhattan dan Euclidean, cocok untuk gerakan delapan arah.
- **Chebyshev Distance**: `h = max(|dx|, |dy|)` – secara khusus memperhitungkan gerakan diagonal seperti gerakan Raja pada catur, memberikan estimasi yang cepat dan admissible bila diagonal diizinkan.

## Cara Kerja dalam Godot
1. **Node Grid**: Dibangun dari TileMap, setiap tile menjadi node dengan koordinat `(x, y)`.
2. **Pathfinder.gd**: Skrip utama yang mengimplementasikan UCS dan A* menggunakan `PriorityQueue`.
3. **Pemilihan Algoritma**: Pada inspector, pilih `SearchAlgorithm` (UCS atau A*) dan, bila A* dipilih, pilih `Heuristic` (termasuk Chebyshev).
4. **Visualisasi**: Node yang sedang diproses ditandai biru, jalur akhir berwarna hijau.

## Cara Menjalankan
1. Pastikan **Godot Engine** versi 4.x sudah terpasang.
2. Buka proyek dengan menjalankan `godot` pada folder proyek atau buka `project.godot` melalui UI Godot.
3. Jalankan scene utama yang berada di dalam folder `Scenes`.

## Instalasi
- **Godot Engine**: Unduh dari https://godotengine.org/download
- Tidak ada dependensi tambahan karena semua skrip berada di dalam folder `Scripts`.

## Kontribusi
Jika ingin berkontribusi, lakukan fork repository ini, buat branch baru, dan ajukan *pull request*.

## Kontak
Kelompok 7 - Universitas XYZ

## Lisensi
Proyek ini dilisensikan di bawah **MIT License**. Lihat file `LICENSE` untuk detail lebih lanjut.

## Deskripsi
Proyek ini merupakan tugas akhir mata kuliah *Artificial Intelligence* untuk kelompok 7. Implementasi ini menggunakan Godot Engine untuk membuat visualisasi algoritma A* (A-star) dalam game atau simulasi.

## Fitur
- Implementasi algoritma pencarian jalur A*.
- Visualisasi langkah-langkah pencarian secara real-time.
- Kontrol interaktif untuk mengatur titik mulai dan tujuan.
- Dukungan export ke berbagai platform melalui Godot.

## Algoritma Pencarian NPC
NPC (Non-Player Character) dalam proyek ini dapat mencari jalur terpendek antara dua titik pada grid menggunakan beberapa algoritma pencarian:

### Uniform Cost Search (UCS)
UCS adalah varian Dijkstra yang selalu memperluas node dengan biaya kumulatif terendah terlebih dahulu. Algoritma ini tidak memerlukan fungsi heuristik, sehingga selalu menemukan jalur optimal bila semua biaya sisi non‑negatif. Pada implementasinya, setiap langkah bergerak ke empat arah (atas, bawah, kiri, kanan) dengan biaya 1.

### A* Search
A* menggabungkan keunggulan UCS dengan heuristik. Pada setiap node, nilai f = g + h dihitung, dimana:
- **g**: biaya dari titik awal ke node saat ini.
- **h**: estimasi biaya dari node ke tujuan (heuristik).
Node dengan f terendah dipilih untuk diekspansi. Dengan heuristik yang admissible (tidak melebihi biaya nyata), A* menjamin solusi optimal dan biasanya jauh lebih cepat daripada UCS.

### Heuristik yang Digunakan
Proyek menyediakan beberapa fungsi heuristik yang dapat dipilih melalui Inspector Godot:
- **Manhattan Distance**: `h = |x1 - x2| + |y1 - y2|`. Cocok untuk gerakan 4‑arah.
- **Euclidean Distance**: `h = sqrt((x1 - x2)^2 + (y1 - y2)^2)`. Digunakan bila gerakan diagonal diizinkan.
- **Diagonal Distance**: Kombinasi Manhattan dan Euclidean untuk gerakan 8‑arah: `h = max(|dx|, |dy|)`.
Pengguna dapat mengatur tipe heuristik pada script `Pathfinder.gd` melalui variabel enum `HeuristicType`.

### Cara Kerja dalam Godot
1. **Node Grid**: Grid dibangun dari tilemap, setiap tile menjadi node dengan posisi `(x, y)`.
2. **Pathfinder.gd**: Skrip utama yang mengimplementasikan UCS dan A*. Menggunakan struktur data `PriorityQueue` untuk frontier.
3. **Pemilihan Algoritma**: Pada inspector, pilih `SearchAlgorithm` (UCS atau A*). Jika A* dipilih, pilih juga `Heuristic`.
4. **Visualisasi**: Selama pencarian, node yang sedang diproses diwarnai biru, dan jalur akhir ditandai hijau.

## Cara Menjalankan
1. Pastikan **Godot Engine** versi 4.x sudah terpasang.
2. Buka proyek dengan mengeksekusi `godot` pada folder proyek ini atau buka `project.godot` melalui UI Godot.
3. Jalankan scene utama yang berada di dalam folder `Scenes`.

## Instalasi
- **Godot Engine**: Unduh dari https://godotengine.org/download
- Tidak ada dependensi tambahan karena semua skrip berada di dalam folder `Scripts`.

## Kontribusi
Jika ingin berkontribusi, lakukan fork repository ini, buat branch baru, dan ajukan *pull request*.

## Kontak
Kelompok 7 - Universitas XYZ

## Lisensi
Proyek ini dilisensikan di bawah **MIT License**. Lihat file `LICENSE` untuk detail lebih lanjut.

## Deskripsi
Proyek ini merupakan tugas akhir mata kuliah *Artificial Intelligence* untuk kelompok 7. Implementasi ini menggunakan Godot Engine untuk membuat visualisasi algoritma A* (A-star) dalam game atau simulasi.

## Fitur
- Implementasi algoritma pencarian jalur A*.
- Visualisasi langkah-langkah pencarian secara real-time.
- Kontrol interaktif untuk mengatur titik mulai dan tujuan.
- Dukungan export ke berbagai platform melalui Godot.

## Cara Menjalankan
1. Pastikan **Godot Engine** versi 4.x sudah terpasang.
2. Buka proyek dengan mengeksekusi `godot` pada folder proyek ini atau buka `project.godot` melalui UI Godot.
3. Jalankan scene utama yang berada di dalam folder `Scenes`.

## Instalasi
- **Godot Engine**: Unduh dari https://godotengine.org/download
- Tidak ada dependensi tambahan karena semua skrip berada di dalam folder `Scripts`.

## Kontribusi
Jika ingin berkontribusi, lakukan fork repository ini, buat branch baru, dan ajukan *pull request*.

## Kontak
Kelompok 7 - Universitas XYZ

## Lisensi
Proyek ini dilisensikan di bawah **MIT License**. Lihat file `LICENSE` untuk detail lebih lanjut.