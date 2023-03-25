// import 'package:contacts_app/screens/contact_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

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
    return SearchFinder(query: query);
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
    return ValueListenableBuilder(
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
                    c.notes.toLowerCase().contains(query))

                // .where((c) => c.aidDates.toLowerCase().contains(query))

                // .where((c) => c.isContinuousAid.toLowerCase().contains(query))

                .toList();

        return results.isEmpty
            ? Center(
                child: Text(
                  'No results found !',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                      ),
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  // passing as a custom list
                  final Person contactListItem = results[index];

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DetailsPage(person: results[index])));
                    },
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contactListItem.name,
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          results[index].name,
                          textScaleFactor: 1.0,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                  );
                },
              );
      },
    );
  }
}
