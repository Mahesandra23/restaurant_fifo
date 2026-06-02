import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:restaurant_fifo/app.dart';
import 'package:restaurant_fifo/core/providers/cart_provider.dart';
import 'package:restaurant_fifo/core/providers/session_provider.dart';
import 'package:restaurant_fifo/navigator/route_list.dart';
import 'package:restaurant_fifo/navigator/routes.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
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
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // Session bersifat Global agar seluruh aplikasi tahu siapa yang sedang login
        ChangeNotifierProvider(
          create: (_) => SessionProvider()..fetchCurrentUser(),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
  static final GlobalKey<ScaffoldMessengerState> snackBarKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
            debugShowCheckedModeBanner:
                false, // Tambahan opsional agar tulisan "Debug" hilang
            // Mengubah rute awal langsung ke halaman AuthSelector / Login
            initialRoute: RouteList.AuthSelector,

            theme: ThemeData(
              scaffoldBackgroundColor: AppRestaurantColors.background,

              canvasColor: Colors.white,

              appBarTheme: const AppBarTheme(
                iconTheme: IconThemeData(
                  color: Colors.white,
                ), // Tombol back & ikon kiri otomatis putih
                actionsIconTheme: IconThemeData(
                  color: Colors.white,
                ), // Ikon menu kanan otomatis putih
              ),

              // 2. MENGUBAH WARNA CARD/LIST MENJADI PUTIH BERSIH
              cardTheme: const CardThemeData(
                // <--- Tambahkan kata 'Data' di sini
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ), // Gunakan .all agar bisa di-const
                ),
              ),

              // Menyesuaikan gaya form input secara global
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppRestaurantColors.primary,
                    width: 2.0,
                  ),
                ),
                floatingLabelStyle: TextStyle(
                  color: AppRestaurantColors.primary,
                ),
              ),
            ),

            routes: Routes().allRoutes,
            onGenerateRoute: Routes.getRouteGenerate,
            navigatorObservers: [routeObserver],
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);

              final bool forceMobileAppView = mediaQuery.size.width > 600;

              Widget app = MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: SafeArea(
                  top: false,
                  bottom: !kIsWeb,
                  child: child ?? const SizedBox.shrink(),
                ),
              );

              if (forceMobileAppView) {
                return Container(
                  color: const Color(0xFFE5E5E5),
                  child: Center(
                    child: SizedBox(
                      width: 430,
                      height: mediaQuery.size.height,
                      child: Material(
                        elevation: 8,
                        clipBehavior: Clip.hardEdge,
                        borderRadius: BorderRadius.circular(12),
                        child: app,
                      ),
                    ),
                  ),
                );
              }

              return app;
            },
          );
        },
      ),
    );
  }
}
