import 'package:bloc/bloc.dart';
import 'package:loyalty/data/model/banner.dart';
import 'package:loyalty/data/model/highlight.dart';
import 'package:loyalty/data/model/promo.dart';
import 'package:loyalty/data/model/service.dart';
import 'package:meta/meta.dart';
import 'package:loyalty/data/repository/database_repository.dart';

part 'content_event.dart';
part 'content_state.dart';

// class ContentBloc extends Bloc<ContentEvent, ContentState> {
//   final DatabaseRepository databaseRepository;
//
//   ContentBloc({
//     required this.databaseRepository,
//   }) : super(ContentInitial()) {
//     on<ContentEvent>(
//       (event, emit) async {
//         if (event is LoadEvent || event is PullToRefreshEvent) {
//           emit(LoadingState());
//           try {
//             if (event is PullToRefreshEvent) {
//               await databaseRepository.clearContent();
//               await InAppWebViewController.clearAllCache();
//             }
//
//             final banners = databaseRepository.loadAllBanner();
//             final highlights = databaseRepository.loadAllHighlight();
//             final services = databaseRepository.loadAllService();
//             final promos = databaseRepository.loadAllPromo();
//
//             List<Banner> banner = await banners;
//             List<Highlight> highlight = await highlights;
//             List<Service> service = await services;
//             List<Promo> promo = await promos;
//
//             emit(LoadedState(
//               banner: banner,
//               highlight: highlight,
//               service: service,
//               promo: promo,
//             ));
//           } catch (e) {
//             emit(FailureLoadState(
//                 message:
//                     'Gagal memuat menu. Silakan periksa koneksi internet Anda dan coba lagi.'));
//           }
//         }
//       },
//     );
//   }
// }

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final DatabaseRepository databaseRepository;

  ContentBloc({
    required this.databaseRepository,
  }) : super(ContentInitial()) {
    on<ContentEvent>((event, emit) async {
      emit(LoadingState());

      if (event is LoadEvent) {
        // Check if local storage has data
        final bannersFromStorage = await databaseRepository.loadAllBanner();
        final highlightsFromStorage =
            await databaseRepository.loadAllHighlight();
        final servicesFromStorage = await databaseRepository.loadAllService();
        final promosFromStorage = await databaseRepository.loadAllPromo();

        // If local storage has data, load it from storage
        if (bannersFromStorage.isNotEmpty &&
            highlightsFromStorage.isNotEmpty &&
            servicesFromStorage.isNotEmpty &&
            promosFromStorage.isNotEmpty) {
          emit(LoadedState(
            banner: bannersFromStorage,
            highlight: highlightsFromStorage,
            service: servicesFromStorage,
            promo: promosFromStorage,
          ));
          print('LOAD EVENT - STORAGE NOT EMPTY');
        } else {
          // If local storage is empty, fetch from API
          print('LOAD EVENT - STORAGE EMPTY');
          await _fetchAndStoreMenu(emit);
        }
      }

      if (event is PullToRefreshEvent) {
        print('PULL TO REFRESH');

        // Always fetch fresh data from the API when PullToRefreshEvent is triggered
        await _fetchAndStoreMenu(emit);
      }
    });
  }

  Future<void> _fetchAndStoreMenu(Emitter<ContentState> emit) async {
    try {
      // Fetch data from API
      final bannersFromApi = await databaseRepository.fetchBannersFromApi();
      final highlightsFromApi =
          await databaseRepository.fetchHighlightsFromApi();
      final servicesFromApi = await databaseRepository.fetchServicesFromApi();
      final promosFromApi = await databaseRepository.fetchPromosFromApi();

      // Clear storage and save new data from API
      await databaseRepository.clearContent();

      await databaseRepository.saveBanners(bannersFromApi);
      await databaseRepository.saveHighlights(highlightsFromApi);
      await databaseRepository.saveServices(servicesFromApi);
      await databaseRepository.savePromos(promosFromApi);

      // Emit loaded state with the new data
      emit(LoadedState(
        banner: bannersFromApi,
        highlight: highlightsFromApi,
        service: servicesFromApi,
        promo: promosFromApi,
      ));
      print('FETCH MENU SUCCESS');
    } catch (e) {
      // Handle error, fall back to local storage if available
      final bannersFromStorage = await databaseRepository.loadAllBanner();
      final highlightsFromStorage = await databaseRepository.loadAllHighlight();
      final servicesFromStorage = await databaseRepository.loadAllService();
      final promosFromStorage = await databaseRepository.loadAllPromo();

      if (bannersFromStorage.isNotEmpty ||
          highlightsFromStorage.isNotEmpty ||
          servicesFromStorage.isNotEmpty ||
          promosFromStorage.isNotEmpty) {
        emit(LoadedState(
          banner: bannersFromStorage,
          highlight: highlightsFromStorage,
          service: servicesFromStorage,
          promo: promosFromStorage,
        ));
        print('FETCH MENU FAILED');
      } else {
        emit(FailureLoadState(
            message:
                'Gagal memuat menu.\nMohon periksa koneksi internet Anda dan coba lagi'));
      }
    }
  }
}
