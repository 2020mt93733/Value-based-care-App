import 'package:valuebasedcare/commons.dart';
import 'package:valuebasedcare/db/dataFunctions.dart';
import 'package:valuebasedcare/db/dbProvider.dart';
import 'package:valuebasedcare/global_functions.dart';
import 'package:valuebasedcare/interface/placeholdSpinner.dart';
import 'package:valuebasedcare/screens/floatingActions/VaccineAlerts/vaccineDropDown.dart';
import 'package:valuebasedcare/screens/todayScreen/centresList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:provider/provider.dart';

class DayScreen extends StatefulWidget {
  final bool isToday;

  const DayScreen({@required this.isToday, Key key}) : super(key: key);

  @override
  _DayScreenState createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  List<Map> _userLocations = [];
  DataFunctions _dataFunctions = DataFunctions();
  GlobalFunctions _globalFunctions = GlobalFunctions();
  DatabaseProvider _databaseProvider;
  final ScrollController _scrollController = ScrollController();
  String selectedDisease = CommonData.defaultDiseaseType;
  String selectedAge = CommonData.defaultSymptomType;

  @override
  Widget build(BuildContext context) {
    _databaseProvider = context.watch<DatabaseProvider>();

    return FutureBuilder(
      future: _loadLocations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              Text(
                'Date: ' +
                    (widget.isToday
                        ? _globalFunctions.getTodayDate()
                        : _globalFunctions.getTomorrowDate()),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 5),
              GenericTypeDropDown(
                list: _databaseProvider.DiseaseList,
                value: selectedDisease,
                onChangeEvent: setDiseaseType,
                hintText: CommonData.DiseaseHintText,
              ),
              GenericTypeDropDown(
                list: _databaseProvider.ageList,
                value: selectedAge,
                onChangeEvent: setAge,
                hintText: CommonData.ageSelectionHint,
              ),
              Divider(
                height: 15,
                thickness: 1,
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              Flexible(
                child: ScrollWrapper(
                  scrollController: _scrollController,
                  child: ListView.builder(
                    itemCount: _userLocations.length,
                    physics: AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    controller: _scrollController,
                    cacheExtent: 2000,
                    itemBuilder: (context, index) {
                      final Map item = _userLocations.elementAt(index);

                      return CentresList(
                        diseaseID: item['diseaseID'].toString(),
                        symptomID: item['symptomID'].toString(),
                        symptomName: item['symptomName'],
                        diseaseName: item['diseaseName'],
                        isToday: widget.isToday,
                        diseaseSelected: selecteddiease,
                        ageSelected: selectedAge,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        } else {
          return PlaceholdSpinner();
        }
      },
    );
  }

  Future<void> _loadLocations() async {
    try {
      _userLocations =
          await _dataFunctions.getUserTable(_databaseProvider.database);
    } catch (_) {}
  }

  void setVaccineType(String value) => setState(() => selecteddisease = value);
  void setAge(String value) => setState(() => selectedAge = value);
}
