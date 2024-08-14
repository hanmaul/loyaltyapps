import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loyalty/components/alert.dart';
import 'package:loyalty/screen/webview/content.dart';

class ContentAdds extends StatefulWidget {
  final String gambar;
  final String judul;
  final String isi;
  final String url;
  final bool mobile;

  const ContentAdds({
    Key? key,
    required this.gambar,
    required this.judul,
    required this.isi,
    required this.url,
    required this.mobile,
  }) : super(key: key);

  @override
  State<ContentAdds> createState() => _ContentAddsState();
}

class _ContentAddsState extends State<ContentAdds> {
  Future<void> getUrl(String urlWeb, String urlTitle) async {
    if (urlWeb.isNotEmpty) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => Content(title: urlTitle, url: urlWeb),
        ),
      );
    } else {
      showAlert(
        context: context,
        title: 'Dalam Pengembangan..',
        content: 'Mohon maaf saat ini menu sedang dalam pengembangan.',
        type: 'info',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        getUrl(widget.url, widget.judul);
      },
      child: Container(
        height: widget.mobile ? 250 : 200, // Adjust the height as needed
        child: Card(
          margin: widget.mobile
              ? const EdgeInsets.all(12.0)
              : const EdgeInsets.all(24.0),
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Container(
                  color: Colors.white,
                  height: 120,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: widget.gambar,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        widget.isi,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
