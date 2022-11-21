import 'package:valuebasedcare/db/dataFunctions.dart';
import 'package:valuebasedcare/db/dbProvider.dart';
import 'package:valuebasedcare/db/selectedOptionProvider.dart';
import 'package:valuebasedcare/interface/locationCard.dart';
import 'package:valuebasedcare/screens/location_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserLocations extends StatefulWidget {
  @override
  _UserLocationsState createState() => _UserLocationsState();
}

class _UserLocationsState extends State<UserLocations> {
  DatabaseProvider _databaseProvider;
  SelectedOptionProvider _selectedOptionProvider;
  DataFunctions _dataFunctions = DataFunctions();
  List<Map> _list = [];

  @override
  Widget build(BuildContext context) {
    _databaseProvider = context.watch<DatabaseProvider>();
    _selectedOptionProvider =
        ReadContext(context).read<SelectedOptionProvider>();

    return FutureBuilder(
      future: process(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _list.isNotEmpty)
          return ListView(
            physics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            cacheExtent: 2000,
            children: [
              Column(
                children: List.generate(
                  _list.length,
                  (index) => LocationCard(
                    districtName: _list.elementAt(index)['diseaseName'],
                    stateName: _list.elementAt(index)['symptomName'],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(child: popUpSelector()),
            ],
          );
        else
          return Center(child: popUpSelector());
      },
    );
  }

  Future<void> process() async {
    await _dataFunctions.createUserTable(_databaseProvider.database);
    _list = await _dataFunctions.getUserTable(_databaseProvider.database);
  }

  Widget popUpSelector() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
      ),
      onPressed: () => showDialogLocations(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void showDialogLocations() => showDialog(
        context: context,
        builder: (context) => ChangeNotifierProvider.value(
          value: _databaseProvider,
          builder: (context, widget) => ChangeNotifierProvider.value(
            value: _selectedOptionProvider,
            builder: (context, widget) => LocationSelector(),
          ),
        ),
      );
}
