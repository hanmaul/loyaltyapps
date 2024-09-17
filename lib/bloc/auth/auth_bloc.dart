import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/services/auth_service.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final DatabaseRepository databaseRepository;
  AuthBloc({required this.databaseRepository}) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      // Check internet connectivity first
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        emit(NoInternetState());
        return;
      }

      // Proceed if there's an internet connection
      final key = await databaseRepository.loadUser(field: 'key');
      final isRegistered = await databaseRepository.isRegistered();
      final custId = await databaseRepository.loadUser(field: 'custId');

      if (event is SessionCheck) {
        try {
          if (key.isNotEmpty) {
            bool keyExists =
                await AuthService.keyExists(custId: custId, key: key);

            if (isRegistered) {
              if (keyExists) {
                emit(SignedIn(message: 'Selamat Datang kembali'));
              } else {
                emit(UserLoggedOut());
              }
            } else {
              if (keyExists) {
                emit(InRegister(message: 'Silahkan daftar terlebih dahulu '));
              } else {
                emit(UserLoggedOut());
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
