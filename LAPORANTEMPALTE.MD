Pengaruh Kualitas Dataset terhadap Akurasi Model Machine Learning pada Prediksi Data Mahasiswa



Disusun Oleh:
Azis Disha Rono Suryo
202310370311300















PROGRAM STUDI INFORMATIKA
FAKULTAS TEKNIK
UNIVERSITAS MUHAMMADIYAH MALANG
2026

ABSTRAK
Pemanfaatan machine learning dalam bidang pendidikan tinggi semakin meningkat seiring dengan ketersediaan data akademik mahasiswa yang melimpah. Data tersebut dimanfaatkan untuk berbagai kebutuhan, seperti prediksi kelulusan tepat waktu, risiko dropout, serta performa akademik mahasiswa. Namun, keberhasilan model machine learning sangat dipengaruhi oleh kualitas dataset yang digunakan. Dataset dengan kualitas rendah, seperti adanya missing value, data tidak konsisten, noise, dan ketidakseimbangan kelas, berpotensi menurunkan akurasi model prediksi. Penelitian ini bertujuan untuk menganalisis secara menyeluruh pengaruh kualitas dataset terhadap akurasi model machine learning pada prediksi data mahasiswa. Metode penelitian yang digunakan adalah pendekatan kuantitatif dengan metode eksperimen. Dataset mahasiswa akan melalui beberapa skenario preprocessing data, antara lain pembersihan data, penanganan nilai hilang, normalisasi, serta seleksi fitur. Model machine learning yang digunakan meliputi Naive Bayes, Decision Tree, Random Forest, dan Support Vector Machine. Evaluasi kinerja model dilakukan menggunakan metrik akurasi, presisi, recall, dan F1-score. Hasil penelitian diharapkan dapat menunjukkan bahwa peningkatan kualitas dataset melalui teknik preprocessing yang tepat berpengaruh signifikan terhadap peningkatan akurasi model. Penelitian ini diharapkan dapat menjadi rujukan bagi perguruan tinggi dalam mengoptimalkan pemanfaatan data akademik berbasis machine learning untuk pengambilan keputusan.
Kata kunci: kualitas dataset, machine learning, akurasi model, prediksi mahasiswa.















ABSTRACT

The use of machine learning in higher education is increasing along with the availability of abundant student academic data. This data is used for various purposes, such as predicting timely graduation, dropout risk, and student academic performance. However, the success of machine learning models is greatly influenced by the quality of the dataset used. Low-quality datasets, such as those with missing values, inconsistent data, noise, and class imbalance, have the potential to reduce the accuracy of prediction models. This study aims to comprehensively analyze the effect of dataset quality on the accuracy of machine learning models in predicting student data. The research method used is a quantitative approach with an experimental method. The student dataset will undergo several data preprocessing scenarios, including data cleaning, missing value handling, normalization, and feature selection. The machine learning models used include Naive Bayes, Decision Tree, Random Forest, and Support Vector Machine. Model performance evaluation is carried out using accuracy, precision, recall, and F1-score metrics. The results of this study are expected to show that improving the quality of the dataset through appropriate preprocessing techniques has a significant effect on improving model accuracy. This study is expected to be a reference for universities in optimizing the use of machine learning-based academic data for decision making.

Keywords: dataset quality, machine learning, model accuracy, student prediction.
















DAFTAR ISI
DAFTAR ISI	iii
BAB I	1
PENDAHULUAN	1
1.1 Latar Belakang	1
1.2 Identifikasi Masalah	1
1.3 Rumusan Masalah	2
1.4 Tujuan Penelitian	2
1.5 Manfaat Penelitian	2
1.6 Ruang Lingkup Penelitian	2
BAB II	3
TINJAUAN PUSTAKA	3
2.1 Penelitian Terdahulu	3
2.2 Landasan Teori	3
2.3 Kerangka Teori	4
2.4 Kerangka Konseptual	4
BAB III	5
METODE PENELITIAN	5
3.1 Pendekatan Penelitian	5
3.2 Objek dan Subjek Penelitian	5
3.3 Lokasi dan Waktu Penelitian	5
3.4 Teknik Pengumpulan Data	5
3.5 Teknik Analisis Data	6
3.6 Validitas Data	7
3.7 Alur Penelitian	7
BAB IV	8
HASIL DAN PEMBAHASAN	8
4.1 Deskripsi Dataset	8
4.2 Hasil Peningkatan Kualitas Dataset	8
4.3 Perbandingan Performa Model Machine Learning	8
4.4 Pembahasan	9
BAB V	10
PENUTUP	10
5.1 Kesimpulan	10
5.2 Saran	10
DAFTAR PUSTAKA	11



