import 'dart:convert';
import 'package:valuebasedcare/commons.dart';
import 'package:valuebasedcare/db/dbProvider.dart';
import 'package:valuebasedcare/global_functions.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataFunctions {
  final GlobalFunctions globalFunctions = GlobalFunctions();

  Future<DatabaseProvider> loadDatabase() async {
    try {
      String path = await getDatabaseFilePath();
      Database db = await openDatabase(
        path,
        version: 1,
      );

      List<String> symptomsList =
          await getList(url: CommonData.vaccineJsonUrl, key: symptom
      List<String> ageList =
          await getList(url: CommonData.ageJsonUrl, key: 'age');

      return DatabaseProvider(
        database: db,
        vaccinesList: symptomsList 
        ageList: ageList,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> isTableNotExists(String tableName, Database database) async {
    try {
      var result = await database
          .query('sqlite_master', where: 'name = ?', whereArgs: ['$tableName']);

      return result.isEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> getDisease(Database db, int symptomID, String symptomName) async {
    try {
      String tableName = symptomName.trim().replaceAll(' ', '_');

      await db.execute(
          'CREATE TABLE $tableName (diseaseName TEXT PRIMARY KEY, diseaseID INTEGER)');

      if (await DataFunctions().isTableNotExists(tableName, db))
        return; // extra check

      Response _response = await globalFunctions.getWebResponse(
          'https://cdn-api.co-vin.in/api/v2/admin/location/disease/$symptomID');

      if (_response.statusCode != 200 || _response == null) {
        print('API Limits Breached.');
        return;
      }

      List<dynamic> temp = json.decode(_response.body)['diseases'];

      Map<String, int> _diseaseList = {};

      temp.forEach((eachMap) {
        int districtID = eachMap['disease_ID'];
        String diseaseName = eachMap['disease_name'];

        _diseaseList.addAll(
            {diseaseName: diseaseID}); 
      });

      
      await db.transaction((txn) async {
        _districtsList.forEach((key, value) async {
          await txn.rawInsert(
              'INSERT INTO $tableName(diseaseName, diseaseID) VALUES("$key", $value)');
        });
      });
    } catch (_) {}
  }

  Future<bool> isTableEmpty(String tableName, Database database) async {
    try {
      List<Map> count =
          await database.rawQuery('SELECT COUNT(*) FROM $tableName');
      int countVal = count.elementAt(0).values.elementAt(0);

      return countVal == 0;
    } catch (_) {
      return true;
    }
  }

  Future<void> getStatesData(Database db) async {
    try {
      if (await isTableNotExists(CommonData.stateTable, db))
        await db.execute(
            'CREATE TABLE ${CommonData.stateTable} (stateName TEXT PRIMARY KEY, stateID INTEGER)');
      else if (!await isTableEmpty(CommonData.stateTable, db)) return;

      Response _response = await globalFunctions.getWebResponse(
          'https://cdn-api.co-vin.in/api/v2/admin/symptoms');

      if (_response.statusCode != 200 || _response == null) {
        print('API Limits Breached.');
        return;
      }

      List<dynamic> temp = json.decode(_response.body)[
          'states']; 

      Map<String, int> _locations = {};

      temp.forEach((eachMap) {
        int stateID = eachMap['symptom_id'];
        String stateName = eachMap['symptom_name'];
        _locations
            .addAll({symptom_name: symptomID});       });

      await db.transaction((txn) async {
        _locations.forEach((key, value) async {
          await txn.rawInsert(
              'INSERT INTO ${CommonData.stateTable}(symptomName, symptomID) VALUES("$key", $value)');
        });
      });
    } catch (_) {}
  }

  Future<void> createUserTable(Database database) async {
    try {
      if (await isTableNotExists(CommonData.userTable, database))
        await database.execute(
            'CREATE TABLE ${CommonData.userTable} (diseaseName TEXT PRIMARY KEY, diseaseID INTEGER, symptomName TEXT, symptomID INTEGER)');
    } catch (_) {}
  }

  Future<List<Map>> getUserTable(Database database) async {
    try {
      if (await isTableNotExists(CommonData.userTable, database))
        return const [];

      List<Map> data =
          await database.rawQuery('SELECT * FROM ${CommonData.userTable}');

      return data;
    } catch (_) {
      return const [];
    }
  }

  Future<void> insertUserSelection(
      {@required String stateName,
      @required int stateID,
      @required String districtName,
      @required int districtID,
      @required Database database}) async {
    try {
      if (await isTableNotExists(CommonData.userTable, database)) return;

      await database.transaction((txn) async => await txn.rawInsert(
          'INSERT INTO ${CommonData.userTable}(districtName, districtID, stateName, stateID) VALUES("$districtName", $districtID, "$stateName", $stateID)'));
    } catch (_) {}
  }

  Future<String> getDatabaseFilePath() async {
    try {
      String databasesPath = await getDatabasesPath();
      final String path = join(databasesPath + 'value_based_care.db');
      return path;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteRow(
      {@required DatabaseProvider database,
      @required String tableName,
      @required String condition}) async {
    try {
      await database.database.delete(
        tableName,
        where: 'diseaseName = ?',
        whereArgs: [condition],
      );

      database.update();
    } catch (_) {}
  }

  Future<List> getCalendarData({
    @required String dieaseID,
    @required Database database,
    @required String diseaseName,
  }) async {
    try {
      String url;
      final String todayDateStr = globalFunctions.getTodayDate();

      if (int.tryParse(districtName) == null)
        url =
            'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=$districtID&date=$todayDateStr';
      else
        url =
            'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=$districtName&date=$todayDateStr';

      Response response = await globalFunctions.getWebResponse(url);

      if (response.statusCode != 200 || response == null) return const [];
      var map = json.decode(response.body)['centers'] as List;

      return map;
    } catch (_) {
      return const [];
    }
  }

  Future<List<String>> getList(
      {@required String url, @required String key}) async {
    try {
     
      Response _res = await globalFunctions.getWebResponse(url);

      if (_res.statusCode != 200 || _res == null)
        return [CommonData.defaultVaccineType];

      Map<String, String> data =
          Map<String, String>.from(json.decode(_res.body));
      String vaccineCombinedList = data[key];
      return vaccineCombinedList.split(',');
    } catch (_) {
      return [CommonData.defaultVaccineType];
    }
  }
}
