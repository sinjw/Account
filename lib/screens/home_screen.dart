import 'dart:async';
import 'package:flutter/material.dart';
import 'add_expension_screen.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

// ==================================================
// 숫자 카운트업 애니메이션 위젯
// ==================================================
class AnimatedAmount extends StatelessWidget {
  final int amount;
  final TextStyle style;
  final String prefix;

  const AnimatedAmount({
    super.key,
    required this.amount,
    required this.style,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: amount.toDouble()),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '$prefix${NumberFormat('#,###').format(value.round())}원',
          style: style,
        );
      },
    );
  }
}

// ==================================================
// 홈 화면
// ==================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];

  DateTime selectedMonth = DateTime.now();

  // ==================================================
  // 상단 배경색 설정
  // ==================================================

  // 기본 배경색
  Color backgroundColor = const Color(0xFF302B3D);

  // 선택 가능한 배경색 목록
  final List<Color> backgroundColors = [
    const Color(0xFF302B3D), // 보라
    const Color(0xFF263238), // 차콜
    const Color(0xFF26352E), // 딥 그린
    const Color(0xFF243B5A), // 네이비
    const Color(0xFF5A3038), // 버건디
    const Color.fromARGB(255, 101, 42, 106), // 딥 퍼플
  ];

  // 숫자 애니메이션 재생 번호
  int animationVersion = 0;

  // ==================================================
  // 기존 배경 이미지 목록
  // 슬라이드는 현재 사용하지 않음
  // ==================================================
  final List<String> backgroundImages = [
    'assets/images/image01.jpg',
    'assets/images/image02.jpg',
    'assets/images/image03.jpg',
    'assets/images/image04.jpg',
  ];

  int currentImageIndex = 0;

  late PageController pageController;

  Timer? imageTimer;

  // ==================================================
  // 지출 데이터 불러오기
  // ==================================================
  Future<void> loadExpenses() async {
    final loadedExpenses = await DatabaseHelper.getExpenses(selectedMonth);

    if (!mounted) return;

    setState(() {
      expenses = loadedExpenses;
      animationVersion++;
    });
  }

  // ==================================================
  // 이전 달
  // ==================================================
  void previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });

    loadExpenses();
  }

  // ==================================================
  // 다음 달
  // ==================================================
  void nextMonth() {
    final now = DateTime.now();

    final next = DateTime(selectedMonth.year, selectedMonth.month + 1);

    // 현재 월보다 미래로 이동하지 못하게 함
    if (next.isAfter(DateTime(now.year, now.month))) {
      return;
    }

    setState(() {
      selectedMonth = next;
    });

    loadExpenses();
  }

  // ==================================================
  // 총 지출
  // ==================================================
  int get totalExpense {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // ==================================================
  // 카드 지출 합계
  // ==================================================
  int get cardExpense {
    return expenses
        .where((expense) => expense.paymentMethod == 'card')
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // ==================================================
  // 현금 지출 합계
  // ==================================================
  int get cashExpense {
    return expenses
        .where((expense) => expense.paymentMethod == 'cash')
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // ==================================================
  // 기존 이미지 자동 슬라이드 기능
  // 현재는 실행하지 않음
  // ==================================================
  void startImageTimer() {
    if (backgroundImages.length <= 1) {
      return;
    }

    imageTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;

      currentImageIndex++;

      if (currentImageIndex >= backgroundImages.length) {
        currentImageIndex = 0;
      }

      pageController.animateToPage(
        currentImageIndex,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  // ==================================================
  // 화면 시작
  // ==================================================
  @override
  void initState() {
    super.initState();

    pageController = PageController(initialPage: 0);

    loadExpenses();

    // 이미지 자동 슬라이드 비활성화
    // startImageTimer();
  }

  // ==================================================
  // 화면 종료
  // ==================================================
  @override
  void dispose() {
    imageTimer?.cancel();
    pageController.dispose();

    super.dispose();
  }

  // ==================================================
  // 화면
  // ==================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ==================================================
          // 상단 지출 표시 영역
          // ==================================================
          SizedBox(
            width: double.infinity,
            height: 400,
            child: Stack(
              children: [
                // ==========================================
                // 배경 이미지 슬라이드
                // 현재는 주석 처리
                // ==========================================
                /*
                Positioned.fill(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: backgroundImages.length,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(
                        backgroundImages[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                */

                // ==========================================
                // 선택한 단색 배경
                // ==========================================
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    color: backgroundColor,
                  ),
                ),
                Positioned(
                  top: 52,
                  left: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: backgroundColors.map((color) {
                      final bool isSelected = backgroundColor == color;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            backgroundColor = color;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.white54,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // ==========================================
                // 월 / 지출 정보 영역
                // ==========================================
                Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 18,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ==================================
                        // 월 변경 영역
                        // ==================================
                        Row(
                          children: [
                            // 이전 달
                            IconButton(
                              splashRadius: 28,
                              onPressed: previousMonth,
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),

                            // 가운데 월 표시
                            Expanded(
                              child: Center(
                                child: Text(
                                  '${selectedMonth.year}년 '
                                  '${selectedMonth.month}월 지출',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: const Color(0xFFFCEBFF),
                                  ),
                                ),
                              ),
                            ),

                            // 다음 달
                            IconButton(
                              splashRadius: 28,
                              onPressed: nextMonth,
                              icon: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // ==================================
                        // 배경색 선택 팔레트
                        // ==================================

                        // ==================================
                        // 총 지출 애니메이션
                        // ==================================
                        AnimatedAmount(
                          key: ValueKey('total-$animationVersion'),
                          amount: totalExpense,
                          prefix: '- ',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 5,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ==================================
                        // 카드 지출 애니메이션
                        // ==================================
                        AnimatedAmount(
                          key: ValueKey('card-$animationVersion'),
                          amount: cardExpense,
                          prefix: '카드  -',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF9FC5FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // ==================================
                        // 현금 지출 애니메이션
                        // ==================================
                        AnimatedAmount(
                          key: ValueKey('cash-$animationVersion'),
                          amount: cashExpense,
                          prefix: '현금  -',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF9DE5B5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // 지출 리스트 영역
          // ==================================================
          Expanded(
            child: Stack(
              children: [
                // 리스트 배경 이미지
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/ListImage.jpg',
                    fit: BoxFit.cover,
                  ),
                ),

                // 배경 이미지 위에 흰색 반투명 레이어
                Positioned.fill(
                  child: Container(color: Colors.white.withValues(alpha: 0.4)),
                ),

                // ==========================================
                // 지출 목록
                // ==========================================
                ListView.builder(
                  itemCount: expenses.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];

                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromARGB(255, 188, 188, 188),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.purple.withValues(alpha: 0.10),
                          highlightColor: Colors.purple.withValues(alpha: 0.05),

                          // 길게 누르면 수정 화면
                          onLongPress: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddExpenseScreen(expense: expense),
                              ),
                            );

                            await loadExpenses();
                          },

                          child: ListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 10,
                              right: 5,
                            ),

                            // 메모 및 결제 수단
                            title: Text(
                              '(${expense.paymentMethod == 'card' ? '카드' : '현금'}) '
                              '${expense.memo}',
                              style: const TextStyle(fontSize: 20),
                            ),

                            // 날짜
                            subtitle: Text(
                              DateFormat('yyyy.MM.dd').format(expense.date),
                            ),

                            // 금액 및 삭제 버튼
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 금액
                                Text(
                                  '-${NumberFormat('#,###').format(expense.amount)}원',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 46, 46, 46),
                                  ),
                                ),

                                const SizedBox(width: 4),

                                // 삭제 버튼
                                Material(
                                  color: const Color.fromARGB(
                                    30,
                                    237,
                                    124,
                                    116,
                                  ),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    splashColor: const Color.fromARGB(
                                      50,
                                      237,
                                      124,
                                      116,
                                    ),

                                    onTap: () async {
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('이걸 지우실 건가요?'),
                                            content: const Text(
                                              '지우면 다시 복구 안됨요 ㅎ',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                child: const Text('취소'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },
                                                child: const Text(
                                                  '삭제',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (result == true) {
                                        await DatabaseHelper.deleteExpense(
                                          expense.id!,
                                        );

                                        await loadExpenses();
                                      }
                                    },

                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.delete,
                                        color: Color.fromARGB(
                                          255,
                                          237,
                                          124,
                                          116,
                                        ),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      // ==================================================
      // 지출 추가 버튼
      // ==================================================
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              );

              await loadExpenses();
            },
            child: const Icon(Icons.add, size: 35),
          ),
        ),
      ),
    );
  }
}
