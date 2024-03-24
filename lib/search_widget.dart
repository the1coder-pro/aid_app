import 'package:aidapp/main.dart';
import 'package:aidapp/themes.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'pages/details_page.dart';
import 'person.dart';

class SearchWidget extends SearchDelegate<Person> {
  @override
  String get searchFieldLabel => 'البحث';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context)
        .copyWith(appBarTheme: Theme.of(context).appBarTheme);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              query = '';
            }),
      )
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

  const SearchFinder({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final hiveProvider = Provider.of<HiveServiceProvider>(context);

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
                      (c.isContinuousAid ? "مستمرة" : "منقطعة").contains(query))
                  .toList();

          return results.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(child: NoRecordsSVGPicture()),
                    Center(
                      child: Text(
                        'لا توجد مساعدات',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    // passing as a custom list
                    final Person personListItem = results[index];

                    return OpenContainer(
                      transitionDuration: const Duration(milliseconds: 300),
                      closedElevation: 0,
                      openElevation: 0,
                      closedColor: Theme.of(context).colorScheme.background,
                      openBuilder: (context, _) {
                        // var selectedContactIndex =
                        //     Provider.of<HiveServiceProvider>(context,
                        //             listen: false)
                        //         .peopleBox
                        //         .values
                        //         .toList()
                        //         .indexOf(results[index]);
                        // hiveProvider.updateSelectedIndex(selectedContactIndex);
                        return DetailsPage(personListItem);
                      },
                      closedBuilder: (context, _) => ListTile(
                        title: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(personListItem.name,
                              style: const TextStyle(
                                  fontFamily: 'ibmPlexSansArabic')),
                        ),
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

  const SearchFinderResults({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final hiveProvider = Provider.of<HiveServiceProvider>(context);
    final colorChangeProvider = Provider.of<ThemeColorProvider>(context);
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
                      (c.isContinuousAid ? "مستمرة" : "منقطعة").contains(query))
                  .toList();

          return results.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(child: NoRecordsSVGPicture()),
                    Center(
                      child: Text(
                        'لا توجد مساعدات',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    // passing as a custom list
                    final Person personListItem = results[index];

                    return OpenContainer(
                      transitionDuration: const Duration(milliseconds: 300),
                      closedElevation: 0,
                      openElevation: 0,
                      openBuilder: (context, _) {
                        // var selectedContactIndex =
                        //     Provider.of<HiveServiceProvider>(context,
                        //             listen: false)
                        //         .peopleBox
                        //         .values
                        //         .toList()
                        //         .indexOf(results[index]);
                        // hiveProvider.updateSelectedIndex(selectedContactIndex);
                        return DetailsPage(personListItem);
                      },
                      closedColor: Theme.of(context).colorScheme.background,
                      closedBuilder: (context, _) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  colorChangeProvider.colorTheme == 0
                                      ? const Color(0xFFe9e9ea)
                                      : Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  colorChangeProvider.colorTheme == 0
                                      ? const Color(0xFF191c1e)
                                      : Theme.of(context).colorScheme.onPrimary,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  (personListItem.name)
                                      .toString()
                                      .substring(0, 1),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            title: Text(
                              personListItem.name.split(' ').length > 3
                                  ? "${personListItem.name.split(' ')[0]} ${personListItem.name.split(' ')[1]} ${personListItem.name.split(' ').last}"
                                  : personListItem.name,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                  fontFamily: "ibmPlexSansArabic",
                                  fontSize: 18),
                            ),
                            subtitle: RichText(
                                text: TextSpan(
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .copyWith(
                                            fontFamily: "ibmPlexSansArabic"),
                                    children: [
                                  if (personListItem.phoneNumber.isNotEmpty)
                                    TextSpan(
                                        text: "${personListItem.phoneNumber}\n",
                                        style: const TextStyle(fontSize: 15))
                                  else
                                    const TextSpan(),
                                  TextSpan(
                                      text: personListItem.aidType != 'عينية' &&
                                              personListItem.aidType !=
                                                  'رمضانية'
                                          ? "${personListItem.aidAmount} ريال"
                                          : personListItem.aidTypeDetails,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const TextSpan(text: " لأجل "),
                                  TextSpan(
                                      text: personListItem.aidType.isEmpty
                                          ? 'لا يوجد'
                                          : "${personListItem.aidType == 'عينية' || personListItem.aidType == 'رمضانية' ? 'مساعدة' : ''} ${personListItem.aidType}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const TextSpan(text: " لفترة "),
                                  TextSpan(
                                      text: personListItem.isContinuousAid
                                          ? "مستمرة"
                                          : "منقطعة",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ])),
                            isThreeLine: true,
                          )),
                    );
                  },
                );
        },
      ),
    );
  }
}

class NoRecordsSVGPicture extends StatelessWidget {
  const NoRecordsSVGPicture({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 250, width: 250, child: SvgPicture.string('''
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="1080px" height="1080px" style="shape-rendering:geometricPrecision; text-rendering:geometricPrecision; image-rendering:optimizeQuality; fill-rule:evenodd; clip-rule:evenodd" xmlns:xlink="http://www.w3.org/1999/xlink">
<g><path style="opacity:1" fill="${Theme.of(context).colorScheme.background.toHex()}" d="M -0.5,-0.5 C 359.5,-0.5 719.5,-0.5 1079.5,-0.5C 1079.5,359.5 1079.5,719.5 1079.5,1079.5C 719.5,1079.5 359.5,1079.5 -0.5,1079.5C -0.5,719.5 -0.5,359.5 -0.5,-0.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex()}" d="M 407.5,161.5 C 491.506,158.427 562.006,187.427 619,248.5C 682.355,325.928 698.022,412.261 666,507.5C 654.361,537.765 637.861,564.932 616.5,589C 710.667,683.167 804.833,777.333 899,871.5C 909.269,887.334 907.102,901.168 892.5,913C 881.607,919.202 870.941,918.869 860.5,912C 765.5,817 670.5,722 575.5,627C 574.5,626.333 573.5,626.333 572.5,627C 515.5,665.404 452.833,679.738 384.5,670C 303.644,654.032 242.811,610.532 202,539.5C 169.331,476.143 162.664,410.143 182,341.5C 210.25,259.583 265.083,203.75 346.5,174C 366.528,167.738 386.861,163.571 407.5,161.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.background.toHex()}" d="M 405.5,216.5 C 491.354,212.171 556.854,246.171 602,318.5C 631.427,374.032 635.427,431.365 614,490.5C 584.157,559.995 531.99,601.828 457.5,616C 372.409,625.526 305.576,595.36 257,525.5C 226.615,475.685 218.281,422.351 232,365.5C 254.049,293.117 301.216,245.617 373.5,223C 384.235,220.476 394.902,218.31 405.5,216.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.background.toHex()}" d="M 460.5,252.5 C 530.363,263.83 576.196,303.497 598,371.5C 612.609,436.661 595.943,492.328 548,538.5C 582.941,489.899 593.274,436.232 579,377.5C 561.159,315.162 521.659,273.496 460.5,252.5 Z"/></g>
    </svg>
    '''));
  }
}
