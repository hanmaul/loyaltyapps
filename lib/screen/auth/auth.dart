import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loyalty/bloc/auth/auth_bloc.dart';
import 'package:loyalty/data/repository/preferences_repository.dart';
import 'package:loyalty/data/repository/webview_repository.dart';
import 'package:loyalty/screen/auth/get_otp.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:loyalty/screen/dashboard.dart';

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
      create: (context) =>
          AuthBloc(prefRepository: PrefRepository())..add(SessionCheck()),
      child: Scaffold(
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is SignedIn) {
              return const Dashboard(page: 0);
            }
            if (state is InRegister) {
              return FutureBuilder<String>(
                future: WebviewRepository().getUrlRegister(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // or your own loading widget
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Register(url: snapshot.data!);
                  }
                },
              );
            }
            if (state is UnRegistered) {
              return const getOtp();
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
