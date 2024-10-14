import 'package:bloc/bloc.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/services/auth_service.dart';
import 'package:loyalty/services/internet_service.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final DatabaseRepository databaseRepository;
  final InternetService internetService;

  AuthBloc({
    required this.databaseRepository,
    required this.internetService,
  }) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      final key = await databaseRepository.loadUser(field: 'key');
      final isRegistered = await databaseRepository.isRegistered();
      final isLogout = await databaseRepository.getLogoutSession();

      final custId = await databaseRepository.loadUser(field: 'custId');
      final hasInternet = await internetService.hasActiveInternetConnection();
      bool keyExists = true;

      if (event is SessionCheck) {
        try {
          if (key.isNotEmpty) {
            if (hasInternet) {
              keyExists = await AuthService.keyExists(custId: custId, key: key);
            }

            if (isLogout != null || !keyExists) {
              emit(UserLoggedOut());
            } else {
              if (isRegistered) {
                emit(SignedIn(message: 'Selamat Datang kembali'));
              } else {
                emit(InRegister(message: 'Silahkan daftar terlebih dahulu'));
              }
            }
          } else {
            emit(UnRegistered(message: 'Silahkan masukkan nomor anda'));
          }
        } catch (e) {
          emit(FailureLoadState(message: 'Gagal Memvalidasi Session'));
        }
      }
    });
  }
}
