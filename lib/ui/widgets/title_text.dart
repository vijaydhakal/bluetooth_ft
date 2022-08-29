import 'package:flutter/material.dart';

import '../../core/constants/styles/styles.dart';

class TitleText extends StatelessWidget {
  final String captionText;

  const TitleText({Key? key, required this.captionText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;

    return Container(
      width: _size.width,
      margin: const EdgeInsets.all(10.0),
      child: Text(captionText,
          style: AppStyle.textHeader2, textAlign: TextAlign.start),
    );
  }
}