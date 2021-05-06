

import 'package:flutter/cupertino.dart';

class Trip{

  String name;
  DateTime date;
  Image img;

  Trip(String _name, String _date){
    this.name = _name;
    this.date = DateTime.parse(_date);
  }

  Trip.full(String _name, String _date, Image _img){
    this.name = _name;
    this.date = DateTime.parse(_date);
    this.img = _img;
  }

  void changeDate(String _date){
    this.date = DateTime.parse(_date);
  }

  void addImage(Image _img){
    this.img = _img;
  }
}