class VariantProductModel {
  int idProduk;
  String namaProduk;
  String fotoDepan;
  int idVariantProduk;
  String warna;
  int idDetailVariantProduk;
  String ukuran;
  int stok;
  int hargaSewa;

  VariantProductModel({
    required this.idProduk,
    required this.namaProduk,
    required this.fotoDepan,
    required this.idVariantProduk,
    required this.warna,
    required this.idDetailVariantProduk,
    required this.ukuran,
    required this.stok,
    required this.hargaSewa,
  });

  factory VariantProductModel.fromJson(Map<String, dynamic> json) {
    return VariantProductModel(
      idProduk: json['id_produk'] is int
          ? json['id_produk']
          : int.tryParse(json['id_produk']?.toString() ?? '0') ?? 0,
      namaProduk: json['nama_produk']?.toString() ?? '',
      fotoDepan: json['foto_depan']?.toString() ?? '',
      idVariantProduk: json['id_variant_produk'] is int
          ? json['id_variant_produk']
          : int.tryParse(json['id_variant_produk']?.toString() ?? '0') ?? 0,
      warna: json['warna']?.toString() ?? 'Standar',
      idDetailVariantProduk: json['id_detail_variant_produk'] is int
          ? json['id_detail_variant_produk']
          : int.tryParse(json['id_detail_variant_produk']?.toString() ?? '0') ?? 0,
      ukuran: json['ukuran']?.toString() ?? 'All Size',
      stok: json['stok'] is int
          ? json['stok']
          : int.tryParse(json['stok']?.toString() ?? '0') ?? 0,
      hargaSewa: json['harga_sewa'] is int
          ? json['harga_sewa']
          : int.tryParse(json['harga_sewa']?.toString() ?? '0') ?? 0,
    );
  }
}