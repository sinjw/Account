import 'package:flutter/material.dart';
import '../widgets/custom_keypad.dart';
import 'package:intl/intl.dart';
import 'add_memo_screen.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String amount = "";
  String paymentMethod = 'card';

  bool get isCard => paymentMethod == 'card';

  Color get backgroundColor =>
      isCard ? const Color(0xFFEAF2FF) : const Color(0xFFE8F7ED);

  Color get mainColor =>
      isCard ? const Color(0xFF2463C9) : const Color(0xFF16834A);

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      amount = widget.expense!.amount.toString();
      paymentMethod = widget.expense!.paymentMethod;
    }
  }

  String get formattedAmount {
    if (amount.isEmpty) {
      return "0";
    }

    return NumberFormat('#,###').format(int.parse(amount));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: backgroundColor,
          child: Column(
            children: [
              // 좌측 상단 결제수단 전환 버튼
              SizedBox(
                height: 70,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          paymentMethod = isCard ? 'cash' : 'card';
                        });
                      },
                      icon: Icon(
                        isCard ? Icons.credit_card : Icons.payments_outlined,
                      ),
                      label: Text(
                        isCard ? '카드' : '현금',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 금액 표시
              Expanded(
                flex: 4,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "-",
                        style: TextStyle(fontSize: 80, color: mainColor),
                      ),
                      Text(
                        formattedAmount,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "원",
                        style: TextStyle(fontSize: 28, color: mainColor),
                      ),
                    ],
                  ),
                ),
              ),

              // 다음 버튼
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    if (amount.isEmpty || int.parse(amount) == 0) {
                      return;
                    }

                    final expense = await Navigator.push<Expense>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMemoScreen(
                          amount: int.parse(amount),
                          expense: widget.expense,
                          paymentMethod: paymentMethod,
                        ),
                      ),
                    );

                    if (!context.mounted) return;

                    if (expense != null) {
                      Navigator.pop(context, expense);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text(
                    "다음",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // 숫자 키패드
              CustomKeypad(
                onKeyPressed: (value) {
                  setState(() {
                    if (value == "←") {
                      if (amount.isNotEmpty) {
                        amount = amount.substring(0, amount.length - 1);
                      }
                    } else if (value == "00") {
                      amount += "00";
                    } else {
                      amount += value;
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
