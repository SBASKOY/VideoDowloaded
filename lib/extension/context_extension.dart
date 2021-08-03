import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  void showSnackBar(Widget content) => ScaffoldMessenger.of(this).showSnackBar(new SnackBar(
   
    content: content));
  get back => Navigator.of(this).pop();
  pushReplement(model) => Navigator.push(this, MaterialPageRoute(builder: (c) => model));
}
