import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loyalty/bloc/content/content_bloc.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/components/dashboard/content_keuangan.dart';
import 'package:loyalty/components/dashboard/content_services.dart';
import 'package:loyalty/components/dashboard/content_adds.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';
import 'package:loyalty/screen/response/server_error.dart';
import 'package:loyalty/screen/loading/shimmer_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InternetAwareWidget(
      child: BlocProvider(
        create: (context) => ContentBloc(
          databaseRepository: DatabaseRepository(),
        )..add(LoadEvent()),
        child: Scaffold(
          body: BlocBuilder<ContentBloc, ContentState>(
            builder: (context, state) {
              if (state is LoadedState) {
                return RefreshIndicator(
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverPadding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            Stack(
                              children: [
                                Container(
                                  color: Colors.white,
                                  height: 350,
                                  width: double.infinity,
                                ),
                                _buildCarousel(state.banner),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 190, left: 16, right: 16),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      _buildHighlight(state.highlight),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () {},
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              color: Colors.white,
                              width: double.infinity,
                              child: _buildServices(state.service),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              color: Colors.white,
                              width: double.infinity,
                              child: _buildPromo(state.promo),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  onRefresh: () async {
                    context.read<ContentBloc>().add(PullToRefreshEvent());
                  },
                );
              }
              if (state is LoadingState) {
                return const ShimmerHome();
              }
              if (state is FailureLoadState) {
                return ServerError(
                  message: state.message,
                  onRetry: () async {
                    context.read<ContentBloc>().add(PullToRefreshEvent());
                  },
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(List<dynamic> banners) {
    return CarouselSlider(
      items: banners.map<Widget>((item) {
        return Container(
          child: CachedNetworkImage(
            imageUrl: item.gambar,
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: 212.0, // Adjust the height as needed
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 1,
      ),
    );
  }

  Widget _buildHighlight(List<dynamic> highlight) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the maximum length of the total values
    int maxLength = highlight
        .map((h) => h.keterangan.length)
        .reduce((a, b) => a > b ? a : b);

    // Determine the font size based on the maximum length and screen width
    double fontSize;
    if (maxLength > 11) {
      fontSize = screenWidth < 400 ? 8 : (screenWidth < 500 ? 10 : 12);
    } else if (maxLength > 9) {
      fontSize = screenWidth < 400 ? 10 : (screenWidth < 500 ? 12 : 14);
    } else {
      fontSize = screenWidth < 400 ? 12 : (screenWidth < 500 ? 14 : 16);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: highlight
          .map((h) => ContentKeuangan(
                icon: h.gambar,
                title: h.judul,
                total: h.keterangan,
                url: h.link,
                fontSize: fontSize, // Pass the calculated fontSize
              ))
          .toList(),
    );
  }

  Widget _buildServices(List<dynamic> service) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: service.map((menuItem) {
        return ContentServices(
          icon: menuItem.gambar,
          title: menuItem.judul,
          url: menuItem.link!,
        );
      }).toList(),
    );
  }

  Widget _buildPromo(List<dynamic> promo) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: promo
          .map((p) => ContentAdds(
                gambar: p.gambar,
                judul: p.judul,
                isi: p.keterangan,
                url: p.link,
              ))
          .toList(),
    );
  }
}
