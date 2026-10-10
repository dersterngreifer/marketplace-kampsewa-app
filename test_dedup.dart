void main() {
  List<String> rawImages = [
    'http://localhost:8000/assets/image/produk/1.jpg',
    'http://192.168.1.2:8000/assets/image/produk/2.jpg',
    '3.jpg',
    '/assets/image/produk/4.jpg'
  ];
  List<String> uniqueImages = [];
  for (var img in rawImages) {
    String filename = img.split('/').last;
    if (!uniqueImages.any((e) => e.split('/').last == filename)) {
      uniqueImages.add(img);
    }
  }
  print(uniqueImages);
}
