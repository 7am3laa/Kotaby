import 'package:flutter/material.dart';

class N {
  static pushto({required BuildContext context, required Widget screen}) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));

  static pushReplacementto(
          {required BuildContext context, required Widget screen}) =>
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => screen));

  static pushAndRemoveUntil(
          {required BuildContext context, required Widget screen}) =>
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => screen),
        (route) => false,
      );

  static pop({required BuildContext context}) => Navigator.of(context).pop();
}
