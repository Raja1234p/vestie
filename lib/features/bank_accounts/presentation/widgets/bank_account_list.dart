import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';
import 'package:vestie/features/bank_accounts/presentation/widgets/bank_account_manage_row.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_primary_button.dart';

class BankAccountList extends StatelessWidget {
  final List<BankAccountEntity> accounts;
  final VoidCallback onAdd;
  final bool addLoading;

  const BankAccountList({
    super.key,
    required this.accounts,
    required this.onAdd,
    this.addLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
            itemCount: accounts.length,
            separatorBuilder: (_, _) =>
                SizedBox(height: AppDimens.paymentMethodRowGap),
            itemBuilder: (_, i) => BankAccountManageRow(
              account: accounts[i],
              showChevron: false,
            ),
          ),
        ),
        FlowScreenFooter(
          child: PaymentPrimaryButton(
            label: AppStrings.btnAddBankAccount,
            onTap: addLoading ? null : onAdd,
            loading: addLoading,
          ),
        ),
      ],
    );
  }
}
