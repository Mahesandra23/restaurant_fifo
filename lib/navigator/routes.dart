import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/layout/auth_layout.dart';
import 'package:restaurant_fifo/layout/customer_layout.dart';
import 'package:restaurant_fifo/layout/kitchen_layout.dart';
import 'package:restaurant_fifo/navigator/route_list.dart';

  enum RouteTransition { slide, fade }  

  class Routes {
    // route name dan widget page disini
    // tambah route baru di _routes
    static final Map<String, WidgetBuilder> _routes = {
      RouteList.AuthSelector: (BuildContext context) => const AuthLayout(),
      RouteList.customerHome: (BuildContext context) => const CustomerLayout(),
      RouteList.kitchenHome: (BuildContext context) => const KitchenLayout(),

    };

    Map<String, WidgetBuilder> get allRoutes => _routes;

    static Route getRouteGenerate(RouteSettings settings) =>
        _routeGenerate(settings);

    static Route _routeGenerate(RouteSettings settings) {
      switch (settings.name) {
        // case RouteList.activeRoom:
        //   final args = settings.arguments as Map<String, dynamic>;
        //   return _buildRoute(
        //     settings: settings,
        //     builder: ActiveRoomView(roomId: args['roomId']),
        //   );

        // case RouteList.recruitingRoom:
        //   final args = settings.arguments as Map<String, dynamic>;
        //   return _buildRoute(
        //     settings: settings,
        //     builder: RecruitingRoomView(roomId: args['roomId']),
        //   );

        // case RouteList.closedRoom:
        //   final args = settings.arguments as Map<String, dynamic>;
        //   return _buildRoute(
        //     settings: settings,
        //     builder: ClosedRoomView(roomId: args['roomId']),
        //   );
        // EXAMPLE
        // case RouteList.profile:
        //   String? params;
        //   if (settings.arguments is String) {
        //     params = settings.arguments as String;
        //     return _buildRoute(
        //       settings: settings,
        //       builder: ProfilePage(
        //         params: params,
        //       ),
        //     );
        //   }
        //   return _errorRoute();

        default:
          return MaterialPageRoute(
            builder: getRouteByName(settings.name!)!,
            maintainState: false,
            fullscreenDialog: false,
          );
      }
    }

    static WidgetBuilder? getRouteByName(String name) {
      if (!_routes.containsKey(name)) {
        return _routes[RouteList.errorRoute];
      }
      return _routes[name];
    }

    static Route _errorRoute() {
      return MaterialPageRoute(builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Error"),
          ),
        );
      });
    }

    /// T2 for view model
    /// T for class generic MaterialPageRoute

    static PageRoute _buildRoute<T, T2 extends Listenable?>({
      required RouteSettings settings,
      required Widget builder,
      viewModel,
      bool fullScreenDialog = false,
      RouteTransition? routeTransition,
    }) {
      if (routeTransition != null) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) {
            if (!(null is T2)) {
              return ListenableProvider<T2>.value(
                value: viewModel,
                builder: (context, child) => builder,
              );
            } else {
              return builder;
            }
          },
          fullscreenDialog: fullScreenDialog,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (routeTransition == RouteTransition.slide) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            }

            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      }

      return MaterialPageRoute<T>(
        settings: settings,
        builder: (context) {
          if (!(null is T2)) {
            return ListenableProvider<T2>.value(
              value: viewModel,
              builder: (context, child) => builder,
            );
          } else {
            return builder;
          }
        },
        fullscreenDialog: fullScreenDialog,
      );
    }
  }
