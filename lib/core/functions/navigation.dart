import 'package:flutter/material.dart';

Push(BuildContext context, Widget NewScreen ){
  Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => NewScreen));
}


PushWithReplacement(BuildContext context, Widget NewScreen ){
  Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NewScreen));
}