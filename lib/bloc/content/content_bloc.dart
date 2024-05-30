import 'package:bloc/bloc.dart';
import 'package:loyalty/data/model/banner.dart';
import 'package:loyalty/data/model/highlight.dart';
import 'package:loyalty/data/model/promo.dart';
import 'package:loyalty/data/model/service.dart';
import 'package:meta/meta.dart';
import 'package:loyalty/data/repository/preferences_repository.dart';
import 'package:loyalty/data/repository/content_repository.dart';

part 'content_event.dart';
part 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final PrefRepository prefRepository;
  final ContentRepository contentRepository;

  ContentBloc({
    required this.prefRepository,
    required this.contentRepository,
  }) : super(ContentInitial()) {
    on<ContentEvent>(
      (event, emit) async {
        if (event is LoadEvent || event is PullToRefreshEvent) {
          emit(LoadingState());
          try {
            if (event is PullToRefreshEvent) {
              await contentRepository.clearDatabase();
            }

            final banners = contentRepository.loadAllBanner();
            final highlights = contentRepository.loadAllHighlight();
            final services = contentRepository.loadAllService();
            final promos = contentRepository.loadAllPromo();

            List<Banner> banner = await banners;
            List<Highlight> highlight = await highlights;
            List<Service> service = await services;
            List<Promo> promo = await promos;

            emit(LoadedState(
              banner: banner,
              highlight: highlight,
              service: service,
              promo: promo,
            ));
          } catch (e) {
            emit(FailureLoadState(message: '$e'));
          }
        }
      },
    );
  }
}
