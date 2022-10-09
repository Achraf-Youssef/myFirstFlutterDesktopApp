import 'package:flutter_application/program.dart';

class Task {
  String title;
  String subtitle;
  String date;
  List<Program> programList;

  Task(this.title, this.subtitle, this.date, this.programList);
}