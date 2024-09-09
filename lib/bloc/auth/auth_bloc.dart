import 'package:bloc/bloc.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/services/auth_service.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final DatabaseRepository databaseRepository;
  AuthBloc({required this.databaseRepository}) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      final key = await databaseRepository.loadUser(field: 'key');
      final isRegistered = await databaseRepository.isRegistered();
      final custId = await databaseRepository.loadUser(field: 'custId');
      bool keyExists = await AuthService.keyExists(custId: custId, key: key);

      if (event is SessionCheck) {
        try {
          if (key != "" && isRegistered) {
            if (keyExists) {
              emit(SignedIn(message: 'Selamat Datang kembali'));
            } else {
              emit(UserLoggedOut());
            }
          } else if (key != "" && !isRegistered) {
            if (keyExists) {
              emit(InRegister(message: 'Silahkan daftar terlebih dahulu '));
            } else {
              emit(UserLoggedOut());
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
