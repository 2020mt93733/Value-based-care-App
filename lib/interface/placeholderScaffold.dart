import 'package:valuebasedcare/commons.dart';
import 'package:valuebasedcare/interface/placeholdSpinner.dart';
import 'package:flutter/material.dart';

class PlaceHolderScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(CommonData.appTitle),
      ),
      body: PlaceholdSpinner(),
    );
  }
}
