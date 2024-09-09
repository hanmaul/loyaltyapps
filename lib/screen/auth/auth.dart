import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loyalty/bloc/auth/auth_bloc.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/auth/get_otp.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:loyalty/screen/dashboard/dashboard.dart';
import 'package:loyalty/services/auth_service.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(databaseRepository: DatabaseRepository())
        ..add(SessionCheck()),
      child: Scaffold(
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is SignedIn) {
              return const Dashboard(page: 0);
            }
            if (state is InRegister) {
              return const Register();
            }
            if (state is UnRegistered) {
              return const GetOtp();
            }
            if (state is UserLoggedOut) {
              AuthService.signOut(context);
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
}
