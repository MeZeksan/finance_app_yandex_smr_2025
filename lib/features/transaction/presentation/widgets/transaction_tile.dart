import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_brief/account_brief.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/repositoryI/mock_bank_account_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/account/domain/repository/bank_account_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/models/category.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/repositoryI/mock_category_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/category/domain/repositories/category_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_request/transaction_request.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/repositoryI/mock_transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final TransactionResponce transaction;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onChanged;

  const TransactionTile({
    super.key,
    required this.transaction, 
    required this.isFirst, 
    required this.isLast,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(transaction.amount) ?? 0.0;
    final formatter = NumberFormat('#,##0', 'ru_RU');
    final formattedAmount = '${formatter.format(amount.round())} ₽';
    

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFEF7FF),
      ),
      child: Column(
        children: [
          if (isFirst) const Divider(height: 0,),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF7FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  transaction.category.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (transaction.comment != null && transaction.comment!.isNotEmpty)
              Text(
                transaction.comment!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedAmount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
            onTap: () async {
              final result = await _showTransactionModal(context, transaction);
              if (result == true && onChanged != null) {
                onChanged!();
              }
            },
          ),
          if (!isLast) const Divider(height: 0,),
        if (isLast) const Divider(height: 0,),
          ],
      ),
    );
  }

  Future<bool?> _showTransactionModal(BuildContext context, TransactionResponce transaction) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TransactionScreen.edit(
          transaction: transaction,
          transactionRepository: MockTransactionRepository.instance,
        ),
      ),
    );
  }
}

class TransactionScreen extends StatefulWidget {
  final TransactionRepository transactionRepository;
  final TransactionResponce? transaction; // null for create mode
  final bool isIncome; // Used only in create mode

  TransactionScreen.edit({
    super.key,
    required this.transaction,
    required this.transactionRepository,
  }) : isIncome = transaction!.category.isIncome;

  const TransactionScreen.create({
    super.key,
    required this.isIncome,
    required this.transactionRepository,
  }) : transaction = null;

