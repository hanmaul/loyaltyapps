import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContentServices extends StatefulWidget {
  final String icon;
  final String title;
  final String url;

  const ContentServices({
    Key? key,
    required this.icon,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  State<ContentServices> createState() => _ContentServicesState();
}

class _ContentServicesState extends State<ContentServices> {
  Future<void> getUrl(String urlWeb, String urlTitle) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("url", urlWeb);
    await pref.setString("url_title", urlTitle);
    if (urlWeb != "") {
      Navigator.pushNamed(context, '/services');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          "Url Kosong!",
          style: TextStyle(fontSize: 16, color: Colors.white),
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        getUrl(widget.url, widget.title);
      },
      child: Container(
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
                  width: 58,
                  height: 58,
                ),
                Container(
                  // color: Colors.amber,
                  width: 80,
                  height: 80,
                  child: CachedNetworkImage(
                    imageUrl: widget.icon,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
