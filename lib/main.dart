import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/app.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/navigator/route_list.dart';
import 'package:restaurant_fifo/navigator/routes.dart';
import 'package:restaurant_fifo/pages/customer/Cart/view_model/cart_view_model.dart';
import 'package:restaurant_fifo/pages/main/repositories/main_repository.dart';
import 'package:restaurant_fifo/pages/main/view_model/main_view_model.dart';
import 'package:restaurant_fifo/utils/device_type_util.dart';
import 'package:google_fonts/google_fonts.dart';

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
        // Tambahkan ini agar CartViewModel bersifat Global
        ChangeNotifierProvider(create: (_) => CartViewModel()), 
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
          
          /// CATATAN: Jika MainViewModel dan MainRepository belum dibuat, 
          /// kode MvvmBuilder ini akan merah/error. 
          /// Anda harus membuat file-nya terlebih dahulu atau hapus bungkus MvvmBuilder ini sementara.
          return MvvmBuilder(
            key: const ValueKey('main'),
            viewModel: MainViewModel(MainRepository()), 
            view: (context) {
              return MaterialApp(
                title: 'Restaurant FIFO', // Saya ubah judulnya dari Game Hub
                navigatorKey: navigatorKey,
                scaffoldMessengerKey: snackBarKey,
                
                // --- PERUBAHAN UTAMA DI SINI ---
                // Mengubah rute awal langsung ke halaman LayoutSelector
                initialRoute: RouteList.AuthSelector, 
                // -------------------------------
                
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
          );
        },
      ),
    );
  }
}