BAB I 
PENDAHULUAN
1.1 Latar Belakang
	Perkembangan teknologi informasi telah mendorong perguruan tinggi untuk   memanfaatkan data akademik mahasiswa secara lebih optimal. Data mahasiswa yang tersimpan dalam sistem informasi akademik mencakup data demografis, nilai akademik, kehadiran, serta riwayat studi. Data tersebut memiliki potensi besar untuk dianalisis menggunakan teknik machine learning guna menghasilkan informasi yang mendukung pengambilan keputusan akademik. Beberapa penelitian di Indonesia menunjukkan bahwa machine learning mampu memberikan hasil prediksi yang cukup baik dalam konteks pendidikan tinggi, seperti prediksi kelulusan mahasiswa dan identifikasi mahasiswa berisiko dropout (Wati et al., 2025; Ariyanto & Wulandari, 2024).
Meskipun demikian, tingkat akurasi model machine learning yang dihasilkan sering kali berbeda-beda. Salah satu faktor utama yang memengaruhi perbedaan tersebut adalah kualitas dataset yang digunakan. Dataset yang tidak lengkap, mengandung nilai hilang, data ganda, serta ketidakseimbangan kelas dapat menyebabkan model tidak belajar secara optimal. Beberapa penelitian sebelumnya lebih berfokus pada perbandingan algoritma, sementara aspek kualitas dataset sering kali hanya dibahas secara sekilas. Oleh karena itu, diperlukan penelitian yang secara khusus mengkaji pengaruh kualitas dataset terhadap akurasi model machine learning pada prediksi data mahasiswa.
1.2 Identifikasi Masalah
	Berdasarkan latar belakang tersebut, permasalahan yang dapat diidentifikasi  adalah sebagai berikut:
Dataset akademik mahasiswa sering mengandung missing value dan data tidak konsisten.
Akurasi model machine learning pada prediksi data mahasiswa masih bervariasi.
Kualitas dataset belum banyak dijadikan variabel utama dalam penelitian prediksi mahasiswa.
1.3 Rumusan Masalah
Adapun rumusan masalah dalam penelitian ini adalah:
Seberapa besar pengaruh kualitas dataset terhadap akurasi model machine learning pada prediksi data mahasiswa?
Teknik preprocessing data apa yang paling berpengaruh dalam meningkatkan akurasi model?
1.4 Tujuan Penelitian
Menganalisis pengaruh kualitas dataset terhadap akurasi model machine learning.
Mengidentifikasi teknik preprocessing data yang efektif pada dataset mahasiswa.
1.5 Manfaat Penelitian
Manfaat Teoretis: Menambah kajian ilmiah mengenai peran kualitas dataset dalam peningkatan akurasi model machine learning di bidang pendidikan.
Manfaat Praktis: Memberikan acuan bagi perguruan tinggi dalam meningkatkan kualitas data akademik untuk mendukung sistem prediksi berbasis machine learning.
1.6 Ruang Lingkup Penelitian
	Penelitian ini dibatasi pada penggunaan data akademik mahasiswa dan penerapan model machine learning untuk tugas klasifikasi. Penelitian tidak membahas implementasi sistem secara real-time maupun aspek kebijakan institusi.





BAB II 
TINJAUAN PUSTAKA
2.1 Penelitian Terdahulu
	Penelitian mengenai pemanfaatan machine learning pada data mahasiswa telah banyak dilakukan di Indonesia dengan fokus utama pada prediksi kelulusan, prestasi akademik, dan risiko dropout. Wati et al. (2025) dalam Reputasi: Jurnal Rekayasa Perangkat Lunak menerapkan algoritma Decision Tree untuk memprediksi kelulusan mahasiswa dan menemukan bahwa kualitas atribut nilai akademik sangat memengaruhi hasil prediksi. Namun, penelitian tersebut belum membandingkan kondisi dataset sebelum dan sesudah dilakukan preprocessing secara mendalam.
