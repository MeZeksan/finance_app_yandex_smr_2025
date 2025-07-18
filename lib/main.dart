import 'package:finance_app_yandex_smr_2025/core/di/service_locator.dart';
import 'package:finance_app_yandex_smr_2025/core/routes/app_router.dart';
import 'package:finance_app_yandex_smr_2025/core/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем сервис-локатор с network режимом
  await ServiceLocator.init(mode: AppMode.network);
  
  // Инициализируем локализацию для корректного отображения дат
  await initializeDateFormatting('ru_RU', null);
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ServiceLocator.themeService;
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Finance App',
          debugShowCheckedModeBanner: false,
          theme: _themeService.getLightTheme(),
          darkTheme: _themeService.getDarkTheme(),
          themeMode: _themeService.useSystemTheme 
            ? ThemeMode.system 
            : (_themeService.isDarkTheme ? ThemeMode.dark : ThemeMode.light),
          routerConfig: appRouter.config(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ru', 'RU'),
          ],
        );
      },
    );
  }
}
