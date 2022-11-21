import 'package:flutter/material.dart';

class SelectedOptionProvider extends ChangeNotifier {
  String symptomName;
  String diseaseName;
  int symptomID;
  int diseaseID;

  void update() => notifyListeners();
}
