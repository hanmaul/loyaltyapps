import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loyalty/components/alert.dart';
import 'package:loyalty/screen/webview/content.dart';

class ContentAdds extends StatefulWidget {
  final List<dynamic> adds;
  final bool mobile;

  const ContentAdds({
    Key? key,
    required this.adds,
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
    // Layout size
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    final double addWidth = mediaQueryWidth * 0.9;

    // Size calculations
    final double itemWidth = widget.mobile
        ? mediaQueryWidth * 0.9
        : mediaQueryWidth < 900
            ? (addWidth / 2) - (addWidth * 0.05)
            : (addWidth / 3) - (addWidth * 0.025);
    final double itemDistance =
        mediaQueryWidth < 900 ? addWidth * 0.05 : addWidth * 0.025;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        color: Colors.white,
        width: addWidth,
        child: Wrap(
          spacing: itemDistance, // Horizontal spacing between items
          runSpacing: itemDistance, // Vertical spacing between lines
          alignment: WrapAlignment.center,
          children: widget.adds.map((menuItem) {
            return GestureDetector(
              onTap: () {
                getUrl(menuItem.link, menuItem.judul);
              },
              child: SizedBox(
                width: itemWidth,
                height: 260, // Ensure each item has a consistent width
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 2, // Adjust the elevation as needed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        // ClipRRect widget is used to clip the child widget with rounded corners
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Container(
                          color: Colors.white,
                          height: 170,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: menuItem.gambar,
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
                              menuItem.judul,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              menuItem.keterangan,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                              overflow:
                                  TextOverflow.ellipsis, // Limit to 2 lines
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
