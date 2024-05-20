import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:loyalty/data/model/promo.dart';
import 'package:loyalty/data/model/service.dart';
import 'package:loyalty/data/model/banner.dart';
import 'package:loyalty/data/model/highlight.dart';
import 'package:loyalty/data/repository/content_repository.dart';
import 'package:loyalty/data/repository/preferences_repository.dart';

part 'content_event.dart';
part 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final ContentRepository contentRepository;
  final PrefRepository prefRepository;

  ContentBloc({required this.contentRepository, required this.prefRepository})
      : super(ContentInitial()) {
    on<ContentEvent>((event, emit) async {
      if (event is LoadEvent || event is PullToRefreshEvent) {
        emit(LoadingState());
        try {
          final banners = await contentRepository.getBanner();
          final highlights = await contentRepository.getHighlight();
          final services = await contentRepository.getService();
          final promos = await contentRepository.getPromo();
          //await prefRepository.firstAccessFalse();
          emit(LoadedState(
            banner: banners,
            highlight: highlights,
            service: services,
            promo: promos,
          ));
        } catch (e) {
          emit(FailureLoadState(message: 'Sorry, the server is busy now'));
        }
      }

      if (event is LoadAkun) {
        emit(LoadingState());
        try {
          const url =
              'http://mobilekamm.ddns.net:8065/m_mlp/mobile/akun/profile?key=d0775532e6ae9b934fdfea4b8b16872c';
          emit(LoadedAkun(url: url));
        } catch (e) {
          emit(FailureLoadState(message: 'Gagal memuat akun $e'));
        }
      }
    });
  }
}
