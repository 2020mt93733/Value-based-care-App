import 'package:valuebasedcare/global_functions.dart';
import 'package:valuebasedcare/interface/displayResult.dart';
import 'package:flutter/material.dart';

class DetailItem extends StatelessWidget {
  final Map map;
  final bool showDivider;
  final GlobalFunctions globalFunctions = GlobalFunctions();

  DetailItem({@required this.map, Key key, this.showDivider = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String blockName = map['address'].toString();
    final String pinCode = map['pincode'].toString();
    String address = '${map['address']}, $pinCode' ?? '';

    if (address.isEmpty) address = blockName + pinCode;
    final String availableDoses = map['available_capacity'].toString() ?? '--';
    final String doses1 = map['available_capacity_disease1'].toString() ?? '--';
    final String doses2 = map['available_capacity_disease2'].toString() ?? '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DisplayResult(
          text: map['name'].toString(),
          header: 'Name: ',
        ),
        DisplayResult(
          text: availableDoses,
          header: 'Joints affected: ',
          color: globalFunctions.getColorFromAvailability(
            availabilityStr: availableDoses,
          ),
        ),
        Row(
          children: [
            DisplayResult(
              text: doses1,
              header: 'Joint 1: ',
              color: globalFunctions.getColorFromAvailability(
                availabilityStr: doses1,
              ),
            ),
            DisplayResult(
              text: doses2,
              header: 'Joint 2: ',
              color: globalFunctions.getColorFromAvailability(
                availabilityStr: doses2,
              ),
            ),
          ],
        ),
        DisplayResult(
          text: map['disease'].toString(),
          header: 'Rheuma: ',
          color: Colors.blue[800],
        ),
        DisplayResult(
          text: map['min_age_limit'].toString(),
          header: 'Min Age Limit: ',
        ),
        DisplayResult(
          text: address,
          header: 'Address: ',
        ),
        DisplayResult(
          text: map['fee'].toString() == '0'
              ? 'Free'
              : map['fee'].toString() + '₹',
          header: 'Fee Type: ',
        ),
        if (showDivider) Divider(),
      ],
    );
  }
}
