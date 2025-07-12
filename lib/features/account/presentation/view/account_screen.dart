import 'dart:async';
import 'dart:math';

import 'package:auto_route/annotations.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_update_request/account_update_request.dart';
import 'package:finance_app_yandex_smr_2025/core/di/service_locator.dart';
import 'package:finance_app_yandex_smr_2025/features/account/presentation/bloc/account_bloc.dart';
import 'package:finance_app_yandex_smr_2025/features/account/presentation/bloc/account_event.dart';
import 'package:finance_app_yandex_smr_2025/features/account/presentation/bloc/account_state.dart';
import 'package:finance_app_yandex_smr_2025/features/account/presentation/widgets/noise_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../widgets/balance_chart.dart';
import '../../data/repositoryI/network_bank_account_repository.dart';
import '../../data/models/balance_data/balance_data.dart';

@RoutePage()
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountBloc(
        repository: ServiceLocator.bankAccountRepository,
      )..add(const LoadAccount(accountId: 1)),
      child: const AccountView(),
    );
  }
}

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> with SingleTickerProviderStateMixin {
  bool _isBalanceVisible = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;
  List<BalanceData> _balanceData = [];
  
  @override
  void initState() {
    super.initState();
    
    // Инициализация анимации
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Подписка на события акселерометра
    _startListeningAccelerometer();
    
    // Загружаем данные графика
    _loadBalanceData();
  }
  
  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  void _startListeningAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      // Определяем переворот устройства (z < -9.0 означает, что устройство перевернуто экраном вниз)
      if (event.z < -9.0) {
        _toggleBalanceVisibility();
        return;
      }
      
      // Определяем тряску устройства
      final double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      final double delta = acceleration - 9.8; // Вычитаем гравитацию
      
      // Если ускорение больше порогового значения, считаем это тряской
      if (delta.abs() > 10.0) {
        final now = DateTime.now();
        if (_lastShakeTime == null || now.difference(_lastShakeTime!) > const Duration(milliseconds: 500)) {
          _lastShakeTime = now;
          _toggleBalanceVisibility();
        }
      }
    });
  }
  
  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
      if (_isBalanceVisible) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }
  

  
  Future<void> _loadBalanceData() async {
    final repository = ServiceLocator.bankAccountRepository;
    if (repository is NetworkBankAccountRepository) {
      final balanceData = await repository.getBalanceData();
      if (mounted) {
        setState(() {
          _balanceData = balanceData;
        });
      }
    }
  }
  
  void _showEditDialog(BuildContext context, AccountState state) {
    final account = state.account;
    if (account == null) return;
    
    final TextEditingController nameController = TextEditingController(text: account.name);
    final TextEditingController currencyController = TextEditingController(text: account.currency);
    
    // Сохраняем ссылку на внешний контекст, содержащий BlocProvider
    final outerContext = context;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Редактирование счета'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Название счета',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: currencyController.text,
                decoration: const InputDecoration(
                  labelText: 'Валюта',
                ),
                items: const [
                  DropdownMenuItem(value: 'RUB', child: Text('₽')),
                  DropdownMenuItem(value: 'USD', child: Text('\$')),
                  DropdownMenuItem(value: 'EUR', child: Text('€')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    currencyController.text = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                
                // Используем outerContext для доступа к BlocProvider
                if (nameController.text.isNotEmpty && currencyController.text.isNotEmpty) {
                  final updateRequest = AccountUpdateRequest(
                    name: nameController.text,
                    balance: account.balance,
                    currency: currencyController.text,
                  );
                  
                  // Используем внешний контекст для доступа к BlocProvider
                  outerContext.read<AccountBloc>().add(
                    UpdateAccount(
                      accountId: account.id,
                      request: updateRequest,
                    ),
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topPadding = statusBarHeight + 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.isFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Произошла ошибка',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AccountBloc>().add(
                        const LoadAccount(accountId: 1),
                      );
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          final account = state.account;
          if (account == null) {
            return const Center(
              child: Text('Счет не найден'),
            );
          }

          final formatter = NumberFormat('#,##0.00');
          final formattedBalance = formatter.format(
            double.tryParse(account.balance) ?? 0,
          );

          return Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFb2AE881),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        account.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1D1B20),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          onPressed: () {
                            _showEditDialog(context, state);
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF1D1B20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Column(
                  children: [
                    // Balance Container
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4FAE6),
                      ),
                      child: Column(
                        children: [
                          // Balance Container
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Text(
                                  'Баланс',
                                  style: TextStyle(
                                    color: Color(0xFF1D1B20),
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _toggleBalanceVisibility,
                                  child: Row(
                                    children: [
                                      AnimatedBuilder(
                                        animation: _fadeAnimation,
                                        builder: (context, child) {
                                          return _isBalanceVisible
                                            ? Text(
                                                '$formattedBalance ${_getCurrencySymbol(account.currency)}',
                                                style: const TextStyle(
                                                  color: Color(0xFF1D1B20),
                                                  fontSize: 18,
                                                ),
                                              )
                                            : const NoiseBox(
                                                width: 120,
                                                height: 18,
                                              );
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                                        color: const Color(0xFF1D1B20),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF1D1B20),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE6E6E6),
                          ),
                          // Currency Container
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Text(
                                  'Валюта',
                                  style: TextStyle(
                                    color: Color(0xFF1D1B20),
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _getCurrencySymbol(account.currency),
                                  style: const TextStyle(
                                    color: Color(0xFF1D1B20),
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF1D1B20),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Balance Chart
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: BalanceChart(
                        balanceData: _balanceData,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        heroTag: 'accountButtonTag',
        shape: const CircleBorder(),
        onPressed: () {
          // TODO: Implement add functionality
        },
        backgroundColor: const Color(0xFFb2AE881),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
  
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'RUB':
        return '₽';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currencyCode;
    }
  }
}
