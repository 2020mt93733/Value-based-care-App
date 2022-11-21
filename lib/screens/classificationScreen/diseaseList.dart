import 'dart:convert';
import 'package:valuebasedcare/commons.dart';
import 'package:valuebasedcare/global_functions.dart';
import 'package:valuebasedcare/interface/notAvailableWidget.dart';
import 'package:valuebasedcare/screens/todayScreen/detailItem.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CentresList extends StatefulWidget {
  final String diseaseID;
  final String symptomID;
  final String stateName;
  final String diseaseName;
  final bool isToday;
  final String ageSelected;

  const CentresList({
    @required this.diseaseID,
    @required this.symptomID,
    @required this.symptomName,
    @required this.diseaseName,
    @required this.ageSelected,
    Key key,
  }) : super(key: key);

  @override
  _CentresListState createState() => _CentresListState();
}

class _CentresListState extends State<CentresList> {
  List<Map> _centresList = [];
  GlobalFunctions _globalFunctions = GlobalFunctions();
  final String requestDistrictURL =
      'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=';
  Future<void> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _centresList.isNotEmpty) {
          return Padding(
            padding: EdgeInsets.all(CommonData.outerPadding),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(
                      widget.diseaseName + ', ' + widget.symptomName,
                      style: TextStyle(
                        fontSize: CommonData.smallFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    ExpandChild(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(
                          _centresList.length,
                          (index) => DetailItem(
                            map: _centresList.elementAt(index),
                            showDivider: _centresList.length > 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            _centresList.isEmpty)
          return NotAvailableWidget(widget.districtName);

          else
          return placeHolderWithText();
      },
    );
  }

  Widget placeHolderWithText() => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: CommonData.smallFont,
              height: CommonData.smallFont,
              child: LoadingIndicator(
                indicatorType: Indicator.ballScale,
                pathBackgroundColor:
                    Theme.of(context).textTheme.bodyText1.color,
              ),
            ),
            SizedBox(width: 5),
            Text(
              'Checking on ' + widget.diseaseName,
              style: TextStyle(
                fontSize: CommonData.smallFont,
                height: 1,
              ),
            ),
          ],
        ),
      );

  Future<void> _load() async {
    try {
      _centresList.clear();
      
      final String date = widget.isToday
          ? _globalFunctions.getTodayDate()
          : _globalFunctions.getTomorrowDate();

      String url;

      if (int.tryParse(widget.districtName) == null)
        url = requestDistrictURL + widget.diseaseID + '&date=' + date;
      else
        url =
            'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByPin?pincode=${widget.districtName}&date=$date';

      Response response = await _globalFunctions.getWebResponse(url);

      if (response.statusCode != 200 || response == null) return;
      var mapTemp = json.decode(response.body)['sessions'] as List<dynamic>;

      mapTemp.forEach((element) {
        Map map = element;

        String count = map['available_capacity'].toString() ?? '0';
        if (count != '0' &&
            (vaccine.contains(vaccineSelected) ||
                vaccineSelected.contains(defaultVaccine))) {
          // Compare ages with the common type.
          if (widget.ageSelected.contains(CommonData.defaultVaccineType))
            _centresList.add(map);
          else {
            // Check Ages based on user selection.
            String ageInSessionStr = map['min_age_limit'].toString().trim();
            int minAgeLimit = int.tryParse(ageInSessionStr) ?? 0;
            int userSelectedAge = int.tryParse(widget.ageSelected) ?? 0;
            if (userSelectedAge >= minAgeLimit) _centresList.add(map);
          }
        }
      });
    } catch (_) {}
  }
}
