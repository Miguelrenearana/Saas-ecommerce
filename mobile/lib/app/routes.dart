import 'package:flutter/material.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/login_page.dart';
import '../features/catalog/catalog_controller.dart';
import '../features/catalog/product_detail_page.dart';
import '../features/cart/cart_page.dart';
import '../features/notifications/notification_controller.dart';
import '../features/notifications/notifications_page.dart';
import '../features/orders/checkout_page.dart';
import '../features/orders/orders_page.dart';
import '../features/reservations/reservation_create_page.dart';
import '../features/reservations/reservation_models.dart';
import '../features/reservations/reservations_page.dart';
import '../features/branches_map/branches_map_page.dart';
import 'main_navigation_shell.dart';

abstract final class AppRoutes {
  static const catalog = '/';
  static const cart = '/cart';
  static const management = '/management';
  static const account = '/account';
  static const reservations = '/reservations';
  static const reservationCreate = '/reservation-create';
  static const orders = '/orders';
  static const checkout = '/checkout';
  static const productDetail = '/product';
  static const login = '/login';
  static const notifications = '/notifications';
  static const branchesMap = '/branches-map';
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    required AuthController authController,
    CatalogController? catalogController,
    NotificationController? notificationController,
  }) {
    return switch (settings.name) {
      AppRoutes.catalog => _main(
        settings,
        authController: authController,
        catalogController: catalogController,
        notificationController: notificationController,
        reservationArguments: settings.arguments is ReservationArguments
            ? settings.arguments as ReservationArguments
            : null,
        initialIndex: 0,
      ),
      AppRoutes.management => _main(
        settings,
        authController: authController,
        catalogController: catalogController,
        notificationController: notificationController,
        initialIndex: 1,
      ),
      AppRoutes.account => _main(
        settings,
        authController: authController,
        catalogController: catalogController,
        notificationController: notificationController,
        initialIndex: 2,
      ),
      AppRoutes.cart => _subpage(
        settings,
        'Carrito',
        CartPage(authController: authController),
      ),
      AppRoutes.notifications => _subpage(
        settings,
        'Notificaciones',
        NotificationsPage(
          authController: authController,
          controller: notificationController,
        ),
      ),
      AppRoutes.reservations => _subpage(
        settings,
        'Mis reservas',
        ReservationsPage(
          authController: authController,
          initialReservationId: settings.arguments is String
              ? settings.arguments as String
              : null,
        ),
      ),
      AppRoutes.orders => _subpage(
        settings,
        'Mis pedidos',
        OrdersPage(
          authController: authController,
          initialOrderId: settings.arguments is String
              ? settings.arguments as String
              : null,
        ),
      ),
      AppRoutes.reservationCreate => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => ReservationCreatePage(
          authController: authController,
          arguments: settings.arguments is ReservationArguments
              ? settings.arguments as ReservationArguments
              : null,
        ),
      ),
      AppRoutes.checkout => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => CheckoutPage(
          authController: authController,
          orderId: settings.arguments is String
              ? settings.arguments as String
              : null,
        ),
      ),
      AppRoutes.productDetail => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => ProductDetailPage(
          arguments: settings.arguments is ProductDetailArguments
              ? settings.arguments as ProductDetailArguments
              : null,
          authController: authController,
        ),
      ),
      AppRoutes.login => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => _LoginRoutePage(authController: authController),
      ),
      AppRoutes.branchesMap => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => BranchesMapPage(
          initialBranchId: settings.arguments is String ? settings.arguments as String : null,
        ),
      ),
      _ => _main(
        settings,
        authController: authController,
        catalogController: catalogController,
        notificationController: notificationController,
        initialIndex: 0,
      ),
    };
  }

  static Route<dynamic> _main(
    RouteSettings settings, {
    required AuthController authController,
    CatalogController? catalogController,
    NotificationController? notificationController,
    ReservationArguments? reservationArguments,
    int initialIndex = 0,
  }) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => MainNavigationShell(
        authController: authController,
        catalogController: catalogController,
        notificationController: notificationController,
        reservationArguments: reservationArguments,
        initialIndex: initialIndex,
      ),
    );
  }

  static Route<dynamic> _subpage(
    RouteSettings settings,
    String title,
    Widget page,
  ) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: page,
      ),
    );
  }
}

class _LoginRoutePage extends StatelessWidget {
  const _LoginRoutePage({required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: LoginPage(
        controller: authController,
        showGuestButton: true,
        onGuest: () => Navigator.of(context).pop(),
      ),
    );
  }
}
