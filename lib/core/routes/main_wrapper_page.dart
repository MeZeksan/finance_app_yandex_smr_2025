import 'package:auto_route/auto_route.dart';
import 'package:finance_app_yandex_smr_2025/core/di/service_locator.dart';
import 'package:finance_app_yandex_smr_2025/core/routes/app_router.dart';
import 'package:finance_app_yandex_smr_2025/core/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

@RoutePage()
class MainWrapperPage extends StatefulWidget {
  const MainWrapperPage({super.key});

  @override
  State<MainWrapperPage> createState() => _MainWrapperPageState();
}

class _MainWrapperPageState extends State<MainWrapperPage> {
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ServiceLocator.themeService;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
                return AutoTabsScaffold(
          routes: [
            ExpensesRoute(),
            IncomesRoute(),
            const AccountRoute(),
            const ArticlesRoute(),
            const SettingsRoute(),
          ],
          bottomNavigationBuilder: (_, tabsRouter) {
            return BottomNavigationBar(
              backgroundColor: _themeService.backgroundColor,
              currentIndex: tabsRouter.activeIndex,
              onTap: tabsRouter.setActiveIndex,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle().copyWith(fontSize: 0),
              unselectedLabelStyle: const TextStyle().copyWith(fontSize: 0),
              selectedItemColor: _themeService.headerColor,
              unselectedItemColor: _themeService.textColor.withOpacity(0.6),
              items: [
                _buildNavItem(
                  context,
                  'assets/icons/expanses.svg',
                  tabsRouter.activeIndex == 0,
                  'Расходы',
                ),
                _buildNavItem(
                  context,
                  'assets/icons/incomes.svg',
                  tabsRouter.activeIndex == 1,
                  'Доходы',
                ),
                _buildNavItem(
                  context,
                  'assets/icons/account.svg',
                  tabsRouter.activeIndex == 2,
                  'Счет',
                ),
                _buildNavItem(
                  context,
                  'assets/icons/articles.svg',
                  tabsRouter.activeIndex == 3,
                  'Статьи',
                ),
                _buildNavItem(
                  context,
                  'assets/icons/settings.svg',
                  tabsRouter.activeIndex == 4,
                  'Настройки',
                ),
              ],
            );
          },
                );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(
    BuildContext context,
    String assetPath,
    bool isSelected,
    String label,
  ) {
    final icon = Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Container(
        width: 64,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? _themeService.containerColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            color: isSelected ? _themeService.headerColor : _themeService.textColor.withOpacity(0.6),
            width: 24,
            height: 24,
          ),
        ),
      ),
    );

    final labelText = Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _themeService.textColor.withOpacity(0.6)),
      ),
    );

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: icon,
          ),
          labelText,
        ],
      ),
      label: '',
    );
  }
}
