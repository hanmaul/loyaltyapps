import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loyalty/bloc/content/content_bloc.dart';
import 'package:loyalty/data/repository/content_repository.dart';
import 'package:loyalty/data/repository/preferences_repository.dart';
import 'package:loyalty/services/fetch_content.dart';
import 'package:loyalty/components/dashboard/content_keuangan.dart';
import 'package:loyalty/components/dashboard/content_services.dart';
import 'package:loyalty/components/dashboard/content_adds.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => ContentBloc(
          contentRepository: ContentRepository(dataContent: DataContent()),
          prefRepository: PrefRepository())
        ..add(LoadEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<String>(
            future: PrefRepository().getName(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return RichText(
                    text: TextSpan(
                      text: "Hai, ",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: snapshot.data,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  );
                }
              }
            },
          ),
          backgroundColor: const Color(0xff0B60B0),
        ),
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
                                    _buildHighligt(state.highlight),
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
                            padding: const EdgeInsets.symmetric(horizontal: 40),
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
              return Center(
                child: LoadingAnimationWidget.waveDots(
                  color: const Color(0xff0B60B0),
                  size: 32,
                ),
              );
            }
            if (state is FailureLoadState) {
              return Center(
                child: Text(state.message),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildCarousel(List<dynamic> banners) {
    return CarouselSlider(
      items: banners.map<Widget>((item) {
        return Container(
          child: CachedNetworkImage(
            imageUrl: item.url,
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

  Widget _buildHighligt(List<dynamic> highlight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ContentKeuangan(
          icon: highlight[0].gambar,
          title: highlight[0].judul,
          total: highlight[0].keterangan,
          url: highlight[0].link,
        ),
        ContentKeuangan(
          icon: highlight[1].gambar,
          title: highlight[1].judul,
          total: highlight[1].keterangan,
          url: highlight[1].link,
        ),
        ContentKeuangan(
          icon: highlight[2].gambar,
          title: highlight[2].judul,
          total: highlight[2].keterangan,
          url: highlight[2].link,
        ),
      ],
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
      children: [
        ContentAdds(
          gambar: promo[0].gambar,
          judul: promo[0].judul,
          isi: promo[0].keterangan,
          url: promo[0].link,
        ),
        ContentAdds(
          gambar: promo[1].gambar,
          judul: promo[1].judul,
          isi: promo[1].keterangan,
          url: promo[1].link,
        ),
      ],
    );
  }
}