  static Future<bool?> show(
    BuildContext context,
    bool isIncome,
    TransactionRepository repository,
  ) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TransactionScreen.create(
          isIncome: isIncome,
          transactionRepository: MockTransactionRepository.instance,
        ),
      ),
    );
  }

  bool get isEditMode => transaction != null;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late TextEditingController _amountController;
  late TextEditingController _commentController;
  late DateTime _selectedDate;
  AccountBrief? _selectedAccount;
  Category? _selectedCategory;
  
  List<AccountBrief> _accounts = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isSaving = false;
  
  final BankAccountRepository _accountRepository = MockBankAccountRepository();
  final CategoryRepository _categoryRepository = MockCategoryRepository();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.isEditMode) {
      final amount = double.tryParse(widget.transaction!.amount) ?? 0.0;
      _amountController = TextEditingController(text: amount.toStringAsFixed(2).replaceAll('.', ','));
      _commentController = TextEditingController(text: widget.transaction!.comment ?? '');
      _selectedDate = widget.transaction!.transactionDate;
      _selectedAccount = widget.transaction!.account;
      _selectedCategory = widget.transaction!.category;
    } else {
      _amountController = TextEditingController();
      _commentController = TextEditingController();
      _selectedDate = DateTime.now();
    }
    
    _loadAccountsAndCategories();
  }

  Future<void> _loadAccountsAndCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load accounts
      if (widget.isEditMode) {
        final account = await _accountRepository.getAccountById(_selectedAccount!.id);
        if (account != null) {
          _accounts = [AccountBrief(
            id: account.id,
            name: account.name,
            balance: account.balance,
            currency: account.currency,
          )];
        }
      } else {
        final account = await _accountRepository.getAccountById(1);
        if (account != null) {
          _accounts = [AccountBrief(
            id: account.id,
            name: account.name,
            balance: account.balance,
            currency: account.currency,
          )];
          _selectedAccount = _accounts.first;
        }
      }

      // Load categories based on transaction type
      final categoryEntities = widget.isIncome 
          ? await _categoryRepository.getIncomeCategories()
          : await _categoryRepository.getExpenseCategories();
      
      _categories = categoryEntities.map((entity) => Category(
        id: entity.id,
        name: entity.name,
        emoji: entity.emoji,
        isIncome: entity.isIncome,
      )).toList();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ru', 'RU'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFb2AE881),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFb2AE881),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  List<String> _validateFields() {
    final errors = <String>[];

    // Проверка счета
    if (_selectedAccount == null) {
      errors.add('Выберите счет');
    }

    // Проверка категории
    if (_selectedCategory == null) {
      errors.add('Выберите категорию');
    }

    // Проверка суммы
    if (_amountController.text.trim().isEmpty) {
      errors.add('Введите сумму');
    } else {
      final amountText = _amountController.text.replaceAll(',', '.');
      final amount = double.tryParse(amountText);
      if (amount == null || amount <= 0) {
        errors.add('Введите корректную сумму больше 0');
      }
    }

    return errors;
  }

  void _showValidationDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заполните обязательные поля'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Для сохранения операции необходимо заполнить:'),
            const SizedBox(height: 8),
            ...errors.map((error) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(error)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTransaction() async {
    // Валидация всех полей
    final validationErrors = _validateFields();
    if (validationErrors.isNotEmpty) {
      _showValidationDialog(validationErrors);
      return;
    }

    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText)!; // Safe because validation passed

    setState(() {
      _isSaving = true;
    });

    try {
      final request = TransactionRequest(
        accountId: _selectedAccount!.id,
        categoryId: _selectedCategory!.id,
        amount: amount.toStringAsFixed(2),
        transactionDate: _selectedDate,
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      );

      if (widget.isEditMode) {
        await widget.transactionRepository.updateTransaction(
          widget.transaction!.id,
          request,
        );
      } else {
        await widget.transactionRepository.addTransaction(request);
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить транзакцию?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isSaving = true;
      });

      try {
        await widget.transactionRepository.deleteTransaction(widget.transaction!.id);
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка удаления: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      body: Column(
        children: [
          // Header with status bar padding
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFb2AE881),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    widget.isIncome ? 'Мои доходы' : 'Мои расходы',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.black),
                  onPressed: _isSaving ? null : _saveTransaction,
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Account Selection
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF7FF),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                title: const Text(
                                  'Счет',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedAccount?.name ?? 'Выберите счет',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: _selectedAccount != null ? Colors.black : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
                                onTap: _showAccountSelector,
                              ),
                              const Divider(height: 1, color: Colors.grey),
                            ],
                          ),
                        ),

                        // Category Selection
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF7FF),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                title: const Text(
                                  'Статья',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedCategory?.name ?? 'Выберите категорию',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: _selectedCategory != null ? Colors.black : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
                                onTap: _showCategorySelector,
                              ),
                              const Divider(height: 1, color: Colors.grey),
                            ],
                          ),
                        ),

                        // Amount Input
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF7FF),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Сумма',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const Spacer(),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: _amountController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
                                        ],
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '0 ₽',
                                          hintStyle: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Colors.grey),
                            ],
                          ),
                        ),

                        // Date Selection
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF7FF),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                title: const Text(
                                  'Дата',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                trailing: Text(
                                  DateFormat('dd.MM.yyyy', 'ru_RU').format(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                                onTap: _selectDate,
                              ),
                              const Divider(height: 1, color: Colors.grey),
                            ],
                          ),
                        ),

                        // Time Selection
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF7FF),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                title: const Text(
                                  'Время',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                trailing: Text(
                                  DateFormat('HH:mm', 'ru_RU').format(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                                onTap: _selectTime,
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 1, color: Colors.grey),
                        // Comment Input
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF7FF),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: _commentController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.pink, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.pink, width: 2),
                                ),
                                hintText: 'Комментарий',
                                hintStyle: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const Divider(height: 1, color: Colors.grey),

                        // Delete Button (only in edit mode)
                        if (widget.isEditMode)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _deleteTransaction,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE46962),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Удалить',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAccountSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Выберите счет',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ..._accounts.map((account) => ListTile(
              title: Text(account.name),
              subtitle: Text('${account.balance} ${account.currency}'),
              trailing: _selectedAccount?.id == account.id
                  ? const Icon(Icons.check, color: Color(0xFFb2AE881))
                  : null,
              onTap: () {
                setState(() {
                  _selectedAccount = account;
                });
                Navigator.of(context).pop();
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Выберите категорию',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return ListTile(
                    leading: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text(category.name),
                    trailing: _selectedCategory?.id == category.id
                        ? const Icon(Icons.check, color: Color(0xFFb2AE881))
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}