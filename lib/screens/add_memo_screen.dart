import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

class AddMemoScreen extends StatefulWidget {
  final int amount;
  final Expense? expense;
  final String paymentMethod;

  const AddMemoScreen({
    super.key,
    required this.amount,
    this.expense,
    this.paymentMethod = 'card',
  });

  @override
  State<AddMemoScreen> createState() => _AddMemoScreenState();
}

class _AddMemoScreenState extends State<AddMemoScreen> {
  final TextEditingController memoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      memoController.text = widget.expense!.memo;
    }
  }

  @override
  void dispose() {
    memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCard = widget.paymentMethod == 'card';

    final Color mainColor = isCard
        ? const Color(0xFF2463C9)
        : const Color(0xFF16834A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('메모'),
        backgroundColor: isCard
            ? const Color(0xFFEAF2FF)
            : const Color(0xFFE8F7ED),
        foregroundColor: mainColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.amount}원',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      isCard ? '카드 결제' : '현금 결제',
                      style: TextStyle(fontSize: 15, color: mainColor),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: memoController,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: '내용 입력'),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 66,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final expense = Expense(
                      id: widget.expense?.id,
                      amount: widget.amount,
                      memo: memoController.text,
                      date: widget.expense?.date ?? DateTime.now(),
                      paymentMethod: widget.paymentMethod,
                    );

                    if (widget.expense == null) {
                      await DatabaseHelper.insertExpense(expense);
                    } else {
                      await DatabaseHelper.updateExpense(expense);
                    }

                    if (!context.mounted) return;

                    Navigator.pop(context, expense);
                  } catch (e) {
                    debugPrint('DB 오류: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
