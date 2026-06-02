/// How the payment-method picker finishes after the user selects a row.
enum PaymentMethodPickerBehavior {
  /// Wallet deposit: save selection → open deposit confirm screen.
  depositFlow,

  /// Borrow repay: pop [PaymentMethodSelection] to the caller.
  returnSelection,
}
