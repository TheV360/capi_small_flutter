import 'package:flutter/material.dart';

class DividerText extends StatelessWidget {
  final String label;

  const DividerText({super.key, required this.label});
  // TODO: builder pattern variant where arbitrary widgets can be put in center

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
        child: Container(
            margin: const EdgeInsets.only(left: 10.0, right: 20.0),
            child: Divider()),
      ),
      Text(label),
      Expanded(
        child: Container(
            margin: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: Divider()),
      ),
    ]);
  }
}
