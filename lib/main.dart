import 'dart:convert' show base64, jsonDecode, utf8;
import 'dart:io';

import 'package:aidapp/json_compiler.dart';
import 'package:aidapp/pages/chart_page.dart';
import 'package:aidapp/pages/printing_page.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:animations/animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xcel;
import 'pages/details_page.dart';
import 'pages/register_page.dart';
import 'person.dart';
import 'search_widget.dart';
import 'themes.dart';
import 'color_schemes.g.dart';
import "package:universal_html/html.dart" as html;

// add and use the animations package to make the app feel more smoother and natural (https://pub.dev/packages/animations)

List<String> colorSchemes = [
  "Default",
  "Blue",
  "Red",
  "Yellow",
  "Green",
  "Device"
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(PersonAdapter());
  final Box<Person> database = await Hive.openBox<Person>('personList');

  runApp(MyApp(database: database));
}

class MyApp extends StatefulWidget {
  final Box<Person> database;
  const MyApp({super.key, required this.database});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TheThemeProvider themeChangeProvider = TheThemeProvider();
  ThemeColorProvider colorChangeProvider = ThemeColorProvider();
  SelectedIdProvider selectedIdProvider = SelectedIdProvider();
  HiveServiceProvider hiveServiceProvider = HiveServiceProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    getCurrentColorTheme();
    getSelectedId();
    getDatabaseData();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  void getDatabaseData() async {
    await hiveServiceProvider.getItems();
  }

  void getCurrentColorTheme() async {
    colorChangeProvider.colorTheme =
        await colorChangeProvider.colorThemePreference.getThemeColor();
  }

  void getSelectedId() async {
    selectedIdProvider.selectedId =
        await selectedIdProvider.selectedIdPreference.getSelectedId();
  }

  ColorScheme colorSchemeChooser(int color, bool darkMode,
      {ColorScheme? deviceLightColorTheme, ColorScheme? deviceDarkColorTheme}) {
    switch (colorSchemes[color]) {
      case "Default":
        return darkMode ? greyDarkColorScheme : greyLightColorScheme;
      case "Red":
        return darkMode ? redDarkColorScheme : redLightColorScheme;
      case "Yellow":
        return darkMode ? yellowDarkColorScheme : yellowLightColorScheme;
      case "Blue":
        return darkMode ? blueDarkColorScheme : blueLightColorScheme;
      case "Green":
        return darkMode ? greenDarkColorScheme : greenLightColorScheme;
      case "Device":
        return darkMode
            ? (deviceDarkColorTheme ?? greyDarkColorScheme)
            : (deviceLightColorTheme ?? greyLightColorScheme);
    }
    return darkMode ? greyDarkColorScheme : greyLightColorScheme;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => themeChangeProvider),
          ChangeNotifierProvider(create: (_) => colorChangeProvider),
          ChangeNotifierProvider(create: (_) => selectedIdProvider),
          ChangeNotifierProvider(create: (_) => hiveServiceProvider)
        ],
        child:
            Consumer3<TheThemeProvider, ThemeColorProvider, SelectedIdProvider>(
          builder:
              (context, themeProvider, colorProvider, selectedIdProvider, _) =>
                  DynamicColorBuilder(
            builder: (deviceLightColorScheme, deviceDarkColorScheme) =>
                MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'المساعدات',
              theme: ThemeData(
                useMaterial3: true,
                textTheme: textThemeDefault,
                colorScheme: colorSchemeChooser(
                    colorChangeProvider.colorTheme, false,
                    deviceLightColorTheme: deviceLightColorScheme,
                    deviceDarkColorTheme: deviceDarkColorScheme),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                textTheme: textThemeDefault,
                colorScheme: colorSchemeChooser(
                    colorChangeProvider.colorTheme, true,
                    deviceLightColorTheme: deviceLightColorScheme,
                    deviceDarkColorTheme: deviceDarkColorScheme),
              ),
              themeMode: themeChangeProvider.darkTheme
                  ? ThemeMode.dark
                  : ThemeMode.light,
              routes: {
                '/': (context) => const MyHomePage(),
              },
              initialRoute: '/',
            ),
          ),
        ));
  }
}

enum PopupMenuItemsEnum { chartPage, printingPage, settingsPage }

