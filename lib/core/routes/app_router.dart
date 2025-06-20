import 'package:auto_route/auto_route.dart';
import 'package:finance_app_yandex_smr_2025/core/routes/main_wrapper_page.dart';
import 'package:finance_app_yandex_smr_2025/features/account/presentation/view/account_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/articles/presentation/view/articles_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/settings/presentation/view/settings_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/presentation/view/expenses_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/presentation/view/incomes_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // Главный wrapper route с AutoTabsScaffold
        AutoRoute(
          page: MainWrapperRoute.page,
          path: '/',
          children: [
            AutoRoute(
              page: ExpensesRoute.page,
              path: 'expenses',
            ),
            AutoRoute(
              page: IncomesRoute.page,
              path: 'income',
            ),
            AutoRoute(
              page: AccountRoute.page,
              path: 'account',
              initial: true,
            ),
            AutoRoute(
              page: ArticlesRoute.page,
              path: 'articles',
            ),
            AutoRoute(
              page: SettingsRoute.page,
              path: 'settings',
            ),
          ],
        ),
      ];
}
