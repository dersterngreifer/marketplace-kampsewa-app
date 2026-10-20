import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/card/produk_card.dart';
import 'package:project_camp_sewa/models/suspend_info_model.dart';

void main() {
  testWidgets('ProdukCard renders locked state and banner when isLocked is true',
      (WidgetTester tester) async {
    final suspendInfo = SuspendInfoModel(
      idSuspend: 15,
      alasan: "Foto Berbau Seksual / Vulgar",
      catatan: "Mohon ganti foto utama dengan foto asli produk jaket camping.",
      statusRevisi: "menunggu_perbaikan",
      createdAt: "2026-10-20 10:45:00",
      instruksi:
          "Revisi dan pengajuan pemulihan hanya dapat dilakukan melalui Dashboard Web KampSewa.",
    );

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 350,
              child: ProdukCard(
                images: const [],
                namaProduk: "Pakaian Anti Air Dan Hangat Untuk Camping",
                harga: "35000",
                rating: "4.8",
                isOwner: true,
                isLocked: true,
                lockedMessage:
                    "Produk ini ditangguhkan oleh Admin KampSewa. Silakan lakukan revisi perbaikan produk melalui Dashboard Web KampSewa.",
                suspendInfo: suspendInfo,
                aksi: () {},
                aksiKeranjang: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify "Ditangguhkan" badge is rendered
    expect(find.text("Ditangguhkan"), findsOneWidget);

    // Verify "Terkunci di Mobile" overlay is rendered
    expect(find.text("Terkunci di Mobile"), findsOneWidget);

    // Verify "Revisi di Web" / locked button is rendered
    expect(find.text("Terkunci (Web)"), findsOneWidget);

    // Verify banner text is rendered
    expect(
      find.text(
          "Produk ditangguhkan oleh Admin. Silakan periksa & revisi melalui Dashboard Web KampSewa."),
      findsOneWidget,
    );
  });

  testWidgets('Active ProdukCard renders normal state',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 350,
              child: ProdukCard(
                images: const [],
                namaProduk: "Tenda Dome 4 Orang",
                harga: "60000",
                rating: "5.0",
                stok: 5,
                isOwner: false,
                isLocked: false,
                aksi: () {},
                aksiKeranjang: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify "Sewa" button is rendered
    expect(find.text("Sewa"), findsOneWidget);

    // Verify "Ditangguhkan" is NOT present
    expect(find.text("Ditangguhkan"), findsNothing);
    expect(find.text("Terkunci di Mobile"), findsNothing);
  });
}
