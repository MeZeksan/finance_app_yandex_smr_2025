import 'package:auto_route/auto_route.dart';
import 'package:finance_app_yandex_smr_2025/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

@RoutePage()
class MainWrapperPage extends StatelessWidget {
  const MainWrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Color(0xffF3EDF7),
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle().copyWith(fontSize: 0),
          unselectedLabelStyle: const TextStyle().copyWith(fontSize: 0),
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: const Color(0xff49454F),
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
          color: isSelected ? const Color(0xffD4FAE6) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            color: isSelected ? Color(0xff2AE881) : const Color(0xff49454F),
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
            color: Color(0xff49454F)),
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
