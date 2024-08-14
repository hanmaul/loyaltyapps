import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loyalty/components/alert.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/webview/content.dart';

class ContentServices extends StatefulWidget {
  final List<dynamic> service;
  final bool mobile;

  const ContentServices({
    Key? key,
    required this.service,
    required this.mobile,
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
    final int gridCount = widget.mobile ? 3 : 6;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemsWidth = 110 * gridCount.toDouble();
    final double padding = (screenWidth - itemsWidth) / 2;

    return GridView.count(
      crossAxisCount: gridCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: padding),
      children: widget.service.map((menuItem) {
        return GestureDetector(
          onTap: () {
            getUrl(menuItem.link, menuItem.judul);
          },
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
                    width: 52,
                    height: 52,
                  ),
                  Container(
                    color: Colors.transparent,
                    width: 74,
                    height: 74,
                    child: CachedNetworkImage(
                      imageUrl: menuItem.gambar,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Text(
                  menuItem.judul,
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
