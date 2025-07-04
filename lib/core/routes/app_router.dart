import 'package:auto_route/auto_route.dart';
import 'package:finance_app_yandex_smr_2025/core/routes/main_wrapper_page.dart';
import 'package:finance_app_yandex_smr_2025/core/splash/splash_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/account/presentation/view/account_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/analysis/presentation/view/analysis_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/articles/presentation/view/articles_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/history/presentation/view/history_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/settings/presentation/view/settings_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/presentation/view/expenses_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/presentation/view/incomes_screen.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter() : super();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: SplashRoute.page,
          initial: true,
        ),
        AutoRoute(
          page: MainWrapperRoute.page,
          path: '/main',
          children: [
            AutoRoute(
              page: AccountRoute.page,
              path: 'account',
            ),
            AutoRoute(
              page: AnalysisRoute.page,
              path: 'analysis',
            ),
            AutoRoute(
              page: ArticlesRoute.page,
              path: 'articles',
            ),
            AutoRoute(
              page: HistoryRoute.page,
              path: 'history',
            ),
            AutoRoute(
              page: SettingsRoute.page,
              path: 'settings',
            ),
            AutoRoute(
              page: ExpensesRoute.page,
              path: 'expenses',
            ),
            AutoRoute(
              page: IncomesRoute.page,
              path: 'incomes',
            ),
          ],
        ),
      ];
}
