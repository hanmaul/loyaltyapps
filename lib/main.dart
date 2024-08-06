import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/services/firebase_api.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loyalty/firebase_options.dart';
import 'package:loyalty/routes.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();
    await Permission.camera.request();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseApi().initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => DatabaseRepository()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'KAMM Loyalty',
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF0B60B0)),
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
          onGenerateInitialRoutes: (String initialRoute) {
            return [generateRoute(RouteSettings(name: initialRoute))];
          },
          onGenerateRoute: generateRoute,
        ),
      ),
    );
  }
}