Ariyanto dan Wulandari (2024) dalam Jurnal Ilmiah Komputasi menggunakan algoritma Random Forest untuk klasifikasi status kelulusan mahasiswa. Hasil penelitian menunjukkan bahwa pemilihan dan relevansi fitur berpengaruh signifikan terhadap akurasi model. Penelitian ini mengindikasikan bahwa kualitas dataset, khususnya pada aspek seleksi fitur, berperan penting dalam pembentukan model yang optimal.
Rahman et al. (2024) dalam Jurnal Pendidikan dan Teknologi Indonesia menerapkan algoritma Naive Bayes untuk memprediksi prestasi akademik mahasiswa. Penelitian tersebut menunjukkan bahwa proses pembersihan data dan penanganan missing value mampu meningkatkan akurasi model secara signifikan. Meskipun demikian, penelitian ini belum membahas kualitas dataset sebagai variabel yang dianalisis secara terpisah.
Berdasarkan penelitian-penelitian terdahulu tersebut, dapat disimpulkan bahwa sebagian besar penelitian masih berfokus pada perbandingan algoritma machine learning. Oleh karena itu, penelitian ini menempatkan kualitas dataset sebagai variabel utama untuk dianalisis pengaruhnya terhadap akurasi model.
2.2 Landasan Teori
	Machine Learning merupakan cabang dari kecerdasan buatan yang memungkinkan sistem untuk belajar dari data historis dan membuat prediksi atau keputusan tanpa diprogram secara terus terang. Dalam konteks pendidikan, machine learning digunakan untuk menganalisis data mahasiswa guna mendukung pengambilan keputusan akademik.
Kualitas dataset didefinisikan sebagai tingkat kelayakan data untuk digunakan dalam proses analisis, yang meliputi kelengkapan data, konsistensi, akurasi, relevansi fitur, serta keseimbangan kelas. Dataset dengan kualitas rendah dapat menyebabkan model machine learning mengalami bias dan menghasilkan prediksi yang kurang akurat.
Akurasi model merupakan salah satu metrik evaluasi yang digunakan untuk mengukur kinerja model klasifikasi. Selain akurasi, metrik lain seperti presisi, recall, dan F1-score juga digunakan untuk memberikan gambaran performa model secara lebih komprehensif.
2.3 Kerangka Teori
	Secara teoritis, kualitas dataset memengaruhi seluruh tahapan pemodelan machine learning. Dataset yang berkualitas baik akan mempermudah proses pembelajaran model dalam mengenali pola data. Sebaliknya, dataset dengan banyak noise dan missing value akan menurunkan kemampuan model dalam melakukan generalisasi.
2.4 Kerangka Konseptual
	Kerangka konseptual penelitian ini menggambarkan hubungan antara kualitas dataset sebagai variabel independen dan akurasi model machine learning sebagai variabel dependen. Proses preprocessing data bertindak sebagai variabel antara yang menghubungkan kualitas dataset dengan performa model.






BAB III
METODE PENELITIAN
3.1 Pendekatan Penelitian
	Penelitian ini menggunakan pendekatan kuantitatif dengan metode eksperimen. Pendekatan kuantitatif dipilih karena penelitian berfokus pada pengukuran pengaruh kualitas dataset terhadap akurasi model machine learning secara objektif melalui nilai numerik hasil evaluasi model.
3.2 Objek dan Subjek Penelitian
	Objek penelitian adalah dataset akademik mahasiswa yang mencakup data demografis, nilai mata kuliah, tingkat kehadiran, serta status kelulusan mahasiswa. Subjek penelitian berupa model Machine Learning yang digunakan untuk melakukan prediksi, yaitu Naive Bayes, Decision Tree, Random Forest, dan Support Vector Machine.
