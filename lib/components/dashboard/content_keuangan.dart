import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loyalty/components/alert.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/webview/content.dart';

class ContentKeuangan extends StatefulWidget {
  final String icon;
  final String title;
  final String total;
  final String url;
  final double fontSize;
  final double cardSize;

  const ContentKeuangan({
    Key? key,
    required this.icon,
    required this.title,
    required this.total,
    required this.url,
    required this.fontSize,
    required this.cardSize,
  }) : super(key: key);

  @override
  State<ContentKeuangan> createState() => _ContentKeuanganState();
}

class _ContentKeuanganState extends State<ContentKeuangan> {
  Future<void> getUrl(String urlWeb, String urlTitle) async {
    final custId = await DatabaseRepository().loadUser(field: "custId");
    if (urlWeb.isNotEmpty) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => Content(title: urlTitle, url: urlWeb + custId),
        ),
      );
    } else {
      if (mounted) {
        showAlert(
          context: context,
          title: 'Dalam Pengembangan..',
          content: 'Mohon maaf saat ini menu sedang dalam pengembangan.',
          type: 'info',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.cardSize * 0.24;
    final titleSize = iconSize * 0.46;

    // Split the title into a list of words
    final List<String> titleWords = widget.title.split(' ');

    return Expanded(
      child: GestureDetector(
        onTap: () {
          getUrl(widget.url, widget.title);
        },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: iconSize,
                    child: CachedNetworkImage(
                      imageUrl: widget.icon,
                      placeholder: (context, url) => SizedBox(
                        height: iconSize,
                        width: iconSize,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: titleSize * 0.5),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: titleWords.map((word) {
                      return Text(
                        word,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.normal,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.start,
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: titleSize * 0.5),
              Text(
                'Rp${widget.total}',
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  height: 0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