extension ColorToHex on Color {
  String get toHex {
    return "#${value.toRadixString(16).substring(2)}";
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int currentPageIndex = 0;
  PopupMenuItemsEnum? selectedMenu;
  final box = Hive.box<Person>('personList');

  bool isLargeScreen = false;
  // int selectedId = -1;

  List<bool> isSelected = [];
  List<bool> getIsSelected(ThemeColorProvider colorProvider) {
    isSelected = [];
    for (String color in colorSchemes) {
      isSelected
          .add(colorSchemes[colorProvider.colorTheme] == color ? true : false);
    }
    return isSelected;
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<TheThemeProvider>(context);
    final colorChangeProvider = Provider.of<ThemeColorProvider>(context);
    final selectedIdProvider = Provider.of<SelectedIdProvider>(context);
    isSelected = getIsSelected(colorChangeProvider);

    final hiveProvider = Provider.of<HiveServiceProvider>(context);
    // hiveProvider.getItems();

    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'المساعدات',
                style: TextStyle(fontFamily: "ScheherazadeNew"),
                // style: GoogleFonts.ibmPlexSansArabic(),
              ),
              centerTitle: true,
              actions: [
                hiveProvider.people.isEmpty
                    ? Container()
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: SearchWidget(),
                          );
                        },
                      )
              ],
              leading: hiveProvider.people.isEmpty
                  ? IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () async {
                        return await settingsPage(
                            context, themeChange, colorChangeProvider);
                      })
                  : PopupMenuButton<PopupMenuItemsEnum>(
                      tooltip: 'صفحات اضافية',
                      // Callback that sets the selected popup menu item.
                      onSelected: (PopupMenuItemsEnum item) {
                        setState(() {
                          selectedMenu = item;
                          switch (selectedMenu!) {
                            // Chart Page
                            case PopupMenuItemsEnum.chartPage:
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      child: Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: ChartPage()),
                                      type: PageTransitionType.rightToLeft));

                              break;
                            // Printing Page
                            case PopupMenuItemsEnum.printingPage:
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      child: const Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: PrintingPage()),
                                      type: PageTransitionType.rightToLeft));
                              break;

                            // Settings Page
                            case PopupMenuItemsEnum.settingsPage:
                              settingsPage(
                                  context, themeChange, colorChangeProvider);
                              break;
                          }
                        });
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<PopupMenuItemsEnum>>[
                        const PopupMenuItem<PopupMenuItemsEnum>(
                          value: PopupMenuItemsEnum.chartPage,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.poll_outlined),
                              Spacer(),
                              Text('الرسم البياني',
                                  style: TextStyle(
                                      fontFamily: "IbmPlexSansArabic")),
                            ],
                          ),
                        ),
                        const PopupMenuItem<PopupMenuItemsEnum>(
                          value: PopupMenuItemsEnum.printingPage,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.print_outlined),
                              Spacer(),
                              Text('الطباعة',
                                  style: TextStyle(
                                      fontFamily: "IbmPlexSansArabic")),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<PopupMenuItemsEnum>(
                          value: PopupMenuItemsEnum.settingsPage,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.settings_outlined),
                              Spacer(),
                              Text('الإعدادات',
                                  style: TextStyle(
                                      fontFamily: "IbmPlexSansArabic")),
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(Icons.more_vert),
                    ),
            ),
            body: OrientationBuilder(builder: (context, orientation) {
              if (MediaQuery.of(context).size.width > 600) {
                isLargeScreen = true;
              } else {
                isLargeScreen = false;
              }
              if (hiveProvider.people.isNotEmpty) {
                return Center(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Consumer<HiveServiceProvider>(
                              builder: (context, hiveService, _) =>
                                  ListView.builder(
                                      // reverse: true,
                                      itemCount: hiveProvider.people.length,
                                      itemBuilder: (context, i) {
                                        // var person = hiveService.people[i];
                                        var person = hiveProvider.getItem(i);
                                        return Slidable(
                                          // Specify a key if the Slidable is dismissible.
                                          key: const ValueKey(0),

                                          // The start action pane is the one at the left or the top side.
                                          startActionPane: ActionPane(
                                            // A motion is a widget used to control how the pane animates.
                                            motion: const ScrollMotion(),

                                            // All actions are defined in the children parameter.
                                            children: [
                                              // A SlidableAction can have an icon and/or a label.

                                              SlidableAction(
                                                onPressed: (context) =>
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            RegisterPage(
                                                                id: i)),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .tertiary,
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onTertiary,
                                                icon: Icons.edit,
                                                label: 'تعديل',
                                              ),
                                              SlidableAction(
                                                onPressed: (context) =>
                                                    deleteDialog(
                                                        context,
                                                        person,
                                                        box,
                                                        i,
                                                        selectedIdProvider),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .errorContainer,
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onErrorContainer,
                                                icon: Icons.delete,
                                                label: 'حذف',
                                              ),
                                            ],
                                          ),

                                          child: OpenContainer(
                                            closedColor: Theme.of(context)
                                                .colorScheme
                                                .background,
                                            openBuilder: (context, _) =>
                                                DetailsPage(id: i),
                                            closedBuilder: (context, _) =>
                                                Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundColor:
                                                      colorChangeProvider
                                                                  .colorTheme ==
                                                              0
                                                          ? const Color(
                                                              0xFFe9e9ea)
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                  foregroundColor:
                                                      colorChangeProvider
                                                                  .colorTheme ==
                                                              0
                                                          ? const Color(
                                                              0xFF191c1e)
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onPrimary,
                                                  child: Text(
                                                    (person.name)
                                                        .toString()
                                                        .substring(0, 1),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 20),
                                                  ),
                                                ),
                                                title: Text(
                                                  person.name
                                                              .split(' ')
                                                              .length >
                                                          3
                                                      ? "${person.name.split(' ')[0]} ${person.name.split(' ')[1]} ${person.name.split(' ').last}"
                                                      : person.name,
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          "ibmPlexSansArabic",
                                                      fontSize: 18),
                                                ),
                                                subtitle: RichText(
                                                    text: TextSpan(
                                                        style: DefaultTextStyle
                                                                .of(context)
                                                            .style
                                                            .copyWith(
                                                                fontFamily:
                                                                    "ibmPlexSansArabic"),
                                                        children: [
                                                      if (person.phoneNumber
                                                          .isNotEmpty)
                                                        TextSpan(
                                                            text:
                                                                "${person.phoneNumber}\n",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15))
                                                      else
                                                        const TextSpan(),
                                                      TextSpan(
                                                          text: person.aidType !=
                                                                      'عينية' &&
                                                                  person.aidType !=
                                                                      'رمضانية'
                                                              ? "${person.aidAmount} ريال"
                                                              : person
                                                                  .aidTypeDetails,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      const TextSpan(
                                                          text: " لأجل "),
                                                      TextSpan(
                                                          text: person.aidType
                                                                  .isEmpty
                                                              ? 'لا يوجد'
                                                              : "${person.aidType == 'عينية' || person.aidType == 'رمضانية' ? 'مساعدة' : ''} ${person.aidType}",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      const TextSpan(
                                                          text: " لفترة "),
                                                      TextSpan(
                                                          text: person
                                                                  .isContinuousAid
                                                              ? "مستمرة"
                                                              : "منقطعة",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ])),
                                                isThreeLine: true,
                                                // onTap: () {
                                                //   if (isLargeScreen) {
                                                //     // selectedId = (box.length > i ? i : -1);
                                                //     selectedIdProvider.selectedId =
                                                //         i;
                                                //     setState(() {});
                                                //   } else {
                                                //     selectedIdProvider.selectedId =
                                                //         i;
                                                //     setState(() {});
                                                //     Navigator.push(
                                                //         context,
                                                //         PageTransition(
                                                //             child: DetailsPage(
                                                //                 id: selectedIdProvider
                                                //                     .selectedId),
                                                //             type: PageTransitionType
                                                //                 .bottomToTop,
                                                //             duration:
                                                //                 const Duration(
                                                //                     milliseconds:
                                                //                         300)));
                                                //   }
                                                // },
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                            ),
                          ),
                        ),
                        if (isLargeScreen &&
                            box.values.isNotEmpty &&
                            selectedIdProvider.selectedId != -1 &&
                            box.getAt(selectedIdProvider.selectedId)!.isInBox)
                          Expanded(
                              flex: 3,
                              child: DetailsPage(
                                  id: selectedIdProvider.selectedId))
                        else
                          Container(),
                      ]),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(top: 100, right: 20, left: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: 250,
                            width: 250,
                            child: SvgPicture.string('''
                <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="1080px" height="1080px" style="shape-rendering:geometricPrecision; text-rendering:geometricPrecision; image-rendering:optimizeQuality; fill-rule:evenodd; clip-rule:evenodd" xmlns:xlink="http://www.w3.org/1999/xlink">
                <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M -0.5,-0.5 C 359.5,-0.5 719.5,-0.5 1079.5,-0.5C 1079.5,359.5 1079.5,719.5 1079.5,1079.5C 719.5,1079.5 359.5,1079.5 -0.5,1079.5C -0.5,719.5 -0.5,359.5 -0.5,-0.5 Z"/></g>
                  <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 954.5,579.5 C 955.492,587.316 955.826,595.316 955.5,603.5C 840.184,669.826 724.851,736.159 609.5,802.5C 423.707,695.435 238.041,588.102 52.5,480.5C 51.1667,472.5 51.1667,464.5 52.5,456.5C 56.0608,458.779 59.7274,460.779 63.5,462.5C 63.56,463.043 63.8933,463.376 64.5,463.5C 65.4909,459.555 65.8242,455.555 65.5,451.5C 180.24,385.379 295.074,319.379 410,253.5C 444.698,268.733 480.531,280.566 517.5,289C 561.181,302.506 601.181,322.839 637.5,350C 653.058,362.39 666.724,376.557 678.5,392.5C 724.36,403.263 767.694,420.429 808.5,444C 821.729,452.561 834.396,461.895 846.5,472C 865.5,492.333 884.5,512.667 903.5,533C 918.059,545.556 933.726,556.556 950.5,566C 950,566.5 949.5,567 949,567.5C 948.171,572.533 948.338,577.533 949.5,582.5C 951.36,581.74 953.027,580.74 954.5,579.5 Z"/></g>
                  <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M 408.5,258.5 C 437.662,270.832 467.662,280.665 498.5,288C 552.283,302.057 600.616,326.39 643.5,361C 654.067,370.897 663.9,381.397 673,392.5C 673.667,393.167 673.667,393.833 673,394.5C 561,459.167 449,523.833 337,588.5C 307.649,551.897 271.483,524.064 228.5,505C 193.577,489.803 157.577,477.803 120.5,469C 105.189,464.119 90.1889,458.452 75.5,452C 186.563,387.473 297.563,322.973 408.5,258.5 Z"/></g>
                  <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M 676.5,397.5 C 727.147,407.987 774.147,427.153 817.5,455C 840.584,470.75 860.418,489.917 877,512.5C 895.825,533.668 917.325,551.501 941.5,566C 829.749,630.96 717.915,695.793 606,760.5C 573.011,741.486 545.344,716.486 523,685.5C 486.451,648.958 443.618,622.124 394.5,605C 378.17,599.67 361.837,594.504 345.5,589.5C 456.06,525.726 566.393,461.726 676.5,397.5 Z"/></g>
                  <g><path style="opacity:1" fill="#9d9d9d" d="M 65.5,451.5 C 65.8242,455.555 65.4909,459.555 64.5,463.5C 63.8933,463.376 63.56,463.043 63.5,462.5C 64.1667,458.833 64.8333,455.167 65.5,451.5 Z"/></g>
                  <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M 69.5,454.5 C 102.449,468.74 136.449,479.907 171.5,488C 222.501,502.823 267.834,527.49 307.5,562C 316.747,571.243 325.247,581.076 333,591.5C 333.667,600.5 333.667,609.5 333,618.5C 245.582,567.874 158.082,517.374 70.5,467C 69.5363,462.934 69.203,458.767 69.5,454.5 Z"/></g>
                  <g><path style="opacity:1" fill="#8b8b8b" d="M 942.5,571.5 C 942.56,570.957 942.893,570.624 943.5,570.5C 944.814,575.652 944.814,580.652 943.5,585.5C 943.819,580.637 943.486,575.97 942.5,571.5 Z"/></g>
                  <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M 942.5,571.5 C 943.486,575.97 943.819,580.637 943.5,585.5C 832.625,650.192 721.459,714.526 610,778.5C 519.208,726.526 428.708,674.192 338.5,621.5C 338.173,611.985 338.506,602.652 339.5,593.5C 399.747,606.794 453.747,632.628 501.5,671C 515.147,683.306 527.314,696.806 538,711.5C 557.788,733.306 580.454,751.306 606,765.5C 717.977,700.431 830.143,635.764 942.5,571.5 Z"/></g>
                  <g><path style="opacity:1" fill="#969696" d="M 954.5,579.5 C 954.56,578.957 954.893,578.624 955.5,578.5C 956.821,586.991 956.821,595.324 955.5,603.5C 955.826,595.316 955.492,587.316 954.5,579.5 Z"/></g>
                  <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 339.5,593.5 C 338.506,602.652 338.173,611.985 338.5,621.5C 337.177,611.992 337.177,602.325 338.5,592.5C 339.107,592.624 339.44,592.957 339.5,593.5 Z"/></g>
                  <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 1008.5,654.5 C 1014.18,654.334 1019.84,654.501 1025.5,655C 1026.02,655.561 1026.36,656.228 1026.5,657C 1019.95,669.555 1010.61,679.555 998.5,687C 921.167,731.667 843.833,776.333 766.5,821C 757.216,826.987 750.049,825.153 745,815.5C 742.72,807.565 745.22,801.731 752.5,798C 829.833,753.333 907.167,708.667 984.5,664C 992.186,659.722 1000.19,656.556 1008.5,654.5 Z"/></g>
                  </svg>
                      ''')),
                        const Center(
                          child: Text("لا توجد مساعدات مسجلة",
                              style:
                                  TextStyle(fontSize: 25, fontFamily: "Amiri")),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: FilledButton.icon(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context).colorScheme.primary)),
                            icon: Icon(Icons.add,
                                color: Theme.of(context).colorScheme.onPrimary),
                            label: Text("إضافة مساعدة",
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary)),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => RegisterPage());
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            }),
            floatingActionButton: hiveProvider.people.isEmpty
                ? Container()
                : OpenContainer(
                    closedElevation: 0,
                    closedColor: Theme.of(context).colorScheme.background,
                    transitionDuration: const Duration(milliseconds: 500),
                    closedBuilder: (context, _) => const FloatingActionButton(
                      elevation: 0,
                      onPressed: null,
                      child: Icon(Icons.add),
                    ),
                    openBuilder: (context, _) => RegisterPage(),
                    tappable: true,
                  )));
  }

  Future<void> settingsPage(BuildContext context, TheThemeProvider themeChange,
      ThemeColorProvider colorChangeProvider) {
    final hiveServiceProvider =
        Provider.of<HiveServiceProvider>(context, listen: false);
    return showModalBottomSheet<void>(
        context: context,
        elevation: 1,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
                title: const Text("الإعدادات"),
                centerTitle: true,
              ),
              body: Center(
                  child: ListView(
                children: [
                  SwitchListTile(
                      title: const Text(
                        "الوضع الداكن",
                        style: TextStyle(fontFamily: "ibmPlexSansArabic"),
                      ),
                      value: themeChange.darkTheme,
                      onChanged: (bool value) => themeChange.darkTheme = value),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text('السمات',
                        style: TextStyle(
                            fontFamily: "ibmPlexSansArabic", fontSize: 20)),
                  ),
                  Center(
                    child: ToggleButtons(
                      isSelected: isSelected,
                      onPressed: (int index) {
                        setState(() {
                          for (int buttonIndex = 0;
                              buttonIndex < isSelected.length;
                              buttonIndex++) {
                            if (buttonIndex == index) {
                              isSelected[buttonIndex] = true;
                              colorChangeProvider.colorTheme = buttonIndex;
                            } else {
                              isSelected[buttonIndex] = false;
                            }
                          }
                        });
                      },
                      selectedBorderColor:
                          Theme.of(context).colorScheme.primary,
                      borderWidth: 4,
                      children: <Widget>[
                        ThemeButton(
                            darkColorScheme: greyDarkColorScheme,
                            lightColorScheme: greyLightColorScheme,
                            themeChange: themeChange),
                        ThemeButton(
                            darkColorScheme: blueDarkColorScheme,
                            lightColorScheme: blueLightColorScheme,
                            themeChange: themeChange),
                        ThemeButton(
                            darkColorScheme: redDarkColorScheme,
                            lightColorScheme: redLightColorScheme,
                            themeChange: themeChange),
                        ThemeButton(
                            darkColorScheme: yellowDarkColorScheme,
                            lightColorScheme: yellowLightColorScheme,
                            themeChange: themeChange),
                        ThemeButton(
                            darkColorScheme: greenDarkColorScheme,
                            lightColorScheme: greenLightColorScheme,
                            themeChange: themeChange),
                        const Icon(Icons.phone_android),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ExpansionTile(
                      title: const Text("اعدادات متقدمة",
                          style: TextStyle(fontFamily: "ibmPlexSansArabic")),
                      childrenPadding: const EdgeInsets.all(10),
                      children: [
                        const SizedBox(height: 20),
                        const Text("استخراج البيانات"),
                        const SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              OutlinedButton(
                                onPressed: () async {
                                  pw.Document pdf =
                                      await generatePdfForAllRecords(
                                          hiveServiceProvider);
                                  try {
                                    // which os is it?
                                    if (Platform.isMacOS ||
                                        Platform.isLinux ||
                                        Platform.isWindows) {
                                      String? outputFile =
                                          await FilePicker.platform.saveFile(
                                        dialogTitle:
                                            'Please select an output file:',
                                        fileName: 'file_all.pdf',
                                      );

                                      if (outputFile == null) {
                                        debugPrint("User canceled the picker");
                                      } else {
                                        final file = File(outputFile);
                                        await file
                                            .writeAsBytes(await pdf.save())
                                            .then((value) {
                                          Navigator.pop(context);

                                          return ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration: const Duration(
                                                      milliseconds: 1000),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  content: const Text(
                                                      "تم حفظ الملف بنجاح",
                                                      style: TextStyle(
                                                          fontSize: 15))));
                                        });
                                      }
                                    } else if (Platform.isAndroid ||
                                        Platform.isIOS) {
                                      String? selectedDirectory =
                                          await FilePicker.platform
                                              .getDirectoryPath();

                                      if (selectedDirectory == null) {
                                        debugPrint("User canceled the picker");
                                      } else {
                                        final file = File(
                                            "$selectedDirectory/file_all.pdf");
                                        await file
                                            .writeAsBytes(await pdf.save())
                                            .then((value) {
                                          Navigator.pop(context);
                                          return ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration: const Duration(
                                                      milliseconds: 1000),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  content: const Text(
                                                      "تم حفظ الملف بنجاح",
                                                      style: TextStyle(
                                                          fontSize: 15))));
                                        });
                                      }
                                    }
                                  } catch (e) {
                                    var savedFile = await pdf.save();
                                    List<int> fileInts = List.from(savedFile);
                                    html.AnchorElement(
                                        href:
                                            "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}")
                                      ..setAttribute("download", "file_all.pdf")
                                      ..click();
                                    if (context.mounted) {
                                      Navigator.pop(context);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              duration: const Duration(
                                                  milliseconds: 1000),
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              content: const Text(
                                                  "تم حفظ الملف بنجاح",
                                                  style: TextStyle(
                                                      fontSize: 15))));
                                    }
                                  }
                                },
                                child: const Icon(CommunityMaterialIcons
                                    .file_pdf_box_outline),
                              ),
                              OutlinedButton(
                                  onPressed: () async {
                                    List recordsOfJson = [];
                                    for (var record in hiveServiceProvider
                                        .people
                                        .getRange(0, 10)) {
                                      recordsOfJson.add(record.toJson());
                                    }

                                    var file = utf8.encode("$recordsOfJson");
                                    List<int> fileInts = List.from(file);
                                    // File file = File
                                    // File file = File();
                                    try {
                                      if (Platform.isMacOS ||
                                          Platform.isLinux ||
                                          Platform.isWindows) {
                                        String? outputFile =
                                            await FilePicker.platform.saveFile(
                                          dialogTitle:
                                              'Please select an output file:',
                                          fileName: 'file_all.json',
                                        );

                                        if (outputFile == null) {
                                          debugPrint(
                                              "User canceled the picker");
                                        } else {
                                          final file = File(outputFile);
                                          await file
                                              .writeAsBytes(fileInts)
                                              .then((value) {
                                            Navigator.pop(context);

                                            return ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    duration: const Duration(
                                                        milliseconds: 1000),
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                    content: const Text(
                                                        "تم حفظ الملف بنجاح",
                                                        style: TextStyle(
                                                            fontSize: 15))));
                                          });
                                        }
                                      } else if (Platform.isAndroid ||
                                          Platform.isIOS) {
                                        String? selectedDirectory =
                                            await FilePicker.platform
                                                .getDirectoryPath();

                                        if (selectedDirectory == null) {
                                          debugPrint(
                                              "User canceled the picker");
                                        } else {
                                          final file = File(
                                              "$selectedDirectory/file_all.json");
                                          await file
                                              .writeAsBytes(fileInts)
                                              .then((value) {
                                            Navigator.pop(context);
                                            return ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    duration: const Duration(
                                                        milliseconds: 1000),
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                    content: const Text(
                                                        "تم حفظ الملف بنجاح",
                                                        style: TextStyle(
                                                            fontSize: 15))));
                                          });
                                        }
                                      }
                                    } catch (e) {
                                      html.AnchorElement(
                                          href:
                                              "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}")
                                        ..setAttribute("download", "data.json")
                                        ..click();
                                      if (context.mounted) {
                                        Navigator.pop(context);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                duration: const Duration(
                                                    milliseconds: 1000),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                content: const Text(
                                                    "تم حفظ الملف بنجاح",
                                                    style: TextStyle(
                                                        fontSize: 15))));
                                      }
                                    }
                                  },
                                  child: const Icon(CommunityMaterialIcons
                                      .file_export_outline)),
                              OutlinedButton(
                                child: const Icon(CommunityMaterialIcons
                                    .file_excel_box_outline),
                                onPressed: () async {
                                  // excel
                                  final xcel.Workbook workbook =
                                      xcel.Workbook();
                                  final xcel.Worksheet sheet =
                                      workbook.worksheets[0];
                                  final labels = [
                                    'الاسم',
                                    'تاريخ البداية',
                                    'تاريخ النهاية',
                                    'رقم الهوية',
                                    'النوع',
                                    'المقدار',
                                    'المدة',
                                    'رقم الهاتف'
                                  ];
                                  labels.asMap().forEach((index, label) {
                                    int columnIndex = index + 1;
                                    sheet
                                        .getRangeByIndex(1, columnIndex)
                                        .setText(label);
                                  });
                                  for (var i = 0;
                                      i < hiveServiceProvider.people.length;
                                      i++) {
                                    final record =
                                        hiveServiceProvider.people[i];
                                    sheet
                                        .getRangeByIndex(i + 2, 1)
                                        .setText(record.name);
                                    sheet.getRangeByIndex(i + 2, 2).setText(
                                        intl.DateFormat('yyyy-MM-dd')
                                            .format(record.aidDates[0]));
                                    debugPrint(record.aidDates.toString());
                                    sheet.getRangeByIndex(i + 2, 3).setText(
                                        intl.DateFormat('yyyy-MM-dd').format(
                                            record.aidDates.length > 1
                                                ? record.aidDates[1]
                                                : DateTime.now()));
                                    sheet
                                        .getRangeByIndex(i + 2, 4)
                                        .setText(record.idNumber);
                                    sheet
                                        .getRangeByIndex(i + 2, 5)
                                        .setText(record.aidType);
                                    sheet
                                        .getRangeByIndex(i + 2, 6)
                                        .setText(record.aidAmount.toString());
                                    sheet.getRangeByIndex(i + 2, 7).setText(
                                        record.isContinuousAid
                                            ? 'مستمرة'
                                            : 'منقطعة');
                                    sheet
                                        .getRangeByIndex(i + 2, 8)
                                        .setText(record.phoneNumber.toString());
                                  }
                                  final List<int> bytes =
                                      workbook.saveAsStream();
//Dispose the workbook.

                                  try {
                                    // which os is it?
                                    if (Platform.isMacOS ||
                                        Platform.isLinux ||
                                        Platform.isWindows) {
                                      String? outputFile =
                                          await FilePicker.platform.saveFile(
                                              dialogTitle:
                                                  'Please select an output file:',
                                              fileName: 'file_all.xlsx');

                                      if (outputFile == null) {
                                        debugPrint("User canceled the picker");
                                      } else {
                                        final file = File(outputFile);
                                        await file
                                            .writeAsBytes(bytes)
                                            .then((value) {
                                          Navigator.pop(context);

                                          return ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration: const Duration(
                                                      milliseconds: 1000),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  content: const Text(
                                                      "تم حفظ الملف بنجاح",
                                                      style: TextStyle(
                                                          fontSize: 15))));
                                        });
                                      }
                                    } else if (Platform.isAndroid ||
                                        Platform.isIOS) {
                                      String? selectedDirectory =
                                          await FilePicker.platform
                                              .getDirectoryPath();

                                      if (selectedDirectory == null) {
                                        debugPrint("User canceled the picker");
                                      } else {
                                        final file = File(
                                            "$selectedDirectory/file_all.xlsx");
                                        await file.writeAsBytes(bytes).then(
                                            (value) => ScaffoldMessenger.of(
                                                    context)
                                                .showSnackBar(SnackBar(
                                                    duration: const Duration(
                                                        milliseconds: 1000),
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                    content: const Text(
                                                        "تم حفظ الملف بنجاح",
                                                        style: TextStyle(
                                                            fontSize: 15)))));
                                      }
                                    }
                                  } catch (e) {
                                    var savedFile = bytes;
                                    List<int> fileInts = List.from(savedFile);
                                    html.AnchorElement(
                                        href:
                                            "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}")
                                      ..setAttribute(
                                          "download", "file_all.xlsx")
                                      ..click();
                                  }
                                  workbook.dispose();
                                },
                              )
                            ]),
                        const SizedBox(height: 20),
                        const Text('استيراد البيانات'),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            OutlinedButton(
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                          // allowedExtensions: ['json'],
                                          type: FileType.any);
                                  if (result != null) {
                                    String response;
                                    if (kIsWeb) {
                                      var file = utf8
                                          .decode(result.files.single.bytes!);
                                      response = file;

                                      debugPrint(file);
                                    } else {
                                      File file =
                                          File(result.files.single.path!);
                                      response = await file.readAsString();
                                    }

                                    // File file = File(result.files.single.path!);
                                    // if (file.path.contains('.json')) {
                                    // if (file != null)
                                    List<JsonRecord> records =
                                        (jsonDecode(response) as List<dynamic>)
                                            .map((e) => JsonRecord.fromJson(e))
                                            .toList();

                                    // TODO: add Loading indecator while uploading data.

                                    // show a circular progress indicator
                                    setState(() {
                                      isLoading = true;
                                    });

                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                          );
                                        });

                                    for (var record in records) {
                                      var splitedDates = record.aidDates != null
                                          ? record.aidDates!.split(' - ')
                                          : [];

                                      await hiveServiceProvider.createItem(
                                          Person(
                                              name: record.name ?? 'لا يوجد',
                                              idNumber: record.idNumber ?? '',
                                              phoneNumber:
                                                  record.phoneNumber ?? '0',
                                              aidDates: splitedDates.isNotEmpty
                                                  ? [
                                                      intl.DateFormat(
                                                              "dd/MM/yyyy")
                                                          .parse(
                                                              splitedDates[0]),
                                                      intl.DateFormat(
                                                              "dd/MM/yyyy")
                                                          .parse(
                                                              splitedDates[1]),
                                                    ]
                                                  : [],
                                              aidType:
                                                  record.aidType ?? 'غير محدد',
                                              aidAmount:
                                                  record.aidAmount ?? 0.0,
                                              isContinuousAid:
                                                  record.isContinuousAid ??
                                                      true,
                                              notes:
                                                  record.notes ?? 'لا يوجد'));
                                    }
                                    setState(() {
                                      isLoading = false;
                                      Navigator.pop(context);
                                    });
                                    if (context.mounted) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: AlertDialog(
                                                  icon: const Icon(Icons
                                                      .check_circle_outlined),
                                                  title: const Text(
                                                      "تمت الاستيراد بنجاح"),
                                                  content: const Text(
                                                      "تمت اضافة المساعدات بنجاح"),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child:
                                                            const Text("حسنا"))
                                                  ]),
                                            );
                                          });
                                    }

                                    // debugPrint(records[0].name);
                                  }
                                  // } else {
                                  //   // User canceled the picker
                                  // }
                                },
                                child: const Icon(
                                    CommunityMaterialIcons.file_import_outline))
                          ],
                        )
                      ]),
                ],
              )),
            ),
          );
        });
  }

  Future<pw.Document> generatePdfForAllRecords(
      HiveServiceProvider hiveServiceProvider) async {
    final font =
        await fontFromAssetBundle('fonts/IBMPlexSansArabic-Regular.ttf');
    final boldFont =
        await fontFromAssetBundle('fonts/IBMPlexSansArabic-Bold.ttf');

    final pdf = pw.Document();
    pw.TextStyle tableStyle = pw.TextStyle(fontSize: 10.0, font: font);

    pw.TextStyle tableHeaderStyle = pw.TextStyle(
        fontSize: 8, font: boldFont, fontWeight: pw.FontWeight.bold);
    // debugPrint(hiveServiceProvider.people.toString());

    var recordsToPrint = hiveServiceProvider.people;

    pdf.addPage(pw.MultiPage(
        maxPages: 40,
        margin: const pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return [
            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Center(
                      child: pw.Text("جميع المساعدات المسجلة",
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 25,
                              fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(height: 5),
                  pw.Center(
                      child: pw.Text(
                          "عدد المساعدات: ${hiveServiceProvider.people.length}",
                          style: pw.TextStyle(font: font, fontSize: 20))),
                ]),
            pw.SizedBox(height: 5),
            pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Table(
                  border: pw.TableBorder.all(
                      color: PdfColors.black,
                      style: pw.BorderStyle.solid,
                      width: 1),
                  children: [
                    pw.TableRow(children: [
                      pw.Column(children: [
                        pw.Padding(
                            child:
                                pw.Text('رقم الهاتف', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('المدة', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('المقدار', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('النوع', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.only(
                                top: 4, bottom: 4, right: 2, left: 2))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child:
                                pw.Text('رقم الهوية', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('تاريخ النهاية',
                                style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('تاريخ البداية',
                                style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('الاسم', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('#', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                    ]),
                    for (var person in recordsToPrint.toList().asMap().entries)
                      pw.TableRow(children: [
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(
                                  person.value.phoneNumber.toString(),
                                  style: tableStyle.copyWith(fontSize: 10)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(
                                  person.value.isContinuousAid
                                      ? 'مستمرة'
                                      : 'منقطعة',
                                  style: tableStyle.copyWith(fontSize: 8)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(
                                  person.value.aidType != 'عينية' &&
                                          person.value.aidType != 'رمضانية'
                                      ? person.value.aidAmount.toString()
                                      : person.value.aidTypeDetails.toString(),
                                  style: tableStyle.copyWith(fontSize: 8)))
                        ]),
                        pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(person.value.aidType,
                                  style: tableStyle.copyWith(fontSize: 8)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(
                                  person.value.idNumber == ''
                                      ? '-'
                                      : person.value.idNumber.toString(),
                                  style: tableStyle.copyWith(fontSize: 8)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(
                                  person.value.aidDates.length > 1
                                      ? intl.DateFormat('yyyy/MM/dd')
                                          .format(person.value.aidDates[1])
                                      : '-',
                                  style: tableStyle.copyWith(fontSize: 8)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(
                                  intl.DateFormat('yyyy/MM/dd')
                                      .format(person.value.aidDates[0]),
                                  style: tableStyle.copyWith(fontSize: 8)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(person.value.name,
                                  style: tableStyle.copyWith(fontSize: 8)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text("${person.key + 1}",
                                  style: tableStyle.copyWith(fontSize: 10)))
                        ]),
                      ]),
                  ],
                )),
          ]; // Center
        }));

    return pdf;
  }

  Future<dynamic> deleteDialog(BuildContext context, Person? person,
      Box<Person> box, int i, SelectedIdProvider selectedIdProvider) {
    final hiveProvider =
        Provider.of<HiveServiceProvider>(context, listen: false);
    return showDialog(
        context: context,
        builder: (context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                icon: const Icon(Icons.delete_forever_outlined),
                title: Text("حذف ${person!.name}؟"),
                content: const Text("هل أنت متأكد انك تريد حذف هذه المساعدة؟"),
                actions: [
                  TextButton(
                      child: const Text("إلغاء"),
                      onPressed: () => Navigator.pop(context)),
                  OutlinedButton(
                      child: const Text("نعم"),
                      onPressed: () {
                        box.values.isNotEmpty
                            ? hiveProvider.deleteItem(i).then((value) {
                                selectedIdProvider.selectedId = -1;
                                setState(() {});

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration: const Duration(
                                            milliseconds: 1000),
                                        backgroundColor: Theme
                                                .of(context)
                                            .colorScheme
                                            .primary,
                                        content: Text(
                                            "تم حذف ${person.name} بنجاح",
                                            style: const TextStyle(
                                                fontSize: 15))));
                              })
                            : Navigator.pop(context);
                      })
                ],
              ),
            ));
  }
}

enum AidDuration { continuous, interrupted }

const List<String> aidTypes = <String>[
  'صدقة',
  'زواج',
  'مؤونة',
  'اجار',
  'بناء',
  'عينية',
  'رمضانية',
  'غير محدد',
  'أخرى'
];

class ThemeButton extends StatelessWidget {
  const ThemeButton(
      {super.key,
      required this.themeChange,
      required this.lightColorScheme,
      required this.darkColorScheme});

  final TheThemeProvider themeChange;
  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: themeChange.darkTheme
            ? darkColorScheme.background
            : lightColorScheme.background,
        child: FloatingActionButton.small(
          elevation: 0,
          onPressed: null,
          foregroundColor: themeChange.darkTheme
              ? darkColorScheme.onPrimaryContainer
              : lightColorScheme.onPrimaryContainer,
          backgroundColor: themeChange.darkTheme
              ? darkColorScheme.primaryContainer
              : lightColorScheme.primaryContainer,
          child: const Icon(Icons.add),
        ));
  }
}

class NoSelectedRecord extends StatelessWidget {
  const NoSelectedRecord({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("لا توجد مساعدة محددة")));
  }
}
