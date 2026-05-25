// lib/services/location_service.dart
// Catatan: Untuk menggunakan GPS sungguhan, tambahkan package geolocator
// ke pubspec.yaml: geolocator: ^13.0.0
// dan izin di AndroidManifest.xml:
//   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
//   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

class LocationService {
  // Daftar kota di Palembang dan sekitarnya
  static const List<String> lokasiPalembang = [
    'Ilir Timur, Palembang',
    'Ilir Barat, Palembang',
    'Seberang Ulu, Palembang',
    'Bukit Besar, Palembang',
    'Jakabaring, Palembang',
    'Km 12, Palembang',
    'Kertapati, Palembang',
    'Plaju, Palembang',
    'Sematang Borang, Palembang',
    'Sukarami, Palembang',
  ];

  // Mendapatkan daftar lokasi yang tersedia
  static List<String> getDaftarLokasi() {
    return lokasiPalembang;
  }

  // Memformat harga menjadi format Rupiah
  static String formatHarga(int harga) {
    String hargaStr = harga.toString();
    String hasil = '';
    int counter = 0;

    for (int i = hargaStr.length - 1; i >= 0; i--) {
      if (counter != 0 && counter % 3 == 0) {
        hasil = '.$hasil';
      }
      hasil = hargaStr[i] + hasil;
      counter++;
    }

    return 'Rp $hasil / malam';
  }

  // Mendapatkan kategori warna berdasarkan kategori hotel
  static String getCategoryLabel(String category) {
    switch (category) {
      case 'Hotel':
        return '🏨 Hotel';
      case 'Resort':
        return '🌴 Resort';
      case 'Budget':
        return '💰 Budget';
      case 'Luxury':
        return '⭐ Luxury';
      default:
        return '🏠 Lainnya';
    }
  }
}
