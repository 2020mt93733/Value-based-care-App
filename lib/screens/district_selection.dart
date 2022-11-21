import 'package:valuebasedcare/db/dataFunctions.dart';
import 'package:valuebasedcare/db/dbProvider.dart';
import 'package:valuebasedcare/db/selectedOptionProvider.dart';
import 'package:valuebasedcare/interface/locationsDropDown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class DiseaseSelection extends StatefulWidget {
  const DiseaseSelection({Key key}) : super(key: key);

  @override
  _DiseaseSelectionState createState() => _DiseaseSelectionState();
}

class _DiseaseSelectionState extends State<DiseaseSelection> {
  DatabaseProvider _databaseProvider;
  SelectedOptionProvider _selectedOptionProvider;

  Map<String, int> districts = {};
  String dropDownValState;
  final DataFunctions _dataFunctions = DataFunctions();

  @override
  Widget build(BuildContext context) {
    _databaseProvider = ReadContext(context).read<DatabaseProvider>();
    _selectedOptionProvider =
        ReadContext(context).read<SelectedOptionProvider>();

    return LocationsDropDown(
      futureMethod: loadData(),
      value: dropDownValState,
      list: diseases,
      onChangeEvent: onSelectedEvent,
      hintText: 'Select Disease',
    );
  }

  void onSelectedEvent(String value) {
    try {
      _selectedOptionProvider.diseaseID = disease[value];
      _selectedOptionProvider.diseaseName = value;

      if (mounted) setState(() => dropDownValState = value);
      _selectedOptionProvider.update();
    } catch (_) {}
  }

  Future<void> loadData() async {
    try {
      disease.clear();
      if (_selectedOptionProvider.stateName == null) return;

      disease.clear();
      final Database db = _databaseProvider.database;
      final String tableName =
          _selectedOptionProvider.stateName.trim().replaceAll(' ', '_');

      if (await _dataFunctions.isTableNotExists(tableName, db))
        await _dataFunctions.getDiseases(db, _selectedOptionProvider.symptomID,
            _selectedOptionProvider.symptomName);

      var data = await db.rawQuery('SELECT * FROM $tableName');

      data.forEach((Map<String, dynamic> element) {
        final String name = element['diseaseName'];
        final int id = element['diseaseID'];
        districts.addAll({name: id});
      });
    } catch (_) {
      return;
    }
  }
}
