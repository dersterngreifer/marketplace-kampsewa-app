void main() {
  String baseUrl = "http://192.168.0.3:8000";
  String defaultPrefix = "/assets/image/customers/produk/";
  
  String resolveFullUrl(String path, String prefix) {
    if (path.isEmpty) return '';
    path = path.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    
    if (path.startsWith('/')) path = path.substring(1);
    
    String cleanPrefix = prefix.startsWith('/') ? prefix.substring(1) : prefix;
    if (path.startsWith(cleanPrefix)) {
      return "$baseUrl/$path";
    }
    
    if (path.startsWith('assets/') || path.startsWith('storage/')) {
      return "$baseUrl/$path";
    }
    
    return "$baseUrl$prefix$path";
  }

  print(resolveFullUrl("http://example.com/a.jpg", defaultPrefix));
  print(resolveFullUrl("assets/image/customers/produk/a.jpg", defaultPrefix));
  print(resolveFullUrl("/assets/image/customers/produk/a.jpg", defaultPrefix));
  print(resolveFullUrl("a.jpg", defaultPrefix));
  print(resolveFullUrl("[]", defaultPrefix));
}
