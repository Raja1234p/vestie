import 'entities/payment_card.dart';
import 'entities/transaction.dart';
import 'entities/user_profile.dart';

class MockProfileData {
  MockProfileData._();

  static const UserProfile profile = UserProfile(
    fullName: 'Alex Johnson',
    username: '@alexj',
    email: 'alex@example.com',
  );

  static const List<PaymentCard> cards = [
    PaymentCard(
      id: 'c1',
      holderName: 'Alex Johnson',
      last4: '5022',
      maskedNumber: '•••• 5022',
      expiry: '12/26',
      brand: CardBrand.visa,
      isPrimary: true,
    ),
    PaymentCard(
      id: 'c2',
      holderName: 'Alex Johnson',
      last4: '0283',
      maskedNumber: '•••• 0283',
      expiry: '08/27',
      brand: CardBrand.mastercard,
    ),
  ];

  static const List<Transaction> transactions = [
    Transaction(id: 't1', title: 'Wallet Deposit',         date: 'Mar 12', amount:  500,  type: TransactionType.deposit),
    Transaction(id: 't2', title: 'Contribution: Family V...', date: 'Mar 11', amount: -115,  type: TransactionType.contribution),
    Transaction(id: 't3', title: 'Borrow: Family Vacation',  date: 'Mar 12', amount:  650,  type: TransactionType.borrow),
    Transaction(id: 't4', title: 'Lend: Car Repair',         date: 'Mar 15', amount: -300,  type: TransactionType.lend),
    Transaction(id: 't5', title: 'Borrow: New Laptop',       date: 'Mar 18', amount:  1200, type: TransactionType.borrow),
    Transaction(id: 't6', title: 'Lend: Wedding Gift',       date: 'Mar 20', amount: -150,  type: TransactionType.lend),
    Transaction(id: 't7', title: 'Contribution: Family V...', date: 'Mar 11', amount: -115,  type: TransactionType.contribution),
  ];
}
