import 'dart:convert';

void main() {
  String jsonStr = '{"foto_array": "[http://localhost:8000/assets/image/produk/1728557348_tent.jpg, http://localhost:8000/assets/image/produk/1728557348_tent2.jpg]"}';
  var json = jsonDecode(jsonStr);

  List<String> parsedFotoArray = [];
    if (json['foto_array'] != null) {
      var arr = json['foto_array'];
      if (arr is String) {
        try {
          arr = jsonDecode(arr);
        } catch (_) {
          String strArr = arr.toString().trim();
          if (strArr.startsWith('[') && strArr.endsWith(']')) {
            strArr = strArr.substring(1, strArr.length - 1);
          }
          if (strArr.contains(',')) {
            arr = strArr.split(',').map((e) => e.replaceAll('"', '').replaceAll("'", "").trim()).toList();
          } else {
            arr = [strArr.replaceAll('"', '').replaceAll("'", "").trim()];
          }
        }
      }
      if (arr is Map) {
        arr = arr.values.toList();
      }
      if (arr is List) {
        parsedFotoArray = arr.map<String>((e) {
          if (e is Map) return e['url']?.toString() ?? '';
          return e.toString().trim();
        }).where((url) {
          return url.toString().isNotEmpty &&
              url.toString() != 'null' &&
              url.toString() != 'Belum di isi';
        }).toList();
      }
    }
  print(parsedFotoArray);
}
