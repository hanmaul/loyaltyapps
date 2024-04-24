class Banner {
  final String url;

  Banner({
    required this.url,
  });

  static String _savedUrl = '';

  factory Banner.fromJson(String url) {
    _savedUrl = url;
    return Banner(
      url: url,
    );
  }

  static Banner fromSaved() {
    return Banner(
      url: _savedUrl,
    );
  }
}
