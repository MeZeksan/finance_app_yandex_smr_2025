import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:finance_app_yandex_smr_2025/core/network/network_service.dart';

class OfflineStatusWidget extends StatelessWidget {
  final NetworkService _networkService = NetworkService();

  OfflineStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _networkService.connectionStream,
      initialData: _networkService.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;
        
        if (isConnected) {
          return const SizedBox.shrink(); // Не показываем ничего когда есть соединение
        }
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            border: Border(
              bottom: BorderSide(
                color: Colors.orange.shade300,
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: 16,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Нет подключения к интернету',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OfflineStatusBar extends StatelessWidget {
  final Widget child;
  final NetworkService _networkService = NetworkService();

  OfflineStatusBar({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OfflineStatusWidget(),
        Expanded(child: child),
      ],
    );
  }
}

class OfflineStatusScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final List<Widget>? persistentFooterButtons;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? drawerScrimColor;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;

  const OfflineStatusScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.persistentFooterButtons,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: OfflineStatusBar(child: body),
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      persistentFooterButtons: persistentFooterButtons,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
    );
  }
} 