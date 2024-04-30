import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContentAdds extends StatefulWidget {
  final String gambar;
  final String judul;
  final String isi;
  final String url;

  const ContentAdds({
    Key? key,
    required this.gambar,
    required this.judul,
    required this.isi,
    required this.url,
  }) : super(key: key);

  @override
  State<ContentAdds> createState() => _ContentAddsState();
}

class _ContentAddsState extends State<ContentAdds> {
  Future<void> getUrl(String urlWeb, String urlTitle) async {
    if (urlWeb != "") {
      Navigator.pushNamed(
        context,
        '/content',
        arguments: {'title': urlTitle, 'url': urlWeb},
      );
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
        getUrl(widget.url, widget.judul);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 2, // Adjust the elevation as needed
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            ClipRRect(
              // ClipRRect widget is used to clip the child widget with rounded corners
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Container(
                height: 190,
                width: double.infinity,
                // child: Image.asset(
                //   widget.gambar,
                //   fit: BoxFit.cover,
                // ),
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.isi,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
