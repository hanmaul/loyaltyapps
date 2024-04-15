import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loyalty/components/custom_appbar.dart';
import 'package:loyalty/components/dashboard/content_keuangan.dart';
import 'package:loyalty/components/dashboard/content_services.dart';
import 'package:loyalty/components/dashboard/content_adds.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  late Future<List<Map<String, dynamic>>> _menuServices;
  late Future<List<Map<String, dynamic>>> _menuKeuangan;
  late Future<List<Map<String, dynamic>>> _listBanner;
  late Future<List<Map<String, dynamic>>> _listPromo;

  int currentPageIndex = 0;
  String nama = "";
  String cust_id = "";
  String status = "";
  String key = "";

  @override
  void initState() {
    super.initState();
    getPref();
    getData();
  }

  void getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      nama = pref.getString("nama")!;
      cust_id = pref.getString("cust_id")!;
      status = pref.getString("status")!;
      key = pref.getString("key")!;
    });
  }

  Future<List<Map<String, dynamic>>> fetchContent(String type) async {
    final response = await http.post(
      Uri.parse(
          "https://www.kamm-group.com:8070/fapi/newcontent2?key=3356271533a91b348974492cba3b7d6c"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Cust_id': cust_id,
        // 'versi': '1',
        // 'apl': '1',
        // 'Location': '1',
        // 'FCM': '1',
      }),
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final menuServices = jsonData['menu1'] as List<dynamic>;
      final menuKeuangan = jsonData['menuheader'] as List<dynamic>;
      final listBanner = jsonData['banner'] as List<dynamic>;
      final listPromo = jsonData['menulist'] as List<dynamic>;
      if (type == "service") {
        return menuServices.map((item) {
          return {
            'icon': item['mGambar'],
            'title': item['mJudul'],
            'url': item['mLink'] + cust_id,
          };
        }).toList();
      } else if (type == "keuangan") {
        return menuKeuangan.map((item) {
          if (item['mKeterangan'] != "") {
            return {
              'icon': item['mGambar'],
              'title': item['mJudul'],
              'total': item['mKeterangan'],
              'url': item['mLink'],
            };
          } else {
            return {
              'icon': item['mGambar'],
              'title': item['mJudul'],
              'total': "500.000",
              'url': item['mLink'],
            };
          }
        }).toList();
      } else if (type == "banner") {
        return listBanner.map((url) {
          return {
            'url': url,
          };
        }).toList();
        // return [
        //   {'url': 'assets/images/Banner.jpeg'},
        //   {'url': 'assets/images/Iklan1.jpeg'},
        //   {'url': 'assets/images/Iklan2.jpeg'},
        //   {'url': 'assets/images/Iklan3.jpeg'},
        // ];
      } else if (type == "promo") {
        return listPromo.map((item) {
          return {
            'image': item['mGambar'],
            'title': item['mJudul'],
            'body': item['mKeterangan'],
            'url': item['mLink'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load menu');
      }
    } else {
      throw Exception('Failed to load menu data');
    }
  }

  Future<void> getData() async {
    _menuServices = fetchContent("service");
    _menuKeuangan = fetchContent("keuangan");
    _listBanner = fetchContent("banner");
    _listPromo = fetchContent("promo");
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: "Hai, ",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            children: [
              TextSpan(
                text: nama,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        backgroundColor: const Color(0xff0B60B0),
      ),
      //CustomAppBar(title: nama),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Stack(
                  children: [
                    Container(
                      color: Colors.white,
                      height: 350,
                      width: double.infinity,
                    ),
                    // Container(
                    //   height: 212,
                    //   width: double.infinity,
                    //   child: Image.asset(
                    //     "assets/images/Banner.jpeg",
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _listBanner,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            color: Colors.white,
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return CarouselSlider(
                            items: snapshot.data!.map<Widget>((item) {
                              return Container(
                                child: CachedNetworkImage(
                                  imageUrl: item['url'],
                                ),
                                // child: Image.asset(
                                //   item['url'],
                                //   fit: BoxFit.cover,
                                // ),
                              );
                            }).toList(),
                            options: CarouselOptions(
                              height: 212.0, // Adjust the height as needed
                              enlargeCenterPage: true,
                              autoPlay: true,
                              aspectRatio: 16 / 9,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enableInfiniteScroll: true,
                              autoPlayAnimationDuration:
                                  Duration(milliseconds: 800),
                              viewportFraction: 1,
                            ),
                          );
                        }
                      },
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 190, left: 16, right: 16),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 0.1,
                          color: Colors.grey,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 4,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      height: 140,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Keuangan Anda',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _menuKeuangan,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  color: Colors.white,
                                );
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<Map<String, dynamic>> menuData =
                                    snapshot.data!;
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ContentKeuangan(
                                      icon: menuData[0]['icon'],
                                      title: menuData[0]['title'],
                                      total: menuData[0]['total'],
                                      url: menuData[0]['url'],
                                    ),
                                    ContentKeuangan(
                                      icon: menuData[1]['icon'],
                                      title: menuData[1]['title'],
                                      total: menuData[1]['total'],
                                      url: menuData[1]['url'],
                                    ),
                                    ContentKeuangan(
                                      icon: menuData[2]['icon'],
                                      title: menuData[2]['title'],
                                      total: menuData[2]['total'],
                                      url: menuData[2]['url'],
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {},
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Informasi lebih lanjut',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_right_alt,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  color: Colors.white,
                  width: double.infinity,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _menuServices,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          color: Colors.white,
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final menuItems = snapshot.data!;
                        return GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: menuItems.map((menuItem) {
                            return ContentServices(
                              icon: menuItem['icon']!,
                              title: menuItem['title']!,
                              url: menuItem['url']!,
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  color: Colors.white,
                  width: double.infinity,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _listPromo,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          color: Colors.white,
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<Map<String, dynamic>> menuData = snapshot.data!;
                        // return ListView.builder(
                        //   physics: const NeverScrollableScrollPhysics(),
                        //   itemCount: menuData.length,
                        //   itemBuilder: (context, index) {
                        //     return ContentAdds(
                        //       gambar: menuData[index]['image'],
                        //       judul: menuData[index]['title'],
                        //       isi: menuData[index]['body'],
                        //       url: menuData[index]['url'],
                        //     );
                        //   },
                        // );
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ContentAdds(
                              gambar: menuData[0]['image'],
                              judul: menuData[0]['title'],
                              isi: menuData[0]['body'],
                              url: menuData[0]['url'],
                            ),
                            ContentAdds(
                              gambar: menuData[1]['image'],
                              judul: menuData[1]['title'],
                              isi: menuData[1]['body'],
                              url: menuData[1]['url'],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                //   color: Colors.white,
                //   width: double.infinity,
                //   child: const Column(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       ContentAdds(
                //         gambar: "assets/images/Iklan1.jpeg",
                //         judul: "Sikat Promo Meriah Maret",
                //         isi:
                //             "Ada banyak promo hemat dan dapatkan banyak hadiah menarik. Yuk pakai sebelum kehabisan!",
                //         url: "",
                //       ),
                //       ContentAdds(
                //         gambar: "assets/images/Iklan2.jpeg",
                //         judul: "Promo HUT KAMM",
                //         isi:
                //             "Kado Spesial khusus pengajuan melalui website kamm-group.com",
                //         url: "",
                //       ),
                //       ContentAdds(
                //         gambar: "assets/images/Iklan3.jpeg",
                //         judul: "Sikat Promo Bulan Juli",
                //         isi:
                //             "Pembiayaan dengan Jaminan BPKB, Kendaraan dan Sertifikat Rumah",
                //         url: "",
                //       ),
                //     ],
                //   ),
                // ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
