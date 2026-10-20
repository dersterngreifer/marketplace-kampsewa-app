class SuspendInfoModel {
  final int? idSuspend;
  final String? alasan;
  final String? catatan;
  final String? statusRevisi;
  final String? createdAt;
  final String? instruksi;

  SuspendInfoModel({
    this.idSuspend,
    this.alasan,
    this.catatan,
    this.statusRevisi,
    this.createdAt,
    this.instruksi,
  });

  factory SuspendInfoModel.fromJson(Map<String, dynamic> json) {
    return SuspendInfoModel(
      idSuspend: json['id_suspend'] is int
          ? json['id_suspend']
          : int.tryParse(json['id_suspend']?.toString() ?? ''),
      alasan: json['alasan']?.toString(),
      catatan: json['catatan']?.toString(),
      statusRevisi: json['status_revisi']?.toString(),
      createdAt: json['created_at']?.toString(),
      instruksi: json['instruksi']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_suspend': idSuspend,
      'alasan': alasan,
      'catatan': catatan,
      'status_revisi': statusRevisi,
      'created_at': createdAt,
      'instruksi': instruksi,
    };
  }
}
