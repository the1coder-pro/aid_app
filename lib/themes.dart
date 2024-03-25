import 'dart:collection';

import 'package:aidapp/person.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Dark/Light Theme

class TheThemePreference {
  // ignore: constant_identifier_names
  static const THEME_STATUS = "THEMESTATUS";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS) ?? false;
  }
}

class TheThemeProvider with ChangeNotifier {
  TheThemePreference darkThemePreference = TheThemePreference();
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }
}

// Color Theme

class TheColorThemePreference {
  // ignore: constant_identifier_names
  static const THEME_COLOR = "THEMECOLOR";

  setThemeColor(int color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(THEME_COLOR, color);
  }

  Future<int> getThemeColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(THEME_COLOR) ?? 0;
  }
}

class ThemeColorProvider with ChangeNotifier {
  TheColorThemePreference colorThemePreference = TheColorThemePreference();
  int _colorTheme = 0;

  int get colorTheme => _colorTheme;

  set colorTheme(int color) {
    _colorTheme = color;
    colorThemePreference.setThemeColor(color);
    notifyListeners();
  }
}

// fix this provider and make it work with Hive better (https://github.com/singlesoup/contacts_app/blob/master/lib/provider/db_provider.dart)
class HiveServiceProvider extends ChangeNotifier {
  List<Person> _people = [];

  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);
  final String personHiveBox = 'personList';

  final Box<Person> peopleBox = Hive.box<Person>('personList');

  int get personCount => _people.length;

  int _selectedPersonIndex = 0;

  int get selectedPersonIndex => _selectedPersonIndex;

  set selectedPersonIndex(int index) {
    _selectedPersonIndex = index;
  }

  // Create new record for person.
  Future<void> createItem(Person person) async {
    Box<Person> box = await Hive.openBox<Person>(personHiveBox);
    await box.add(person);
    _people.add(person);
    _people = box.values.toList();
    notifyListeners();
  }

  Future<void> getItems() async {
    Box<Person> box = await Hive.openBox<Person>(personHiveBox);
    _people = box.values.toList();
    notifyListeners();
  }

  // remove a record of person
  Future<void> deleteItem(int index) async {
    Box<Person> box = await Hive.openBox<Person>(personHiveBox);
    await box.deleteAt(index);
    _people = box.values.toList();
    notifyListeners();
  }

  // update a record of person
  Future<void> updateItem({required int index, required Person person}) async {
    Box<Person> box = await Hive.openBox<Person>(personHiveBox);
    await box.putAt(index, person);
    _people = box.values.toList();
    notifyListeners();
  }
}
