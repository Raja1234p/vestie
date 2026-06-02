/// How the payment-method picker finishes after the user selects a row.
enum PaymentMethodPickerBehavior {
  /// Wallet deposit: save selection → open deposit confirm screen.
  depositFlow,

  /// Deposit confirm: pick another card → pop back to confirm (no auto-skip).
  depositFlowChangeCard,

  /// Borrow repay: pop [PaymentMethodSelection] to the caller.
  returnSelection,
}

extension PaymentMethodPickerBehaviorX on PaymentMethodPickerBehavior {
  bool get isDepositPicker =>
      this == PaymentMethodPickerBehavior.depositFlow ||
      this == PaymentMethodPickerBehavior.depositFlowChangeCard;
}
