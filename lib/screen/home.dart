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
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final bool mobile = mediaQueryWidth < 600;

    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final bodyHeight =
        mediaQueryHeight - appBarHeight - MediaQuery.of(context).padding.top;

    final double carouselHeight =
        _calculateCarouselHeight(mediaQueryWidth, mobile, bodyHeight);

    const double highlightHeight = 104;
    final double highlightWidth =
        mobile ? mediaQueryWidth * 0.9 : mediaQueryWidth * 0.5;

    return InternetAwareWidget(
      child: BlocProvider(
        create: (context) => ContentBloc(
          databaseRepository: DatabaseRepository(),
        )..add(LoadEvent()),
        child: Scaffold(
          backgroundColor: Colors.white,
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
                                  width: mediaQueryWidth,
                                  height:
                                      carouselHeight + (highlightHeight * 1.05),
                                ),
                                _buildCarousel(state.banner, carouselHeight),
                                Positioned(
                                  top: carouselHeight * 0.95,
                                  left: (mediaQueryWidth - highlightWidth) / 2,
                                  right: (mediaQueryWidth - highlightWidth) / 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      highlightHeight * 0.12,
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
                                    height: highlightHeight,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Keuangan Anda",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: highlightHeight * 0.04),
                                          child: _buildHighlight(
                                              state.highlight, highlightHeight),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ContentServices(
                              service: state.service,
                            ),
                            ContentAdds(
                              adds: state.promo,
                              mobile: mobile,
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

  double _calculateCarouselHeight(
      double screenWidth, bool mobile, double screenHeight) {
    if (mobile) {
      return 190.0;
    } else {
      return screenHeight * 0.20;
    }
  }

  Widget _buildCarousel(List<dynamic> banners, double carouselHeight) {
    return CarouselSlider(
      items: banners.map<Widget>((item) {
        return Container(
          color: Colors.transparent,
          child: CachedNetworkImage(
            imageUrl: item.gambar,
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: carouselHeight,
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

  Widget _buildHighlight(List<dynamic> highlight, double cardSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: highlight
          .map((h) => ContentKeuangan(
                icon: h.gambar,
                title: h.judul,
                total: h.keterangan,
                url: h.link,
                cardSize: cardSize,
              ))
          .toList(),
    );
  }
}
