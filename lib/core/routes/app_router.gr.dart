// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AccountScreen]
class AccountRoute extends PageRouteInfo<void> {
  const AccountRoute({List<PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AccountScreen();
    },
  );
}

/// generated route for
/// [AnalysisScreen]
class AnalysisRoute extends PageRouteInfo<AnalysisRouteArgs> {
  AnalysisRoute({
    Key? key,
    required bool isIncome,
    List<PageRouteInfo>? children,
  }) : super(
         AnalysisRoute.name,
         args: AnalysisRouteArgs(key: key, isIncome: isIncome),
         initialChildren: children,
       );

  static const String name = 'AnalysisRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AnalysisRouteArgs>();
      return AnalysisScreen(key: args.key, isIncome: args.isIncome);
    },
  );
}

class AnalysisRouteArgs {
  const AnalysisRouteArgs({this.key, required this.isIncome});

  final Key? key;

  final bool isIncome;

  @override
  String toString() {
    return 'AnalysisRouteArgs{key: $key, isIncome: $isIncome}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnalysisRouteArgs) return false;
    return key == other.key && isIncome == other.isIncome;
  }

  @override
  int get hashCode => key.hashCode ^ isIncome.hashCode;
}

/// generated route for
/// [ArticlesScreen]
class ArticlesRoute extends PageRouteInfo<void> {
  const ArticlesRoute({List<PageRouteInfo>? children})
    : super(ArticlesRoute.name, initialChildren: children);

  static const String name = 'ArticlesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ArticlesScreen();
    },
  );
}

/// generated route for
/// [ExpensesScreen]
class ExpensesRoute extends PageRouteInfo<ExpensesRouteArgs> {
  ExpensesRoute({Key? key, List<PageRouteInfo>? children})
    : super(
        ExpensesRoute.name,
        args: ExpensesRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'ExpensesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ExpensesRouteArgs>(
        orElse: () => const ExpensesRouteArgs(),
      );
      return ExpensesScreen(key: args.key);
    },
  );
}

class ExpensesRouteArgs {
  const ExpensesRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'ExpensesRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExpensesRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [HistoryScreen]
class HistoryRoute extends PageRouteInfo<HistoryRouteArgs> {
  HistoryRoute({
    Key? key,
    required bool isIncome,
    List<PageRouteInfo>? children,
  }) : super(
         HistoryRoute.name,
         args: HistoryRouteArgs(key: key, isIncome: isIncome),
         initialChildren: children,
       );

  static const String name = 'HistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HistoryRouteArgs>();
      return HistoryScreen(key: args.key, isIncome: args.isIncome);
    },
  );
}

class HistoryRouteArgs {
  const HistoryRouteArgs({this.key, required this.isIncome});

  final Key? key;

  final bool isIncome;

  @override
  String toString() {
    return 'HistoryRouteArgs{key: $key, isIncome: $isIncome}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HistoryRouteArgs) return false;
    return key == other.key && isIncome == other.isIncome;
  }

  @override
  int get hashCode => key.hashCode ^ isIncome.hashCode;
}

/// generated route for
/// [IncomesScreen]
class IncomesRoute extends PageRouteInfo<IncomesRouteArgs> {
  IncomesRoute({Key? key, List<PageRouteInfo>? children})
    : super(
        IncomesRoute.name,
        args: IncomesRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'IncomesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<IncomesRouteArgs>(
        orElse: () => const IncomesRouteArgs(),
      );
      return IncomesScreen(key: args.key);
    },
  );
}

class IncomesRouteArgs {
  const IncomesRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'IncomesRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IncomesRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [MainWrapperPage]
class MainWrapperRoute extends PageRouteInfo<void> {
  const MainWrapperRoute({List<PageRouteInfo>? children})
    : super(MainWrapperRoute.name, initialChildren: children);

  static const String name = 'MainWrapperRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainWrapperPage();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}
