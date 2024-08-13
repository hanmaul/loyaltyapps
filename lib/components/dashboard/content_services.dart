import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loyalty/components/alert.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/webview/content.dart';

class ContentServices extends StatefulWidget {
  final String icon;
  final String title;
  final String url;
  final double cardSize;

  const ContentServices({
    Key? key,
    required this.icon,
    required this.title,
    required this.url,
    required this.cardSize,
  }) : super(key: key);

  @override
  State<ContentServices> createState() => _ContentServicesState();
}

class _ContentServicesState extends State<ContentServices> {
  Future<void> getUrl(String urlWeb, String urlTitle) async {
    final custId = await DatabaseRepository().loadUser(field: "custId");
    if (urlWeb != "") {
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
    final double imgSize = widget.cardSize / 4;
    final double boxSize = imgSize * 0.70;
    final double lableSize = boxSize * 0.22;
    return GestureDetector(
      onTap: () {
        getUrl(widget.url, widget.title);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xffFFFFFF),
                        Color(0xff8CC2E6),
                      ],
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  width: boxSize,
                  height: boxSize,
                ),
                Container(
                  // color: Colors.amber,
                  width: imgSize,
                  height: imgSize,
                  child: CachedNetworkImage(
                    imageUrl: widget.icon,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: lableSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
