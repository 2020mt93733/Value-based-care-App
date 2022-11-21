import 'package:valuebasedcare/global_functions.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:valuebasedcare/interface/displayResult.dart';

class CenterDetailCard extends StatelessWidget {
  final Map center;
  final List session;
  final GlobalFunctions globalFunctions = GlobalFunctions();

  CenterDetailCard({@required this.center, Key key, @required this.session})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                center['name'],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 12),
            DisplayResult(
              header: 'Region': ',
              text: center['Region'],
            ),
            DisplayResult(
              header: 'Disease: ',
              text: '${center['disease_name']}',
            ),
            DisplayResult(
              header: 'Symptom: ',
              text: center['symptom_name'],
            ),
                        ExpandChild(
              child: Column(
                children: _sessions(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sessions() {
    return List.generate(session.length, (index) {
      String availableDoses =
          session.elementAt(index)['available_capacity'].toString() ?? '--';
      String doses1 =
          session.elementAt(index)['available_capacity_dose1'].toString() ??
              '--';
      String doses2 =
          session.elementAt(index)['available_capacity_dose2'].toString() ??
              '--';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index == 0) Divider(),
          DisplayResult(
            header: 'Date: ',
            text: session.elementAt(index)['date'].toString(),
          ),
          DisplayResult(
            header: 'Available Doses: ',
            text: availableDoses,
            color: globalFunctions.getColorFromAvailability(
                availabilityStr: availableDoses),
          ),
          Row(
            children: <Widget>[
              DisplayResult(
                header: 'Dose 1: ',
                text: doses1,
                color: globalFunctions.getColorFromAvailability(
                  availabilityStr: doses1,
                ),
              ),
              DisplayResult(
                header: 'Dose 2: ',
                text: doses2,
                color: globalFunctions.getColorFromAvailability(
                  availabilityStr: doses2,
                ),
              ),
            ],
          ),
          DisplayResult(
            header: 'Min Age Limit: ',
            text: session.elementAt(index)['min_age_limit'].toString(),
          ),
          DisplayResult(
            header: 'Vaccine: ',
            text: session.elementAt(index)['vaccine'].toString(),
            color: Colors.blue[800],
          ),
          Divider(),
        ],
      );
    });
  }
}
