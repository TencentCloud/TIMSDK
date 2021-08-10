import 'package:flutter/material.dart';

class AdvanceMsgList {
  late String name;
  late Icon icon;
  late Function onPressed = () {};
  AdvanceMsgList({name, icon, onPressed}) {
    this.name = name;
    this.icon = icon;
    this.onPressed = onPressed;
  }
}
