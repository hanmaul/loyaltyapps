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

    const double firstLayer = 297.0;
    const double carouselHeight = 190.0;

    const double highlightHeight = 104;
    final highlightWidth = mediaQueryWidth * 0.9;

    final promoWidth = mediaQueryWidth * 0.95;

    final bool mobile = mediaQueryWidth < 600;

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
                                  height: firstLayer,
                                  width: mediaQueryWidth,
                                ),
                                _buildCarousel(state.banner, carouselHeight),
                                Positioned(
                                  bottom: firstLayer * 0.05,
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
                                    width: highlightWidth,
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
                                            fontSize: highlightHeight * 0.13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: highlightHeight * 0.02),
                                          child: _buildHighlight(
                                              state.highlight, highlightHeight),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: highlightHeight * 0.20),
                              color: Colors.white,
                              width: mediaQueryWidth,
                              child: _buildServices(
                                  state.service, mediaQueryWidth, mobile),
                            ),
                            Center(
                              child: Container(
                                color: Colors.white,
                                width: promoWidth,
                                child: _buildPromo(state.promo, mobile),
                              ),
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
        height: carouselHeight, // Adjust the height as needed
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

  Widget _buildServices(List<dynamic> service, double cardSize, bool mobile) {
    final double serviceWidth =
        mobile ? cardSize * 0.7 : (cardSize * 0.7) / 1.7;
    final double padding = (cardSize - serviceWidth) / 2;
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: padding),
      children: service.map((menuItem) {
        return ContentServices(
          icon: menuItem.gambar,
          title: menuItem.judul,
          url: menuItem.link!,
          cardSize: serviceWidth,
        );
      }).toList(),
    );
  }

  Widget _buildPromo(List<dynamic> promo, bool mobile) {
    if (mobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: promo
            .map((p) => ContentAdds(
                  gambar: p.gambar,
                  judul: p.judul,
                  isi: p.keterangan,
                  url: p.link,
                  mobile: mobile,
                ))
            .toList(),
      );
    } else {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: promo.length,
        itemBuilder: (context, index) {
          return ContentAdds(
            gambar: promo[index].gambar,
            judul: promo[index].judul,
            isi: promo[index].keterangan,
            url: promo[index].link,
            mobile: mobile,
          );
        },
      );
    }
  }
}
