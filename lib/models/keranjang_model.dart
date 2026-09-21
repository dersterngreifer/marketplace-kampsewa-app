import 'package:project_camp_sewa/constants/api_endpoint.dart';

class KeranjangModel {
  final int? id;
  final int idToko;
  final String namaToko;
  final int idProduk;
  final String fotoProduk;
  final String namaProduk;
  final String variantWarna;
  final String variantUkuran;
  final int harga;
  final int qty;
  final int selected;

  KeranjangModel({
    this.id,
    required this.idToko,
    required this.namaToko,
    required this.idProduk,
    required this.fotoProduk,
    required this.namaProduk,
    required this.variantWarna,
    required this.variantUkuran,
    required this.harga,
    required this.qty,
    required this.selected,
  });

  bool get isSelected => selected == 1;
  int get subtotal => harga * qty;

  KeranjangModel copyWith({int? qty, int? selected}) => KeranjangModel(
        id: id,
        idToko: idToko,
        namaToko: namaToko,
        idProduk: idProduk,
        fotoProduk: fotoProduk,
        namaProduk: namaProduk,
        variantWarna: variantWarna,
        variantUkuran: variantUkuran,
        harga: harga,
        qty: qty ?? this.qty,
        selected: selected ?? this.selected,
      );

  factory KeranjangModel.fromMap(Map<String, dynamic> json) => KeranjangModel(
        id: json['id'],
        idToko: json['id_toko'],
        namaToko: json['nama_toko'],
        idProduk: json['id_produk'],
        fotoProduk: getImageUrl(json['foto_produk']),
        namaProduk: json['nama_produk'],
        variantWarna: json['variant_warna'],
        variantUkuran: json['variant_ukuran'],
        harga: json['harga'],
        qty: json['qty'],
        selected: json['selected'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'id_toko': idToko,
        'nama_toko': namaToko,
        'id_produk': idProduk,
        'foto_produk': fotoProduk,
        'nama_produk': namaProduk,
        'variant_warna': variantWarna,
        'variant_ukuran': variantUkuran,
        'harga': harga,
        'qty': qty,
        'selected': selected,
      };

  /// Dipakai untuk data dari SQLite: foto_produk tetap berupa nama file mentah.
  factory KeranjangModel.fromDb(Map<String, dynamic> json) => KeranjangModel(
        id: json['id'],
        idToko: json['id_toko'],
        namaToko: json['nama_toko'],
        idProduk: json['id_produk'],
        fotoProduk: json['foto_produk'] ?? '',
        namaProduk: json['nama_produk'],
        variantWarna: json['variant_warna'],
        variantUkuran: json['variant_ukuran'],
        harga: json['harga'],
        qty: json['qty'],
        selected: json['selected'],
      );
}
