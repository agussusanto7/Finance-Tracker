import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../constants/app_constants.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _equation = "0";
  String _result = "0";
  String _expression = "";
  String _history = "";

  String _formatEquation(String eq) {
    final regex = RegExp(r'(\d+)(,\d+)?');
    return eq.replaceAllMapped(regex, (Match m) {
      String integerPart = m[1]!;
      String fractionalPart = m[2] ?? '';
      
      String formattedInteger = '';
      int count = 0;
      for (int i = integerPart.length - 1; i >= 0; i--) {
        if (count != 0 && count % 3 == 0) {
          formattedInteger = '.' + formattedInteger;
        }
        formattedInteger = integerPart[i] + formattedInteger;
        count++;
      }
      return formattedInteger + fractionalPart;
    });
  }

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "AC") {
        _equation = "0";
        _result = "0";
        _history = "";
      } else if (buttonText == "⌫") {
        _equation = _equation.substring(0, _equation.length - 1);
        if (_equation == "") {
          _equation = "0";
        }
      } else if (buttonText == "+/-") {
        if (_equation[0] != '-') {
          _equation = '-$_equation';
        } else {
          _equation = _equation.substring(1);
        }
      } else if (buttonText == "%") {
        try {
          double val = double.parse(_equation);
          val = val / 100;
          _equation = val.toString();
          if (_equation.endsWith(".0")) {
            _equation = _equation.substring(0, _equation.length - 2);
          }
        } catch (e) {
          // Abaikan jika bukan angka
        }
      } else if (buttonText == "=") {
        _history = _formatEquation(_equation); // Simpan history sebelum dihitung
        _expression = _equation;
        _expression = _expression.replaceAll('×', '*');
        _expression = _expression.replaceAll('÷', '/');
        _expression = _expression.replaceAll(',', '.');
        
        try {
          Parser p = Parser();
          Expression exp = p.parse(_expression);

          ContextModel cm = ContextModel();
          _result = '${exp.evaluate(EvaluationType.REAL, cm)}';
          
          if (_result.endsWith(".0")) {
            _result = _result.substring(0, _result.length - 2);
          }
          // Ubah kembali titik desimal bawaan dart/math_expressions menjadi koma
          _result = _result.replaceAll('.', ',');
          _equation = _result;
        } catch (e) {
          _result = "Error";
          _equation = "Error";
        }
      } else {
        if (_equation == "0") {
          _equation = buttonText;
        } else {
          _equation = _equation + buttonText;
        }
      }
    });
  }

  Widget _buildButton(String buttonText, Color color, Color textColor, {IconData? icon}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxWidth, // Memastikan bentuk lingkaran sempurna
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: textColor,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero, // Hapus padding default agar teks muat
                ),
                onPressed: () => _buttonPressed(buttonText),
                child: icon != null 
                    ? Icon(icon, size: 28, color: textColor)
                    : Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: buttonText.length > 1 ? 22.0 : 28.0, // Perkecil font jika teks panjang
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                        maxLines: 1,
                      ),
              ),
            );
          }
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Warna untuk menyesuaikan dengan tema FinanceTracker
    final Color operatorColor = AppConstants.primaryColor;
    final Color topRowColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final Color numberColor = isDark ? Colors.grey[850]! : Colors.grey[100]!;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color topRowTextColor = isDark ? Colors.white : Colors.black87;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kalkulator',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_history.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _history,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w400,
                            color: textColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _formatEquation(_equation),
                        style: TextStyle(
                          fontSize: 64.0,
                          fontWeight: FontWeight.w300,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.only(bottom: 20.0, top: 10.0, left: 10.0, right: 10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _buildButton("AC", topRowColor, topRowTextColor),
                      _buildButton("+/-", topRowColor, topRowTextColor),
                      _buildButton("%", topRowColor, topRowTextColor),
                      _buildButton("÷", operatorColor, Colors.white),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      _buildButton("7", numberColor, textColor),
                      _buildButton("8", numberColor, textColor),
                      _buildButton("9", numberColor, textColor),
                      _buildButton("×", operatorColor, Colors.white),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      _buildButton("4", numberColor, textColor),
                      _buildButton("5", numberColor, textColor),
                      _buildButton("6", numberColor, textColor),
                      _buildButton("-", operatorColor, Colors.white),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      _buildButton("1", numberColor, textColor),
                      _buildButton("2", numberColor, textColor),
                      _buildButton("3", numberColor, textColor),
                      _buildButton("+", operatorColor, Colors.white),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      _buildButton("⌫", numberColor, textColor, icon: Icons.backspace_outlined),
                      _buildButton("0", numberColor, textColor),
                      _buildButton(",", numberColor, textColor),
                      _buildButton("=", operatorColor, Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