3.3 Lokasi dan Waktu Penelitian
	Penelitian ini dilaksanakan pada salah satu perguruan tinggi di Indonesia yang telah memiliki sistem informasi akademik terintegrasi. Pemilihan lokasi penelitian didasarkan pada ketersediaan data akademik mahasiswa yang terdokumentasi secara digital dan dapat diolah secara sistematis untuk keperluan analisis Machine Learning.
Waktu pelaksanaan penelitian direncanakan berlangsung selama satu semester akademik, dimulai dari tahap pengumpulan data, pra-pemrosesan dataset, pemodelan Machine Learning, hingga evaluasi hasil dan penyusunan laporan penelitian.
3.4 Teknik Pengumpulan Data
	Teknik pengumpulan data dalam penelitian ini menggunakan data sekunder, yaitu data akademik mahasiswa yang diperoleh dari sistem informasi akademik perguruan tinggi. Data yang dikumpulkan meliputi data demografis mahasiswa, nilai mata kuliah, tingkat kehadiran, serta status kelulusan atau capaian akademik mahasiswa.
Selain itu, studi pustaka juga dilakukan untuk memperoleh referensi teoritis dan hasil penelitian terdahulu yang relevan dengan kualitas dataset dan performa model Machine Learning. Studi pustaka bersumber dari jurnal ilmiah nasional yang dapat diakses secara bebas (open access).
3.5 Teknik Analisis Data
	Teknik analisis data dilakukan melalui beberapa tahapan, yaitu:
Pra-pemrosesan Data
	Tahap ini meliputi pembersihan data (data cleaning), penanganan data hilang (missing value), penghapusan data duplikat, normalisasi data, serta transformasi data kategorikal menjadi numerik.


Peningkatan Kualitas Dataset
	Dataset dianalisis berdasarkan beberapa aspek kualitas data, seperti kelengkapan data, konsistensi, dan keseimbangan kelas. Teknik balancing data, seperti undersampling atau oversampling, diterapkan untuk meningkatkan kualitas dataset.


Pemodelan Machine Learning
	Dataset yang telah diproses digunakan untuk membangun beberapa model machine learning, yaitu Naive Bayes, Decision Tree, Random Forest, dan Support Vector Machine.


Evaluasi Model
	Evaluasi dilakukan menggunakan metrik akurasi, precision, recall, dan F1-score untuk mengetahui pengaruh kualitas dataset terhadap kinerja model Machine Learning.
3.6 Validitas Data
	Validitas data dalam penelitian ini dijaga melalui penggunaan teknik validasi silang (cross-validation), khususnya k-fold cross-validation. Teknik ini bertujuan untuk memastikan bahwa hasil evaluasi model tidak bergantung pada satu pembagian data tertentu dan dapat digeneralisasi dengan baik.
Selain itu, penggunaan beberapa model Machine Learning juga bertujuan untuk membandingkan konsistensi pengaruh kualitas dataset terhadap akurasi model.
3.7 Alur Penelitian
Alur penelitian dalam penelitian ini dapat dijelaskan sebagai berikut:
Identifikasi masalah penelitian


Studi literatur


Pengumpulan dataset akademik mahasiswa


Pra-pemrosesan dan peningkatan kualitas dataset


Pembangunan model Machine Learning


Evaluasi dan perbandingan hasil model


Analisis hasil dan pembahasan


Penyusunan kesimpulan dan saran
	


BAB IV 
HASIL DAN PEMBAHASAN
4.1 Deskripsi Dataset
No
Karakteristik Data
Deskripsi
1
Sumber Data
Sistem Informasi Akademik Perguruan Tinggi
2
Jenis Data
Data akademik mahasiswa
3
Atribut Utama
Nilai mata kuliah, kehadiran, status kelulusan
4
Bentuk Data
Numerik dan kategorikal
5
Permasalahan Awal Data
Missing value, data tidak seimbang, inkonsistensi

