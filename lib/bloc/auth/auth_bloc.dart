import 'package:bloc/bloc.dart';
import 'package:loyalty/data/repository/preferences_repository.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PrefRepository prefRepository;
  AuthBloc({required this.prefRepository}) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      final key = await prefRepository.getKey();
      final nama = await prefRepository.getName();
      if (event is SessionCheck) {
        try {
          if (key != "" && nama != "") {
            emit(SignedIn(message: 'Selamat Datang kembali'));
          } else if (key != "" && nama == "") {
            emit(InRegister(message: 'Silahkan daftar terlebih dahulu '));
          } else {
            emit(UnRegistered(message: 'Silahkan masukkan nomor anda'));
          }
        } catch (e) {
          emit(FailureLoadState(message: 'Gagal Memvalidasi Session $e'));
        }
      }
    });
  }
}
