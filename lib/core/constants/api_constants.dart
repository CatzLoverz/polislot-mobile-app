class ApiConstants {
  // Ganti IP ini sesuai dengan IP Laptop/Server Laravel Anda
  static const String baseUrl = "http://192.168.137.1:8000/api";
  
  // URL untuk mengakses gambar (storage)
  static const String storageUrl = "http://192.168.137.1:8000/storage/";
  
  // Timeout default
  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 15000;
}