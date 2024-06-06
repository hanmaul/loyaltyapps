import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/routes.dart';
import 'package:loyalty/services/firebase_api.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loyalty/firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => DatabaseRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Loyalty',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0B60B0)),
          primaryColor: const Color(0xFF0B60B0),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.grey.shade400,
            selectionColor: Colors.grey.shade300,
            selectionHandleColor: Colors.blue,
          ),
          useMaterial3: true,
        ),
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: routes,
      ),
    );
  }
}
