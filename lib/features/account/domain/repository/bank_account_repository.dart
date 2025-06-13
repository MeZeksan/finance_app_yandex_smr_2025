import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_responce/account_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_update_request/account_update_request.dart';

abstract class BankAccountRepository {
  Future<AccountResponce?> getAccountById(int accountId);

  Future<AccountResponce> updateAccount(
      int accountId, AccountUpdateRequest request);
}
