import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:big_decimal/big_decimal.dart';
import '/common.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
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
  final outputController = TextEditingController();

  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  bool validation(String rText, String nText) {
    double r = 0.0;
    int n = 0;

    try {
      r = double.parse(rText);
    } on Exception {
      Common.snackBar(context, "확률을 올바르게 입력해주세요.");
      return false;
    }

    if (r > 100) {
      Common.snackBar(context, "확률은 100을 넘을 수 없습니다.");
      return false;
    }

    try {
      n = int.parse(nText);
    } on Exception {
      Common.snackBar(context, "시행횟수를 올바르게 입력해주세요.");
      return false;
    }

    return true;
  }

  //버튼 클릭 이벤트.
  void clickEvent() {
    String rText = perCentController.text;
    String nText = countController.text;

    double r = 0.0;
    int n = 0;

    if (validation(rText, nText)) {
      r = double.parse(rText) * 0.01;
      n = int.parse(nText);
    } else {
      return;
    }

    double sum = 0.0;
    double remain = 100.0;
    double zero = 0.0;

    String result = "";
    BigDecimal hundred = BigDecimal.fromBigInt(BigInt.from(100));

    for (int i = 0; i <= 4; i++) {
      if (i > n) {
        break;
      }
      BigDecimal percent = calculator(n, r, i);

      percent *= hundred;
      double pp = makeDouble(percent.toString());

      // print("percent : " + percent.toString());
      // print("pp " + pp.toString());
      if (i == 0) {
        zero = pp;
      }
      if (i > 0) {
        sum += pp;
      }
      result += i.toString() + " 번 나올 확률 " + pp.toStringAsFixed(3) + "%";
      result += "\n";
    }
    remain -= sum;
    remain -= zero;

    result += "5 번 이상 확률 합 : " + (remain).toStringAsFixed(3) + "%" + "\n";
    result += "1 번 이상 확률 합 : " + (sum + remain).toStringAsFixed(3) + "%";
    outputController.text = result;
  }

  //BigDecimal => double 변환시 너무 큰 값은 변환이 안되기에
  //String으로 변환 후 자릿수를 잘라 처리한다.
  double makeDouble(String str) {
    //print("str : " + str);
    int index = str.indexOf(".");
    String head = str.substring(0, index);
    String tail = str.substring(index + 1, index + 4);

    double result = double.parse(head + "." + tail);
    return result;
  }

  //계산
  BigDecimal calculator(int n, double p, int r) {
    BigDecimal combi = combination(n, r);
    BigDecimal p1 = power(p, r);
    //print("p1 : " + p1.toString());
    double percent = 1 - p;
    BigDecimal p2 = power(percent, n - r);
    //print("p2 :" + p2.toString());
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
              labelText: '확률 입력(%)',
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
            maxLength: 5,
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
        Container(
          // 결과
          width: 300,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: TextField(
            maxLines: 7,
            enabled: false,
            textAlign: TextAlign.left,
            controller: outputController,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ])),
    );
  }
}
