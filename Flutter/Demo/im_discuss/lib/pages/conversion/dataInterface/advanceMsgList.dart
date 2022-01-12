import 'package:flutter/material.dart';

class AdvanceMsgList {
  late String name;
  late Icon icon;
  // ignore: prefer_function_declarations_over_variables
  late Function onPressed = () {};
  AdvanceMsgList({name, icon, onPressed}) {
    // ignore: prefer_initializing_formals
    this.name = name;
    // ignore: prefer_initializing_formals
    this.icon = icon;
    // ignore: prefer_initializing_formals
    this.onPressed = onPressed;
  }
}
