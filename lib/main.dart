import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:restaurant_fifo/app.dart';
import 'package:restaurant_fifo/core/providers/session_provider.dart';
import 'package:restaurant_fifo/navigator/route_list.dart';
import 'package:restaurant_fifo/navigator/routes.dart';
import 'package:restaurant_fifo/pages/customer/Cart/view_model/cart_view_model.dart';
import 'package:restaurant_fifo/utils/device_type_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pastikan method init() di App Anda tidak error
  await App().init(); 
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await DeviceTypeUtil.init();

  GoogleFonts.montserrat();
  await ScreenUtil.ensureScreenSize();
  
  runApp(
    MultiProvider(
      providers: [
        // Cart bersifat Global agar bisa diakses dari Menu maupun halaman Cart
        ChangeNotifierProvider(create: (_) => CartViewModel()), 
        // Session bersifat Global agar seluruh aplikasi tahu siapa yang sedang login
        ChangeNotifierProvider(create: (_) => SessionProvider()..fetchCurrentUser()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  static final GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: DeviceTypeUtil().isTablet
          ? const Size(768, 1024)
          : const Size(360, 640),
      builder: (context, child) => LayoutBuilder(
        builder: (context, constraints) {
          
          // MvvmBuilder sudah DIHAPUS karena tidak diperlukan di root aplikasi
          return MaterialApp(
            title: 'Restaurant FIFO',
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: snackBarKey,
            debugShowCheckedModeBanner: false, // Tambahan opsional agar tulisan "Debug" hilang
            
            // Mengubah rute awal langsung ke halaman AuthSelector / Login
            initialRoute: RouteList.AuthSelector, 
            
            routes: Routes().allRoutes,
            onGenerateRoute: Routes.getRouteGenerate,
            navigatorObservers: [routeObserver],
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: Builder(
                  builder: (context) => SafeArea(
                    top: false,
                    bottom: Platform.isAndroid,
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}