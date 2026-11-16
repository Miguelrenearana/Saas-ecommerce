import 'package:flutter/material.dart';

import '../features/auth/auth_controller.dart';
import '../features/catalog/catalog_controller.dart';
import '../features/catalog/catalog_page.dart';
import '../features/management/management_page.dart';
import '../features/notifications/notification_controller.dart';
import '../features/profile/profile_page.dart';
import '../features/reservations/reservation_models.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({
    super.key,
    required this.authController,
    this.catalogController,
    this.notificationController,
    this.reservationArguments,
    this.initialIndex = 0,
  });

  final AuthController authController;
  final CatalogController? catalogController;
  final NotificationController? notificationController;
  final ReservationArguments? reservationArguments;
  final int initialIndex;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant MainNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_currentIndex) {
      0 => 'Catálogo',
      1 => 'Gestiones',
      _ => 'Cuenta',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CatalogPage(
            controller: widget.catalogController,
            authController: widget.authController,
            reservationArguments: widget.reservationArguments,
          ),
          ManagementPage(
            notificationController: widget.notificationController,
          ),
          ProfilePage(
            authController: widget.authController,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (_currentIndex != index) {
            setState(() => _currentIndex = index);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Gestiones',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}
