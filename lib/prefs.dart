import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'person.dart';

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

// selectedId

class TheSelectedId {
  // ignore: constant_identifier_names
  static const SELECTED_ID = "SELECTEDID";

  setSelectedId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(SELECTED_ID, id);
  }

  Future<int> getSelectedId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(SELECTED_ID) ?? -1;
  }
}

class SelectedIdProvider with ChangeNotifier {
  TheSelectedId selectedIdPreference = TheSelectedId();
  int _selectedId = -1;

  int get selectedId => _selectedId;

  set selectedId(int id) {
    _selectedId = id;
    selectedIdPreference.setSelectedId(id);
    notifyListeners();
  }
}

class HiveServiceProvider extends ChangeNotifier {
  List<Person> _people = [];
  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);
  final String personHiveBox = 'personList';

  // TODO: How about making a "selectedContact" Variable to store the selected Contact

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

  Person getItem(int index) {
    // Box<Person> box = await Hive.openBox<Person>(personHiveBox);
    // _people = box.values.toList();

    return _people[index];
  }

  // remove a record of person
  Future<void> deleteItem(int index) async {
    Box<Person> box = await Hive.openBox<Person>(personHiveBox);
    await box.deleteAt(index);
    _people = box.values.toList();
    notifyListeners();
  }

  Future<void> updateItem(int id, Person person) async {
    Box<Person> box = await Hive.openBox<Person>(personHiveBox);
    await box.putAt(id, person);
    _people = box.values.toList();
    notifyListeners();
  }
}

// shown Date
// TODO: why did you do this?

class TheSelectedDate {
  // ignore: constant_identifier_names
  static const SELECTED_DATE = "SELECTEDDATE";

  setSelectedDate(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(SELECTED_DATE, id);
  }

  Future<int> getSelectedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(SELECTED_DATE) ?? 0;
  }
}

class SelectedDateProvider with ChangeNotifier {
  TheSelectedDate selectedDatePreference = TheSelectedDate();
  int _selectedDate = 0;

  int get selectedDate => _selectedDate;

  set selectedDate(int date) {
    _selectedDate = date;
    selectedDatePreference.setSelectedDate(date);
    notifyListeners();
  }
}
