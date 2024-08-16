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
    // size
    const double imgSize = 74;
    const double boxSize = 52;
    const double lableSize = 11;

    // layout size
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    final double serviceWidth = mediaQueryWidth * 0.7;

    //final int itemLength = widget.service.length;
    //final int itemCount = widget.mobile ? 3 : 6;
    //final int gridCount = itemLength < itemCount ? itemLength : itemCount;
    //final double screenWidth = MediaQuery.of(context).size.width;
    //final double serviceWidth = 110 * gridCount.toDouble();
    //final double padding = (screenWidth - serviceWidth) / 2;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20.0),
        color: Colors.white,
        width: serviceWidth, // Adjust the width as needed
        child: Wrap(
          spacing: 26.0, // Adjust spacing between items
          runSpacing: 26.0, // Adjust spacing between lines
          alignment: WrapAlignment.center, // Center align items
          children: widget.service.map((menuItem) {
            return GestureDetector(
              onTap: () {
                getUrl(menuItem.link, menuItem.judul);
              },
              child: Container(
                width: imgSize,
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                          color: Colors.transparent,
                          width: imgSize,
                          height: imgSize,
                          child: CachedNetworkImage(
                            imageUrl: menuItem.gambar,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      menuItem.judul,
                      style: const TextStyle(
                        fontSize: lableSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    // return GridView.count(
    //   crossAxisCount: gridCount,
    //   shrinkWrap: true,
    //   physics: const NeverScrollableScrollPhysics(),
    //   padding: EdgeInsets.symmetric(horizontal: padding),
    //   children: widget.service.map((menuItem) {
    //     return GestureDetector(
    //       onTap: () {
    //         getUrl(menuItem.link, menuItem.judul);
    //       },
    //       child: Column(
    //         children: [
    //           Stack(
    //             alignment: Alignment.center,
    //             children: [
    //               Container(
    //                 decoration: BoxDecoration(
    //                   gradient: const LinearGradient(
    //                     begin: Alignment.topLeft,
    //                     end: Alignment.bottomRight,
    //                     colors: [
    //                       Color(0xffFFFFFF),
    //                       Color(0xff8CC2E6),
    //                     ],
    //                   ),
    //                   borderRadius: const BorderRadius.all(
    //                     Radius.circular(15),
    //                   ),
    //                   boxShadow: [
    //                     BoxShadow(
    //                       color: Colors.grey.withOpacity(0.5),
    //                       spreadRadius: 0,
    //                       blurRadius: 10,
    //                       offset: const Offset(0, 6),
    //                     )
    //                   ],
    //                 ),
    //                 width: 52,
    //                 height: 52,
    //               ),
    //               Container(
    //                 color: Colors.transparent,
    //                 width: 74,
    //                 height: 74,
    //                 child: CachedNetworkImage(
    //                   imageUrl: menuItem.gambar,
    //                   fit: BoxFit.cover,
    //                 ),
    //               ),
    //             ],
    //           ),
    //           Flexible(
    //             child: Text(
    //               menuItem.judul,
    //               style: const TextStyle(
    //                 fontSize: 11,
    //               ),
    //               textAlign: TextAlign.center,
    //             ),
    //           ),
    //         ],
    //       ),
    //     );
    //   }).toList(),
    // );
  }
}
