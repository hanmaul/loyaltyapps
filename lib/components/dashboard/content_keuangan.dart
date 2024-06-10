import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loyalty/components/alert.dart';

class ContentKeuangan extends StatefulWidget {
  final String icon;
  final String title;
  final String total;
  final String url;

  const ContentKeuangan({
    Key? key,
    required this.icon,
    required this.title,
    required this.total,
    required this.url,
  }) : super(key: key);

  @override
  State<ContentKeuangan> createState() => _ContentKeuanganState();
}

class _ContentKeuanganState extends State<ContentKeuangan> {
  Future<void> getUrl(String urlWeb, String urlTitle) async {
    if (urlWeb != "" && urlWeb != "#") {
      Navigator.pushNamed(
        context,
        '/content',
        arguments: {'title': urlTitle, 'url': urlWeb},
      );
    } else {
      showAlert(
        context: context,
        title: 'Akses Gagal!',
        content: 'Mohon maaf saat ini menu tidak dapat diakses.',
        type: 'error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          getUrl(widget.url, widget.title);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    // color: Colors.amber,
                    // width: 36,
                    height: 26,
                    child: CachedNetworkImage(
                      imageUrl: widget.icon,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Rp${widget.total}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
