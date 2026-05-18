import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'transactions_list_screen.dart';

/// All Transactions Screen - Full screen version
class AllTransactionsScreen extends ConsumerWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const TransactionsListScreen();
  }
}
