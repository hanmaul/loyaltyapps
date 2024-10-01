import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loyalty/components/alert.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/webview/content.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
  int activeIndex = 0;

  Future<void> getUrl(String urlWeb, String urlTitle) async {
    DatabaseRepository databaseRepository = DatabaseRepository();
    final appVersion = await databaseRepository.loadUser(field: "appVersion");

    if (urlWeb.isNotEmpty) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => Content(
            title: urlTitle,
            url: urlWeb,
            appVersion: appVersion,
          ),
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
    final double addWidth =
        mediaQueryWidth < 900 ? mediaQueryWidth * 0.9 : mediaQueryWidth * 0.95;

    // Size calculations
    final double itemWidth = widget.mobile
        ? addWidth
        : mediaQueryWidth < 900
            ? (addWidth / 2) - (addWidth * 0.05)
            : (addWidth / 3) - (addWidth * 0.025);
    final double itemDistance =
        mediaQueryWidth < 900 ? addWidth * 0.05 : addWidth * 0.025;

    if (widget.mobile) {
      return Container(
        margin: const EdgeInsets.only(top: 15.0, bottom: 20.0),
        child: Column(
          children: [
            CarouselSlider(
              items: widget.adds.map<Widget>((item) {
                return GestureDetector(
                  onTap: () {
                    getUrl(item.link, item.judul);
                  },
                  child: Container(
                    color: Colors.white,
                    width: itemWidth,
                    height: 260,
                    child: Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Container(
                              color: Colors.white,
                              height: 170,
                              width: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: item.gambar,
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
                                  item.judul,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.keterangan,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
              options: CarouselOptions(
                height: 260,
                enlargeCenterPage: false,
                autoPlay: false,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: false,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    activeIndex = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            AnimatedSmoothIndicator(
              activeIndex: activeIndex,
              count: widget.adds.length,
              effect: const ScrollingDotsEffect(
                dotHeight: 6,
                dotWidth: 6,
                activeDotColor: Color(0xff0B60B0),
                dotColor: Colors.grey,
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          color: Colors.white,
          width: addWidth,
          child: Wrap(
            spacing: itemDistance, // Horizontal spacing between items
            runSpacing: itemDistance, // Vertical spacing between lines
            alignment: WrapAlignment.center,
            children: widget.adds.map((item) {
              return GestureDetector(
                onTap: () {
                  getUrl(item.link, item.judul);
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
                              imageUrl: item.gambar,
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
                                item.judul,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.keterangan,
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
}
