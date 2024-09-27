import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loyalty/components/alert.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/webview/content.dart';
import 'package:loyalty/services/fetch_location.dart';

class ContentServices extends StatefulWidget {
  final List<dynamic> service;

  const ContentServices({
    Key? key,
    required this.service,
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

  // Function to handle re-order logic
  Future<void> handleReorder(String urlWeb, String urlTitle) async {
    FetchLocation fetchLocation = FetchLocation();

    // Validate GPS and permissions
    bool gpsValid = await fetchLocation.validateGPSAndPermissions(context);

    if (gpsValid) {
      // If validation passed, proceed to get the URL
      await getUrl(urlWeb, urlTitle);
    } else {
      // Handle failure case, maybe show a dialog or log the event
      debugPrint('GPS or Location Permission is required.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // size
    const double imgSize = 74;
    const double boxSize = 52;
    const double lableSize = 11;
    const double itemDistance = 26.0;

    // layout size
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    final bool mobile = mediaQueryWidth < 600;
    const double mobileWidth = (3 * imgSize) + (4 * itemDistance);
    final double tabWidth = mediaQueryWidth * 0.7;
    final double serviceWidth = mobile ? mobileWidth : tabWidth;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 18.0),
        color: Colors.white,
        width: serviceWidth, // Adjust the width as needed
        child: Wrap(
          spacing: itemDistance, // Adjust spacing between items
          runSpacing: itemDistance, // Adjust spacing between lines
          alignment: WrapAlignment.center, // Center align items
          children: widget.service.map((menuItem) {
            return GestureDetector(
              onTap: () async {
                if (menuItem.link.contains('re-order')) {
                  // Call the validation for GPS and permissions before proceeding
                  await handleReorder(menuItem.link, menuItem.judul);
                } else {
                  // Directly call getUrl if no need for GPS validation
                  await getUrl(menuItem.link, menuItem.judul);
                }
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
  }
}
