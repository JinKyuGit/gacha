import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:big_decimal/big_decimal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '가챠 독립시행 계산기'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final perCentController = TextEditingController();
  final countController = TextEditingController();

  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  //클릭
  void clickEvent() {
    double r = double.parse(perCentController.text);
    int n = int.parse(countController.text);

    double sum = 0.0;
    double remain = 0.0;
    double zero = 0.0;

    for (int i = 0; i <= 4; i++) {
      if (i > n) {
        break;
      }
      BigDecimal percent = calculator(n, r, i);
      double pp = percent.toDouble();
      if (i == 0) {
        zero = pp;
      }
      if (i > 0) {
        sum += pp;
      }
      print(i.toString() + " 번 나올 확률 " + percent.toDouble().toString());
    }
    remain = 100.0 - sum - zero;
    print("0번 : " + zero.toString());
    print("5번 이상 : " + remain.toString());
  }

  //계산
  BigDecimal calculator(int n, double p, int r) {
    BigDecimal combi = combination(n, r);
    BigDecimal p1 = power(p, r);
    double percent = 1 - p;
    BigDecimal p2 = power(percent, n - r);

    BigDecimal result = combi;
    result = result * p1;
    result = result * p2;

    return result;
  }

  //제곱
  BigDecimal power(double n, int r) {
    BigDecimal origin = BigDecimal.parse(n.toString());
    BigDecimal result = origin.pow(r);

    return result;
  }

  //팩토리얼
  BigDecimal factorial(int n) {
    if (n <= 1) {
      return BigDecimal.fromBigInt(BigInt.from(1));
    }
    return BigDecimal.fromBigInt(BigInt.from(n)) * factorial(n - 1);
  }

  //순열
  BigDecimal permutation(int n, int r) {
    BigDecimal t1 = factorial(n);
    BigDecimal t2 = factorial(n - r);

    return t1.divide(t2);
  }

  //조합
  BigDecimal combination(int n, int r) {
    return permutation(n, r).divide(factorial(r));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          //확률 입력란
          width: 300,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: TextField(
            controller: perCentController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter(RegExp('[0-9,.]'), allow: true),
            ],
            decoration: InputDecoration(
              labelText: '확률 입력',
            ),
          ),
        ),
        Container(
          //시행횟수 입력란
          width: 300,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: TextField(
            controller: countController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter(RegExp('[0-9]'), allow: true),
            ],
            decoration: InputDecoration(
              labelText: '시행횟수 입력',
            ),
          ),
        ),
        SizedBox(
          //계산 버튼
          width: 300,
          height: 50,
          child: ElevatedButton(
            style: style,
            onPressed: () {
              clickEvent();
            },
            child: const Text('계산'),
          ),
        ),
      ])),
    );
  }
}