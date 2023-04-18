// import 'package:contacts_app/screens/contact_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'main.dart';
import 'person.dart';

class SearchWidget extends SearchDelegate<Person> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchFinderResults(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SearchFinder(query: query);
  }
}

class SearchFinder extends StatelessWidget {
  final String query;

  const SearchFinder({Key? key, required this.query}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ValueListenableBuilder(
        valueListenable: Hive.box<Person>('personList').listenable(),
        builder: (context, Box<Person> contactsBox, _) {
          ///* this is where we filter data
          var results = query.isEmpty
              ? contactsBox.values.toList() // whole list
              : contactsBox.values
                  .where((c) =>
                      c.name.toLowerCase().contains(query) ||
                      c.idNumber.toLowerCase().contains(query) ||
                      c.phoneNumber.toString().contains(query) ||
                      c.aidAmount.toString().contains(query) ||
                      c.aidType.toLowerCase().contains(query) ||
                      (c.isContinuousAid ? "مستمرة" : "منقطعة")
                          .contains(query) ||
                      c.notes.toLowerCase().contains(query))

                  // .where((c) => c.isContinuousAid.toLowerCase().contains(query))

                  .toList();

          return results.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد مساعدات',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    // passing as a custom list
                    final Person personListItem = results[index];

                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailsPage(id: index)),
                        );
                      },
                      title: Text(
                        personListItem.name,
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

class SearchFinderResults extends StatelessWidget {
  final String query;

  const SearchFinderResults({Key? key, required this.query}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ValueListenableBuilder(
        valueListenable: Hive.box<Person>('personList').listenable(),
        builder: (context, Box<Person> contactsBox, _) {
          ///* this is where we filter data
          var results = query.isEmpty
              ? contactsBox.values.toList() // whole list
              : contactsBox.values
                  .where((c) =>
                      c.name.toLowerCase().contains(query) ||
                      c.idNumber.toLowerCase().contains(query) ||
                      c.phoneNumber.toString().contains(query) ||
                      c.aidAmount.toString().contains(query) ||
                      c.aidType.toLowerCase().contains(query) ||
                      (c.isContinuousAid ? "مستمرة" : "منقطعة")
                          .contains(query) ||
                      c.notes.toLowerCase().contains(query))

                  // .where((c) => c.aidDates.toLowerCase().contains(query))

                  .toList();

          return results.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد مساعدات',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    // passing as a custom list
                    final Person personListItem = results[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (personListItem.name).toString().substring(0, 1),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        personListItem.name,
                        style: const TextStyle(fontSize: 15),
                      ),
                      subtitle: RichText(
                          text: TextSpan(
                              // TODO: Fix the style to look alike the main one
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                            TextSpan(
                                text: "${personListItem.aidAmount} ريال",
                                style: TextStyle(
                                    fontWeight: personListItem.aidAmount
                                            .toString()
                                            .contains(query)
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                            const TextSpan(text: " لأجل "),
                            TextSpan(
                                text: personListItem.aidType,
                                style: TextStyle(
                                    fontWeight:
                                        personListItem.aidType.contains(query)
                                            ? FontWeight.bold
                                            : FontWeight.normal)),
                            const TextSpan(text: " لفترة "),
                            TextSpan(
                                text: personListItem.isContinuousAid
                                    ? "مستمرة"
                                    : "منقطعة",
                                style: TextStyle(
                                    fontWeight: (personListItem.isContinuousAid
                                                ? "مستمرة"
                                                : "منقطعة")
                                            .contains(query)
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                          ])),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailsPage(id: index)),
                        );
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}