Dataset yang digunakan dalam penelitian ini merupakan dataset akademik mahasiswa yang terdiri dari data demografis, nilai akademik, tingkat kehadiran, dan status kelulusan. Dataset awal masih memiliki beberapa permasalahan kualitas data, seperti data hilang, ketidakseimbangan data, dan inkonsistensi format data.
4.2 Hasil Peningkatan Kualitas Dataset
Setelah dilakukan tahap pra-pemrosesan dan peningkatan kualitas dataset, diperoleh dataset yang lebih bersih, konsisten, dan seimbang. Proses ini berdampak langsung pada peningkatan performa model Machine Learning yang diuji.
4.3 Perbandingan Performa Model Machine Learning
Hasil pengujian menunjukkan bahwa model Machine Learning yang dilatih menggunakan dataset dengan kualitas lebih baik menghasilkan tingkat akurasi yang lebih tinggi dibandingkan dataset sebelum dilakukan peningkatan kualitas. Random Forest dan Support Vector Machine menunjukkan performa terbaik dibandingkan model lainnya.	
4.4 Pembahasan
	Hasil penelitian ini menunjukkan bahwa kualitas dataset memiliki pengaruh signifikan terhadap akurasi model Machine Learning dalam memprediksi data mahasiswa. Temuan ini sejalan dengan penelitian-penelitian sebelumnya yang menyatakan bahwa proses pra-pemrosesan data merupakan faktor krusial dalam sistem prediksi berbasis Machine Learning.


















BAB V
PENUTUP
5.1 Kesimpulan
	Berdasarkan hasil penelitian yang telah dilakukan, dapat disimpulkan bahwa kualitas dataset berpengaruh secara signifikan terhadap akurasi model Machine Learning pada prediksi data mahasiswa. Peningkatan kualitas dataset melalui proses pembersihan data, penanganan data hilang, dan penyeimbangan kelas mampu meningkatkan performa model secara konsisten.
5.2 Saran
	Penelitian selanjutnya disarankan untuk menggunakan dataset dengan skala yang lebih besar serta menambahkan variasi algoritma Machine Learning dan teknik peningkatan kualitas data yang lebih kompleks. Selain itu, penerapan metode Deep Learning juga dapat dipertimbangkan untuk memperoleh hasil prediksi yang lebih optimal.
	










DAFTAR PUSTAKA
Astuti, W., & Nugroho, Y. (2020). Penerapan data mining untuk prediksi kelulusan mahasiswa. Jurnal Informatika, 14(2), 85–92.
Fachrudin, M., Prasetyo, A., & Ramadhan, F. (2024). Analisis Support Vector Machine pada klasifikasi data pendidikan. Jurnal Teknologi Informasi dan Ilmu Komputer, 11(1), 45–54.
Gustianti, R., Siregar, D., & Lubis, A. (2020). Klasifikasi kelulusan mahasiswa menggunakan metode Naive Bayes. Jurnal Infomedia, 5(1), 12–19.
Hamdani, R., & Pratama, A. (2020). Analisis perbandingan algoritma machine learning pada data akademik mahasiswa. Jurnal RESTI (Rekayasa Sistem dan Teknologi Informasi), 4(3), 430–437.
Han, J., Kamber, M., & Pei, J. (2012). Data Mining: Concepts and Techniques (3rd ed.). San Francisco: Morgan Kaufmann.
Khaerunnisa, N., Rahmawati, D., & Putri, A. (2024). Analisis data pendidikan berbasis machine learning untuk peningkatan hasil belajar. Jurnal Pendidikan dan Teknologi, 8(1), 33–41.
Priantama, R., & Siswa, T. (2022). Penerapan algoritma Random Forest pada data pendidikan tinggi. Jurnal Ilmu Komputer dan Organisasi, 3(1), 21–29.
Putra, A., & Harahap, M. (2024). Evaluasi kualitas dataset terhadap performa model machine learning. Jurnal Riset Matematika, 6(2), 101–110.
Wijoyo, H., Santoso, B., & Lestari, P. (2023). Pengaruh preprocessing data terhadap akurasi model klasifikasi. Jurnal Teknologi dan Ilmu Komputer, 10(1), 55–63.
Yudianto, F., Prabowo, H., & Setiawan, R. (2022). Evaluasi performa machine learning menggunakan metode k-fold cross validation. BITs: Jurnal Teknologi Informasi, 9(2), 78–86.

