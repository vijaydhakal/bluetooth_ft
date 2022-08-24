import 'package:flutter/cupertino.dart';
import 'package:bluetooth_ft/core/constants/styles/styles.dart';

class TerminalListRow extends StatelessWidget{

  final bool isCommandText;
  final String dateTime;
  final String content;

  const TerminalListRow({Key? key, required this.isCommandText, required this.dateTime, required this.content,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        children: <Widget>[
          Text(dateTime, style: AppStyle.textBody1,),
          const Padding(padding: EdgeInsets.only(left: 4.0)),
          Text(content, style: isCommandText ?  AppStyle.textBody7 : AppStyle.textBody5,)
        ]
    );
  }
}