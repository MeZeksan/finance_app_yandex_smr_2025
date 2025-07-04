import '../models/balance_data/balance_data.dart';

class MockBalanceData {
  static List<BalanceData> getMockData() {
    final now = DateTime.now();
    final data = <BalanceData>[];
    
    // Генерируем данные за весь текущий месяц
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    for (int day = 1; day <= lastDayOfMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final isIncome = day % 6 == 0 || day % 9 == 0; // реже доходы
      final amount = _generateMockAmount(day, isIncome);
      data.add(BalanceData(
        date: date,
        amount: amount,
        type: isIncome ? 'income' : 'expense',
      ));
    }
    return data;
  }

  static double _generateMockAmount(int dayIndex, bool isIncome) {
    final base = isIncome ? 35000.0 : 12000.0;
    final variation = isIncome ? 20000.0 : 15000.0;
    final mod = (dayIndex % 8) - 4;
    return base + variation * mod.abs() / 4;
  }

  static List<BalanceData> getMockDataExtended() {
    return getMockData(); // используем те же данные
  }
} 