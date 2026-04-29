import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/navigator/route_list.dart';
import 'package:restaurant_fifo/navigator/routes.dart';

void main() async {
  // Wajib dipanggil sebelum inisialisasi yang membutuhkan binding framework Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mengunci orientasi layar agar selalu portrait (berdiri)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Menjalankan aplikasi
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  static final GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Inisialisasi ukuran layar yang responsif menggunakan ScreenUtil
    return ScreenUtilInit(
      designSize: const Size(360, 640), // Ukuran desain standar mobile
      builder: (context, child) {
        return MaterialApp(
          title: 'Restaurant FIFO',
          debugShowCheckedModeBanner: false, // Menghilangkan pita debug di pojok kanan atas
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: snackBarKey,
          
          // --- Rute Pertama yang Akan Muncul ---
          initialRoute: RouteList.AuthSelector, 
          
          // Setting Navigator
          routes: Routes().allRoutes,
          onGenerateRoute: Routes.getRouteGenerate,
          navigatorObservers: [routeObserver],
          
          // Memastikan ukuran teks tidak berubah meski user membesarkan font dari setting HP
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: SafeArea(
                top: false,
                bottom: Platform.isAndroid,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}