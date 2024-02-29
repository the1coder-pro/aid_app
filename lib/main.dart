import 'package:aid_app/chart_page.dart';
import 'package:aid_app/print_page.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:intl/intl.dart' as intl;
import 'person.dart';
import 'search_widget.dart';
import 'themes.dart';
import 'color_schemes.g.dart';

// ignore: non_constant_identifier_names
String VERSION_NUMBER = "0.70";
List<String> colorSchemes = [
  "Default",
  "Blue",
  "Red",
  "Yellow",
  "Green",
  "Device"
];

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(PersonAdapter());
  await Hive.openBox<Person>('personList');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TheThemeProvider themeChangeProvider = TheThemeProvider();
  ThemeColorProvider colorChangeProvider = ThemeColorProvider();
  SelectedIdProvider selectedIdProvider = SelectedIdProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    getCurrentColorTheme();
    getSelectedId();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
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
    return ChangeNotifierProvider(
      create: (_) => themeChangeProvider,
      child: Consumer<TheThemeProvider>(
        builder: (BuildContext context, value, child) => DynamicColorBuilder(
          builder: (deviceLightColorScheme, deviceDarkColorScheme) =>
              ChangeNotifierProvider(
            create: (_) => colorChangeProvider,
            child: Consumer<ThemeColorProvider>(
              builder: (BuildContext context, value, change) =>
                  ChangeNotifierProvider(
                create: (_) => selectedIdProvider,
                child: Consumer<SelectedIdProvider>(
                  builder: (BuildContext context, value, change) => MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Aid App',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum SampleItem { itemOne, itemTwo, itemThree }

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
  SampleItem? selectedMenu;
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

  @override
  void initState() {
    // TODO: implement initState
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<TheThemeProvider>(context);
    final colorChangeProvider = Provider.of<ThemeColorProvider>(context);
    final selectedIdProvider = Provider.of<SelectedIdProvider>(context);
    isSelected = getIsSelected(colorChangeProvider);

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
            actions: box.isEmpty
                ? [
                    IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () async {
                          return await appearancePage(
                              context, themeChange, colorChangeProvider);
                        })
                  ]
                : [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: SearchWidget(),
                        );
                      },
                    ),
                  ],
            leading: box.isEmpty
                ? Container()
                : PopupMenuButton<SampleItem>(
                    tooltip: 'صفحات اضافية',
                    // Callback that sets the selected popup menu item.
                    onSelected: (SampleItem item) {
                      setState(() {
                        selectedMenu = item;
                        switch (selectedMenu!) {
                          // Chart Page
                          case SampleItem.itemOne:
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: ChartPage()),
                                    type: PageTransitionType.rightToLeft));

                            break;
                          // Printing Page
                          case SampleItem.itemTwo:
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: const Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: PrintPage()),
                                    type: PageTransitionType.rightToLeft));
                            break;

                          // Settings Page
                          case SampleItem.itemThree:
                            appearancePage(
                                context, themeChange, colorChangeProvider);
                            break;
                        }
                      });
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<SampleItem>>[
                      const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemOne,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.poll_outlined),
                            Spacer(),
                            Text('الرسم البياني'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.print_outlined),
                            Spacer(),
                            Text('الطباعة'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemThree,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.settings_outlined),
                            Spacer(),
                            Text('الإعدادات'),
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
            if (box.isNotEmpty) {
              return Center(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: ValueListenableBuilder(
                            valueListenable: box.listenable(),
                            builder: (context, Box<Person> box, _) {
                              return ListView.builder(
                                  itemCount: box.length,
                                  itemBuilder: (context, i) {
                                    var person = box.getAt(i);
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
                                                deleteDialog(context, person,
                                                    box, i, selectedIdProvider),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .onError,
                                            icon: Icons.delete,
                                            label: 'حذف',
                                          ),
                                          SlidableAction(
                                            onPressed: (context) => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    RegisterPage(id: i)),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .onTertiary,
                                            icon: Icons.edit,
                                            label: 'تعديل',
                                          ),
                                        ],
                                      ),

                                      child: ListTile(
                                        leading: CircleAvatar(
                                          child: Text(
                                            (person!.name)
                                                .toString()
                                                .substring(0, 1),
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                        title: Text(
                                          person.name.split(' ').length > 3
                                              ? "${person.name.split(' ')[0]} ${person.name.split(' ')[1]} ${person.name.split(' ').last}"
                                              : person.name,
                                          style: const TextStyle(
                                              fontFamily: "ibmPlexSansArabic",
                                              fontSize: 18),
                                        ),
                                        subtitle: RichText(
                                            text: TextSpan(
                                                style: DefaultTextStyle.of(
                                                        context)
                                                    .style
                                                    .copyWith(
                                                        fontFamily:
                                                            "ibmPlexSansArabic"),
                                                children: [
                                              if (person.phoneNumber != 0)
                                                TextSpan(
                                                    text:
                                                        "${person.phoneNumber}\n",
                                                    style: const TextStyle(
                                                        fontSize: 15))
                                              else
                                                const TextSpan(),
                                              TextSpan(
                                                  text:
                                                      "${person.aidAmount} ريال",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const TextSpan(text: " لأجل "),
                                              TextSpan(
                                                  text: person.aidType.isEmpty
                                                      ? 'لا يوجد'
                                                      : person.aidType,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const TextSpan(text: " لفترة "),
                                              TextSpan(
                                                  text: person.isContinuousAid
                                                      ? "مستمرة"
                                                      : "منقطعة",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ])),
                                        isThreeLine: true,
                                        onTap: () {
                                          if (isLargeScreen) {
                                            // selectedId = (box.length > i ? i : -1);
                                            selectedIdProvider.selectedId = i;
                                            setState(() {});
                                          } else {
                                            selectedIdProvider.selectedId = i;
                                            setState(() {});
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    child: DetailsPage(
                                                        id: selectedIdProvider
                                                            .selectedId),
                                                    type: PageTransitionType
                                                        .bottomToTop,
                                                    duration: const Duration(
                                                        milliseconds: 300)));
                                            // Navigator.push(context,
                                            //     MaterialPageRoute(
                                            //   builder: (context) {
                                            //     return DetailsPage(
                                            //         id: selectedIdProvider
                                            //             .selectedId);
                                            //   },
                                            // ));
                                          }
                                        },
                                      ),
                                    );
                                  });
                            },
                          ),
                        ),
                      ),
                      if (isLargeScreen &&
                          box.values.isNotEmpty &&
                          selectedIdProvider.selectedId != -1 &&
                          box.getAt(selectedIdProvider.selectedId)!.isInBox)
                        Expanded(
                            flex: 2,
                            child:
                                DetailsPage(id: selectedIdProvider.selectedId))
                      else
                        Container(),
                    ]),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 100, right: 20, left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 300, width: 300, child: SvgPicture.string('''
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="1080px" height="1080px" style="shape-rendering:geometricPrecision; text-rendering:geometricPrecision; image-rendering:optimizeQuality; fill-rule:evenodd; clip-rule:evenodd" xmlns:xlink="http://www.w3.org/1999/xlink">
<g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M -0.5,-0.5 C 359.5,-0.5 719.5,-0.5 1079.5,-0.5C 1079.5,359.5 1079.5,719.5 1079.5,1079.5C 719.5,1079.5 359.5,1079.5 -0.5,1079.5C -0.5,719.5 -0.5,359.5 -0.5,-0.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 222.5,245.5 C 271.516,250.837 319.182,262.004 365.5,279C 418.192,297.682 468.859,320.682 517.5,348C 532.167,348.667 546.833,348.667 561.5,348C 640.525,302.824 724.525,270.491 813.5,251C 828.021,247.851 842.687,246.185 857.5,246C 858.126,246.75 858.626,247.584 859,248.5C 859.5,256.493 859.666,264.493 859.5,272.5C 869.506,272.334 879.506,272.5 889.5,273C 890.126,273.75 890.626,274.584 891,275.5C 891.5,283.827 891.666,292.16 891.5,300.5C 901.506,300.334 911.506,300.5 921.5,301C 922.333,301.833 923.167,302.667 924,303.5C 924.5,314.495 924.667,325.495 924.5,336.5C 931.175,336.334 937.842,336.5 944.5,337C 945.416,337.374 946.25,337.874 947,338.5C 947.5,494.833 947.667,651.166 947.5,807.5C 819.507,811.74 691.84,820.574 564.5,834C 546.5,834.667 528.5,834.667 510.5,834C 384.528,820.088 258.195,811.255 131.5,807.5C 131.333,651.5 131.5,495.5 132,339.5C 132.833,338.667 133.667,337.833 134.5,337C 141.158,336.5 147.825,336.334 154.5,336.5C 154.333,325.495 154.5,314.495 155,303.5C 155.833,302.667 156.667,301.833 157.5,301C 167.828,300.5 178.161,300.334 188.5,300.5C 188.334,291.827 188.5,283.16 189,274.5C 189.5,274 190,273.5 190.5,273C 200.161,272.5 209.828,272.334 219.5,272.5C 219.334,264.493 219.5,256.493 220,248.5C 221.045,247.627 221.878,246.627 222.5,245.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M 511.5,356.5 C 511.833,505.001 511.5,653.334 510.5,801.5C 449.152,768.66 385.152,742.16 318.5,722C 289.639,713.805 260.306,707.972 230.5,704.5C 230.5,555.167 230.5,405.833 230.5,256.5C 279.842,263.335 327.842,275.502 374.5,293C 421.955,310.424 467.621,331.59 511.5,356.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M 841.5,256.5 C 843.833,256.5 846.167,256.5 848.5,256.5C 848.5,405.833 848.5,555.167 848.5,704.5C 791.665,711.959 736.665,726.459 683.5,748C 643.686,763.741 605.019,781.907 567.5,802.5C 566.167,653.833 566.167,505.167 567.5,356.5C 653.202,307.491 744.536,274.157 841.5,256.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M 198.5,282.5 C 205.833,282.5 213.167,282.5 220.5,282.5C 220.333,425.5 220.5,568.5 221,711.5C 221.833,712.333 222.667,713.167 223.5,714C 282.418,721.646 339.418,736.646 394.5,759C 409.615,765.058 424.615,771.391 439.5,778C 399.898,766.098 359.898,755.432 319.5,746C 279.6,737.181 239.267,731.681 198.5,729.5C 198.5,580.5 198.5,431.5 198.5,282.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M 651.5,774.5 C 650.833,774.5 650.5,774.167 650.5,773.5C 715.503,743.444 783.503,723.611 854.5,714C 856.286,713.215 857.786,712.049 859,710.5C 859.5,567.834 859.667,425.167 859.5,282.5C 866.5,282.5 873.5,282.5 880.5,282.5C 880.5,431.5 880.5,580.5 880.5,729.5C 822.172,732.999 764.839,742.499 708.5,758C 689.362,763.034 670.362,768.534 651.5,774.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M 457.5,795.5 C 456.791,796.404 455.791,796.737 454.5,796.5C 359.042,778.184 262.709,767.85 165.5,765.5C 165.5,613.833 165.5,462.167 165.5,310.5C 173.167,310.5 180.833,310.5 188.5,310.5C 188.333,452.5 188.5,594.5 189,736.5C 189.833,737.333 190.667,738.167 191.5,739C 232.603,740.954 273.27,746.287 313.5,755C 362.151,766.161 410.151,779.661 457.5,795.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M 623.5,796.5 C 622.508,796.672 621.842,796.338 621.5,795.5C 709.229,764.769 799.063,744.769 891,735.5C 891.5,593.834 891.667,452.167 891.5,310.5C 899.167,310.5 906.833,310.5 914.5,310.5C 914.5,462.167 914.5,613.833 914.5,765.5C 816.589,767.713 719.589,778.046 623.5,796.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 254.5,323.5 C 315.89,335.352 374.89,354.519 431.5,381C 451.85,390.258 471.683,400.424 491,411.5C 491.989,416.84 489.822,419.34 484.5,419C 411.34,379.332 334.173,350.499 253,332.5C 250.788,329.021 251.288,326.021 254.5,323.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 819.5,323.5 C 827.49,323.086 829.49,326.253 825.5,333C 744.188,350.159 667.188,378.826 594.5,419C 588.531,418.902 586.698,416.068 589,410.5C 661.643,370.123 738.477,341.123 819.5,323.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 511.5,356.5 C 512.833,505.001 512.833,653.667 511.5,802.5C 510.893,802.376 510.56,802.043 510.5,801.5C 511.5,653.334 511.833,505.001 511.5,356.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 555.5,806.5 C 555.5,657.5 555.5,508.5 555.5,359.5C 544.833,359.5 534.167,359.5 523.5,359.5C 523.5,508.5 523.5,657.5 523.5,806.5C 522.5,657.334 522.167,508.001 522.5,358.5C 533.833,358.5 545.167,358.5 556.5,358.5C 556.833,508.001 556.5,657.334 555.5,806.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.background).toHex}" d="M 555.5,806.5 C 544.833,806.5 534.167,806.5 523.5,806.5C 523.5,657.5 523.5,508.5 523.5,359.5C 534.167,359.5 544.833,359.5 555.5,359.5C 555.5,508.5 555.5,657.5 555.5,806.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 254.5,369.5 C 298.377,377.304 341.044,389.47 382.5,406C 418.8,420.213 454.133,436.546 488.5,455C 492.072,457.626 492.405,460.626 489.5,464C 487.5,464.667 485.5,464.667 483.5,464C 411.289,424.596 334.956,396.263 254.5,379C 250.581,375.84 250.581,372.673 254.5,369.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 816.5,369.5 C 819.518,369.335 822.518,369.502 825.5,370C 828.229,373.015 828.063,375.848 825,378.5C 744.294,395.735 667.794,424.235 595.5,464C 590.16,464.989 587.66,462.822 588,457.5C 659.935,417.024 736.101,387.691 816.5,369.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 253.5,415.5 C 272.105,417.9 290.439,421.734 308.5,427C 371.46,445.315 431.793,469.982 489.5,501C 492.999,507.669 490.999,510.669 483.5,510C 411.431,470.199 335.098,441.866 254.5,425C 250.956,422.127 250.623,418.96 253.5,415.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 816.5,415.5 C 819.518,415.335 822.518,415.502 825.5,416C 828.539,419.805 827.872,422.805 823.5,425C 743.292,442.069 667.292,470.402 595.5,510C 590.16,510.989 587.66,508.822 588,503.5C 659.778,462.632 735.945,433.299 816.5,415.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 254.5,460.5 C 315.89,472.352 374.89,491.519 431.5,518C 451.357,527.179 470.857,537.012 490,547.5C 492.569,553.256 490.736,556.089 484.5,556C 411.34,516.332 334.173,487.499 253,469.5C 250.788,466.021 251.288,463.021 254.5,460.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 819.5,460.5 C 827.021,460.39 829.021,463.557 825.5,470C 744.188,487.159 667.188,515.826 594.5,556C 588.531,555.902 586.698,553.068 589,547.5C 661.643,507.123 738.477,478.123 819.5,460.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 254.5,506.5 C 315.89,518.352 374.89,537.519 431.5,564C 451.881,573.273 471.714,583.44 491,594.5C 492.033,599.799 489.866,602.299 484.5,602C 411.721,562.073 334.721,533.406 253.5,516C 250.69,512.432 251.023,509.266 254.5,506.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 816.5,506.5 C 819.518,506.335 822.518,506.502 825.5,507C 828.539,510.805 827.872,513.805 823.5,516C 743.292,533.069 667.292,561.402 595.5,601C 590.16,601.989 587.66,599.822 588,594.5C 659.935,554.024 736.101,524.691 816.5,506.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 253.5,552.5 C 272.105,554.9 290.439,558.734 308.5,564C 372.466,582.239 433.299,607.739 491,640.5C 491.667,646.161 489.167,648.328 483.5,647C 411.431,607.199 335.098,578.866 254.5,562C 250.956,559.127 250.623,555.96 253.5,552.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 820.5,551.5 C 825.813,551.644 827.979,554.31 827,559.5C 745.962,578.183 668.795,607.35 595.5,647C 590.16,647.989 587.66,645.822 588,640.5C 661.056,599.095 738.556,569.428 820.5,551.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 819.5,597.5 C 827.021,597.39 829.021,600.557 825.5,607C 744.188,624.159 667.188,652.826 594.5,693C 588.531,692.902 586.698,690.068 589,684.5C 661.643,644.123 738.477,615.123 819.5,597.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 254.5,597.5 C 337.897,614.617 416.73,643.95 491,685.5C 491.881,691.286 489.381,693.786 483.5,693C 411.067,653.121 334.4,624.455 253.5,607C 250.753,603.553 251.087,600.386 254.5,597.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 254.5,643.5 C 315.89,655.352 374.89,674.519 431.5,701C 451.881,710.273 471.714,720.44 491,731.5C 492.033,736.799 489.866,739.299 484.5,739C 411.721,699.073 334.721,670.406 253.5,653C 250.69,649.432 251.023,646.266 254.5,643.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 819.5,643.5 C 825.496,642.333 827.996,644.666 827,650.5C 826.5,651.667 825.667,652.5 824.5,653C 744.027,670.268 667.693,698.601 595.5,738C 589.498,738.993 587.332,736.493 589,730.5C 661.643,690.123 738.477,661.123 819.5,643.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 650.5,773.5 C 650.5,774.167 650.833,774.5 651.5,774.5C 647.791,776.569 643.791,777.735 639.5,778C 643.188,776.487 646.855,774.987 650.5,773.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 621.5,795.5 C 621.842,796.338 622.508,796.672 623.5,796.5C 619.708,798.034 615.708,798.868 611.5,799C 614.744,797.53 618.077,796.363 621.5,795.5 Z"/></g>
                    <g><path style="opacity:1" fill="${ColorToHex(Theme.of(context).colorScheme.primary).toHex}" d="M 457.5,795.5 C 460.907,796.358 464.24,797.525 467.5,799C 462.946,798.941 458.613,798.108 454.5,796.5C 455.791,796.737 456.791,796.404 457.5,795.5 Z"/></g>
                    </svg>
                    ''')),
                    const Center(
                      child: Text("لا توجد مساعدات مسجلة",
                          style: TextStyle(fontSize: 25, fontFamily: "Amiri")),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                            elevation:
                                const MaterialStatePropertyAll<double>(0),
                            backgroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.primary)),
                        icon: Icon(Icons.add,
                            color: Theme.of(context).colorScheme.onPrimary),
                        label: Text("إنشاء مساعدة",
                            style: TextStyle(
                                fontSize: 25,
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                        // onPressed: () => Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => RegisterPage()))
                        onPressed: () async {
                          Future<bool?> newRecord = showDialog<bool>(
                              context: context,
                              builder: (context) => RegisterPage());
                          newRecord.then((value) {
                            if (value == true) {
                              setState(() {});
                            }
                          });
                        }
                        // Navigator.push(
                        //     context,
                        //     PageTransition(
                        //         duration: const Duration(milliseconds: 300),
                        //         curve: Curves.bounceInOut,
                        //         child: RegisterPage(),
                        //         type: PageTransitionType.bottomToTop))
                        ,
                      ),
                    )
                  ],
                ),
              );
            }
          }),
          floatingActionButton: box.isEmpty
              ? Container()
              : FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: RegisterPage(),
                            type: PageTransitionType.bottomToTop,
                            duration: const Duration(milliseconds: 300))
                        // MaterialPageRoute(builder: (context) => RegisterPage())
                        );
                  }),
        ));
  }

  Future<void> appearancePage(BuildContext context,
      TheThemeProvider themeChange, ThemeColorProvider colorChangeProvider) {
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

                  // TODO: "Export Data" Button
                  const SizedBox(height: 10),
                  ExpansionTile(
                      title: const Text("اعدادات متقدمة",
                          style: TextStyle(fontFamily: "ibmPlexSansArabic")),
                      childrenPadding: const EdgeInsets.all(10),
                      children: [
                        const SizedBox(height: 20),
                        OutlinedButton(
                            onPressed: () {},
                            child: const Text("استخراج البيانات")),
                        const SizedBox(height: 20),
                      ]),
                ],
              )),
            ),
          );
        });
  }

  Future<dynamic> deleteDialog(BuildContext context, Person? person,
      Box<Person> box, int i, SelectedIdProvider selectedIdProvider) {
    return showDialog(
        context: context,
        builder: (context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                icon: const Icon(Icons.delete_forever_outlined),
                title: Text("حذف ${person!.name}؟"),
                content: const Text("هل انت متأكد انك تريد حذف هذا الشخص ؟"),
                actions: [
                  TextButton(
                      child: const Text("إلغاء"),
                      onPressed: () => Navigator.pop(context)),
                  TextButton(
                      child: const Text("نعم"),
                      onPressed: () {
                        box.values.isNotEmpty
                            ? box.deleteAt(i).then((value) {
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
  'غير محددة',
  'أخرى'
];

// ignore: must_be_immutable
class RegisterPage extends StatefulWidget {
  int? id;
  RegisterPage({super.key, this.id});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String description = '';

  final box = Hive.box<Person>('personList');

  AidDuration? _duration = AidDuration.continuous;

  String? aidType = aidTypes[5];

  List<DateTime> dateRange = [];

  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();

    Person? loadPerson = widget.id != null ? box.getAt(widget.id!) : null;
    loadData(loadPerson);

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  loadData(Person? loadPerson) {
    if (loadPerson != null) {
      List<String> fullName = loadPerson.name.split(" ");
      _firstNameController.text = fullName[0];
      fullName.removeAt(0);
      _lastNameController.text = fullName.join(' ');
      // "${fullName[1]} ${fullName.last != fullName[1] ? fullName.join('') : ''}";
      _phoneController.text = loadPerson.phoneNumber.toString();
      _idNumberController.text = loadPerson.idNumber.toString();
      _amountController.text = loadPerson.aidAmount.toString();
      dateRange = loadPerson.aidDates;
      if (aidTypes.contains(loadPerson.aidType)) {
        aidType = loadPerson.aidType;
        debugPrint(aidTypes.contains(loadPerson.aidType).toString());
      } else {
        aidType = aidTypes.last;
        _typeController.text = loadPerson.aidType;
      }
      _duration = loadPerson.isContinuousAid
          ? AidDuration.continuous
          : AidDuration.interrupted;
      _notesController.text = loadPerson.notes;
      description = _notesController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    Person? loadPerson = widget.id != null ? box.getAt(widget.id!) : null;

    if (widget.id != null && loadPerson!.isInBox) {
      return scaffoldRegisterPage(context, id: widget.id);
    } else {
      return scaffoldRegisterPage(context);
    }
  }

  Widget clearButton(TextEditingController controller) {
    return IconButton(
        icon: const Icon(Icons.clear), onPressed: () => controller.text = '');
  }

  Directionality scaffoldRegisterPage(BuildContext context, {int? id}) {
    bool savedPersonId = id != null;
    Person? loadPerson = savedPersonId ? box.getAt(id) : null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // large screen
            return Scaffold(
              appBar: AppBar(
                  title: Text(
                      savedPersonId ? "تعديل المساعدة" : "إنشاء مساعدة جديدة"),
                  centerTitle: true,
                  actions: [
                    IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          if (savedPersonId) {
                            // don't save empty fields by default

                            box.putAt(
                                id,
                                Person(
                                    name:
                                        "${_firstNameController.text} ${_lastNameController.text}",
                                    idNumber: _idNumberController.text,
                                    phoneNumber:
                                        _phoneController.text.isNotEmpty
                                            ? int.parse(_phoneController.text)
                                            : 0,
                                    aidDates: dateRange,
                                    aidType: aidType == aidTypes.last
                                        ? _typeController.text
                                        : aidType ?? aidTypes.last,
                                    aidAmount: _amountController.text.isNotEmpty
                                        ? int.parse(_amountController.text)
                                        : 0,
                                    isContinuousAid:
                                        _duration == AidDuration.continuous
                                            ? true
                                            : false,
                                    notes: _notesController.text));
                            debugPrint(
                                "${loadPerson!.name} is now ${_firstNameController.text}");
                          } else {
                            box.add(Person(
                                name:
                                    "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
                                idNumber: _idNumberController.text.trim(),
                                phoneNumber: _phoneController.text
                                        .trim()
                                        .isNotEmpty
                                    ? int.parse(_phoneController.text.trim())
                                    : 0,
                                aidDates: dateRange,
                                aidType: aidType == aidTypes.last
                                    ? _typeController.text.trim()
                                    : (aidType ?? aidTypes[5]),
                                aidAmount: _amountController.text
                                        .trim()
                                        .isNotEmpty
                                    ? int.parse(_amountController.text.trim())
                                    : 0,
                                isContinuousAid:
                                    _duration == AidDuration.continuous
                                        ? true
                                        : false,
                                notes: _notesController.text));
                          }
                          // Navigator.pushReplacement(
                          //     context,
                          //     PageTransition(
                          //         child: const MyHomePage(),
                          //         type: PageTransitionType.topToBottom,
                          //         duration: const Duration(milliseconds: 300)));
                          // Navigator.popAndPushNamed(context, '/');
                          // Navigator.pushReplacementNamed(context, '/');
                          Navigator.pop(context, true);
                          // setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: const Duration(milliseconds: 1000),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              content: Text(
                                  'تم حفظ "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}" بنجاح',
                                  style: const TextStyle(fontSize: 15))));
                        }),
                  ]),
              body: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  Expanded(
                      flex: 3,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: ListView(
                          children: [
                            Card(
                                child: ListTile(
                              leading: const Icon(Icons.perm_identity_outlined),
                              title: Text(
                                  "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
                                  softWrap: true),
                              subtitle: const Text("الإسم كامل"),
                              onLongPress: () async {
                                if ("${_firstNameController.text.trim()} ${_lastNameController.text.trim()}"
                                    .isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          content: const Text(
                                              "لا توجد بيانات للنسخ",
                                              style: TextStyle(fontSize: 15))));
                                } else {
                                  await Clipboard.setData(ClipboardData(
                                          text:
                                              "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}"))
                                      .then((value) =>
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration: const Duration(
                                                      milliseconds: 1000),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  content: const Text(
                                                      "تم نسخ الإسم الكامل",
                                                      style: TextStyle(
                                                          fontSize: 15)))));
                                }
                              },
                            )),
                            Card(
                                child: ListTile(
                              onLongPress: () async {
                                if (_phoneController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          content: const Text(
                                              "لا توجد بيانات للنسخ",
                                              style: TextStyle(fontSize: 15))));
                                } else {
                                  await Clipboard.setData(ClipboardData(
                                          text: _phoneController.text))
                                      .then((value) =>
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration:
                                                      const Duration(
                                                          milliseconds: 1000),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  content: const Text(
                                                      "تم نسخ رقم الهاتف",
                                                      style: TextStyle(
                                                          fontSize: 15)))));
                                }
                              },
                              leading: const Icon(Icons.phone_outlined),
                              trailing: const Icon(Icons.message_outlined),
                              title: Text(_phoneController.text.isEmpty
                                  ? "لا يوجد"
                                  : _phoneController.text),
                              subtitle: const Text("رقم الهاتف"),
                            )),
                            Card(
                                child: ListTile(
                              leading: const Icon(Icons.badge_outlined),
                              title: Text(_idNumberController.text.isEmpty
                                  ? "لا يوجد"
                                  : _idNumberController.text),
                              subtitle: const Text("رقم الهوية"),
                              onLongPress: () async {
                                if (_idNumberController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          content: const Text(
                                              "لا توجد بيانات للنسخ",
                                              style: TextStyle(fontSize: 15))));
                                } else {
                                  await Clipboard.setData(ClipboardData(
                                          text: _idNumberController.text))
                                      .then((value) =>
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  SnackBar(
                                                      duration: const Duration(
                                                          milliseconds: 1000),
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                      content: const Text(
                                                          "تم نسخ رقم الهوية",
                                                          style: TextStyle(
                                                              fontSize: 15)))));
                                }
                              },
                            )),
                            Card(
                                child: ListTile(
                              leading: const Icon(Icons.request_quote_outlined),
                              title: Text(aidType ?? 'لا يوجد'),
                              subtitle: const Text("نوع المساعدة"),
                              onLongPress: () async {
                                if (aidType != null || aidType!.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          content: const Text(
                                              "لا توجد بيانات للنسخ",
                                              style: TextStyle(fontSize: 15))));
                                } else {
                                  await Clipboard.setData(
                                          ClipboardData(text: aidType!))
                                      .then((value) => ScaffoldMessenger
                                              .of(context)
                                          .showSnackBar(SnackBar(
                                              duration: const Duration(
                                                  milliseconds: 1000),
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              content: const Text(
                                                  "تم نسخ نوع المساعدة",
                                                  style: TextStyle(
                                                      fontSize: 15)))));
                                }
                              },
                            )),
                            Card(
                                child: ListTile(
                              leading: const Icon(Icons.attach_money_outlined),
                              title: Text("${_amountController.text} ريال"),
                              subtitle: const Text("مقدار المساعدة"),
                              onLongPress: () async {
                                await Clipboard.setData(ClipboardData(
                                        text: _amountController.text))
                                    .then((value) => ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(SnackBar(
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            content: const Text(
                                                "تم نسخ مقدار المساعدة",
                                                style:
                                                    TextStyle(fontSize: 15)))));
                              },
                            )),
                            Card(
                                child: ListTile(
                              leading: const Icon(Icons.update_outlined),
                              title: Text(_duration == AidDuration.continuous
                                  ? "مستمرة"
                                  : "منقطعة"),
                              subtitle: const Text("مدة المساعدة"),
                              onLongPress: () async {
                                await Clipboard.setData(ClipboardData(
                                        text:
                                            _duration == AidDuration.continuous
                                                ? 'مستمرة'
                                                : 'منقطعة'))
                                    .then((value) => ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            content: const Text(
                                                "تم نسخ مدة المساعدة",
                                                style:
                                                    TextStyle(fontSize: 15)))));
                              },
                            )),
                            Card(
                                child: ListTile(
                              subtitle: const Text("الملاحظات"),
                              trailing: IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(
                                            text: _notesController.text))
                                        .then(
                                            (value) => ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    duration: const Duration(
                                                        milliseconds: 1000),
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                    content: const Text(
                                                        "تم نسخ الملاحظات",
                                                        style: TextStyle(
                                                            fontSize: 15)))));
                                  }),
                              title: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MarkdownBody(
                                  shrinkWrap: false,
                                  softLineBreak: true,
                                  selectable: true,
                                  data: _notesController.text,
                                  extensionSet: md.ExtensionSet(
                                    md.ExtensionSet.gitHubFlavored
                                        .blockSyntaxes,
                                    <md.InlineSyntax>[
                                      md.EmojiSyntax(),
                                      ...md.ExtensionSet.gitHubFlavored
                                          .inlineSyntaxes
                                    ],
                                  ),
                                ),
                              ),
                            )),
                            Card(
                              child: ListTile(
                                onTap: () {
                                  //share
                                },
                                title: const Text("مشاركة هذه المساعدة"),
                                subtitle: const Text("مشاركة"),
                                leading: const Icon(Icons.share_outlined),
                              ),
                            )
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 5,
                    child: registerationForm(context, loadPerson),
                  ),
                ]),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
                title: Text(
                    savedPersonId ? "تعديل المساعدة" : "إنشاء مساعدة جديدة"),
                centerTitle: true,
                actions: [
                  IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        if (savedPersonId) {
                          // don't save empty fields by default

                          box.putAt(
                              id,
                              Person(
                                  name:
                                      "${_firstNameController.text} ${_lastNameController.text}",
                                  idNumber: _idNumberController.text,
                                  phoneNumber: _phoneController.text.isNotEmpty
                                      ? int.parse(_phoneController.text)
                                      : 0,
                                  aidDates: dateRange,
                                  aidType: aidType == aidTypes.last
                                      ? _typeController.text
                                      : aidType ?? aidTypes.last,
                                  aidAmount: _amountController.text.isNotEmpty
                                      ? int.parse(_amountController.text)
                                      : 0,
                                  isContinuousAid:
                                      _duration == AidDuration.continuous
                                          ? true
                                          : false,
                                  notes: _notesController.text));
                          debugPrint(
                              "${loadPerson!.name} is now ${_firstNameController.text}");
                        } else {
                          box.add(Person(
                              name:
                                  "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
                              idNumber: _idNumberController.text.trim(),
                              phoneNumber:
                                  _phoneController.text.trim().isNotEmpty
                                      ? int.parse(_phoneController.text.trim())
                                      : 0,
                              aidDates: dateRange,
                              aidType: aidType == aidTypes.last
                                  ? _typeController.text.trim()
                                  : (aidType ?? aidTypes[5]),
                              aidAmount:
                                  _amountController.text.trim().isNotEmpty
                                      ? int.parse(_amountController.text.trim())
                                      : 0,
                              isContinuousAid:
                                  _duration == AidDuration.continuous
                                      ? true
                                      : false,
                              notes: _notesController.text));
                        }
                        // Navigator.pop(context);
                        // Navigator.pushReplacementNamed(context, '/');
                        // Navigator.pushReplacement(
                        //     context,
                        //     PageTransition(
                        //         child: const MyHomePage(),
                        //         type: PageTransitionType.topToBottom,
                        //         duration: const Duration(milliseconds: 300)));
                        // Navigator.pushReplacementNamed(context, '/');
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(milliseconds: 1000),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            content: Text(
                                'تم حفظ "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}" بنجاح',
                                style: const TextStyle(fontSize: 15))));
                      })
                ]),
            body: registerationForm(context, loadPerson),
          );
        },
      ),
    );
  }

  Form registerationForm(BuildContext context, Person? loadPerson) {
    return Form(
      canPop: true,
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 15),
            TextFormField(
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                  suffixIcon: clearButton(_firstNameController),
                  label: const Text("الأسم الأول"),
                  border: const OutlineInputBorder(),
                  isDense: true),
              controller: _firstNameController,
              onChanged: (value) => setState(() {}),
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 5),
            TextFormField(
              decoration: InputDecoration(
                  suffixIcon: clearButton(_lastNameController),
                  label: const Text("الأسم الأخير"),
                  border: const OutlineInputBorder(),
                  isDense: true),
              controller: _lastNameController,
              onChanged: (value) => setState(() {}),
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                  suffixIcon: clearButton(_idNumberController),
                  label: const Text("رقم الهوية"),
                  border: const OutlineInputBorder(),
                  isDense: true),
              controller: _idNumberController,
              onChanged: (value) => setState(() {}),
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                  suffixIcon: clearButton(_phoneController),
                  label: const Text("رقم الهاتف"),
                  border: const OutlineInputBorder(),
                  isDense: true),
              controller: _phoneController,
              onChanged: (value) => setState(() {}),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 10,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            const Center(
                child: Text("تاريخ المساعدة",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            dateRange.isEmpty
                ? Container()
                : Center(
                    child: SizedBox(
                    width: 350,
                    child: Table(
                      textDirection: TextDirection.rtl,
                      children: [
                        TableRow(children: [
                          const Text("الميلادي"),
                          Text(
                              "${intl.DateFormat('yyyy/MM/dd').format(dateRange[0])} - ${intl.DateFormat('yyyy/MM/dd').format(dateRange[1])}")
                        ]),
                        TableRow(children: [
                          const Text("الهجري"),
                          Text(
                              "${HijriDateTime.fromDateTime(dateRange[0]).toString().replaceAll('-', '/')} - ${HijriDateTime.fromDateTime(dateRange[1]).toString().replaceAll('-', '/')}")
                        ]),
                      ],
                    ),
                  )),
            const SizedBox(height: 10),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text("تاريخ (ميلادي)"),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: SfDateRangePicker(
                                      initialSelectedRange: dateRange.isNotEmpty
                                          ? PickerDateRange(
                                              dateRange[0], dateRange[1])
                                          : null,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      startRangeSelectionColor:
                                          Theme.of(context).colorScheme.primary,
                                      endRangeSelectionColor:
                                          Theme.of(context).colorScheme.primary,
                                      rangeSelectionColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          .withOpacity(0.4),
                                      selectionMode:
                                          DateRangePickerSelectionMode.range,
                                      confirmText: "تأكيد",
                                      cancelText: "إلغاء",
                                      onCancel: () {
                                        Navigator.pop(context);
                                      },
                                      onSubmit: (Object? value) {
                                        if (value is PickerDateRange) {
                                          dateRange.clear();
                                          dateRange.add(value.startDate!);
                                          dateRange.add(value.endDate!);
                                          setState(() {});

                                          debugPrint(
                                              "Saved DateRange is ${dateRange[0]} - ${dateRange[1]} and it's a ${dateRange[1].difference(dateRange[0]).inDays} days journey");
                                          debugPrint(
                                              "Saved DateRange is ${HijriDateTime.fromDateTime(dateRange[0])} - ${HijriDateTime.fromDateTime(dateRange[1])}");
                                          Navigator.pop(context);
                                        }
                                      },
                                      showActionButtons: true),
                                ));
                      }),
                  // const SizedBox(width: 10),
                  OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text("تاريخ (هجري)"),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: SfHijriDateRangePicker(
                                      initialSelectedRange: dateRange.isNotEmpty
                                          ? HijriDateRange(
                                              HijriDateTime.fromDateTime(
                                                  dateRange[0]),
                                              HijriDateTime.fromDateTime(
                                                  dateRange[1]))
                                          : null,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      startRangeSelectionColor:
                                          Theme.of(context).colorScheme.primary,
                                      endRangeSelectionColor:
                                          Theme.of(context).colorScheme.primary,
                                      rangeSelectionColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      selectionMode:
                                          DateRangePickerSelectionMode.range,
                                      confirmText: "تأكيد",
                                      cancelText: "إلغاء",
                                      onCancel: () {
                                        Navigator.pop(context);
                                      },
                                      onSubmit: (Object? value) {
                                        if (value is HijriDateRange) {
                                          dateRange.clear();
                                          dateRange.add(
                                              value.startDate!.toDateTime());
                                          dateRange
                                              .add(value.endDate!.toDateTime());
                                          setState(() {});

                                          debugPrint(
                                              "Saved DateRange is ${dateRange[0]} - ${dateRange[1]} and it's a ${dateRange[1].difference(dateRange[0]).inDays} days journey");
                                          debugPrint(
                                              "Saved DateRange is ${HijriDateTime.fromDateTime(dateRange[0])} - ${HijriDateTime.fromDateTime(dateRange[1])}");
                                          Navigator.pop(context);
                                        }
                                      },
                                      showActionButtons: true),
                                ));
                      }),
                ]),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: (aidTypes.contains(loadPerson?.aidType) ||
                      aidTypes.contains(aidType))
                  ? aidType
                  : aidTypes.last,
              decoration: const InputDecoration(
                label: Text("نوع المساعدة"),
                border: OutlineInputBorder(),
              ),
              items: aidTypes
                  .map((e) => DropdownMenuItem(
                      value: e,
                      alignment: AlignmentDirectional.center,
                      child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => aidType = value),
              onTap: () => TextInputAction.next,
            ),
            const SizedBox(height: 5),
            Visibility(
              visible: aidType == aidTypes.last,
              child: TextFormField(
                decoration: InputDecoration(
                    suffixIcon: clearButton(_typeController),
                    label: const Text("نوع اخر"),
                    border: const OutlineInputBorder(),
                    isDense: true),
                controller: _typeController,
                onChanged: (value) => setState(() {}),
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              decoration: InputDecoration(
                  suffixIcon: clearButton(_amountController),
                  label: const Text("مقدار المساعدة"),
                  border: const OutlineInputBorder(),
                  isDense: true),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: _amountController,
              onChanged: (value) => setState(() {}),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            const Center(
                child: Text("مدة المساعدة",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            RadioListTile<AidDuration>(
              title: const Text('مستمرة'),
              value: AidDuration.continuous,
              groupValue: _duration,
              onChanged: (AidDuration? value) {
                setState(() {
                  _duration = value;
                });
              },
            ),
            RadioListTile<AidDuration>(
              title: const Text('منقطعة'),
              value: AidDuration.interrupted,
              groupValue: _duration,
              onChanged: (AidDuration? value) {
                setState(() {
                  _duration = value;
                });
              },
            ),
            const SizedBox(height: 10),
            MarkdownTextInput(
              (String value) {
                if (description != value) {
                  setState(() => description = value);
                }
              },
              description,
              label: 'الملاحظات',
              textDirection: TextDirection.rtl,
              maxLines: null,
              actions: const [
                MarkdownType.bold,
                MarkdownType.italic,
                MarkdownType.list,
                MarkdownType.blockquote,
                MarkdownType.title,
                MarkdownType.strikethrough,
                MarkdownType.separator
              ],
              controller: _notesController,
              textStyle: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final int? id;
  const DetailsPage({super.key, this.id});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final box = Hive.box<Person>('personList');
  bool isLargeScreen = false;

  String dateRangeView = '';
  String hijriDateRangeView = '';
  bool isDateHijri = false;

  @override
  Widget build(BuildContext context) {
    final selectedIdProvider = Provider.of<SelectedIdProvider>(context);
    Person? person = (selectedIdProvider.selectedId != -1 ||
            widget.id! >= 0 && box.get(widget.id!)!.isInBox)
        ? box.getAt(widget.id!)
        : null;
    if (person != null) {
      if (person.aidDates.length >= 2) {
        dateRangeView =
            "${intl.DateFormat('yyyy/MM/dd').format(person.aidDates[0])} - ${intl.DateFormat('yyyy/MM/dd').format(person.aidDates[1])}";
        hijriDateRangeView =
            "${HijriDateTime.fromDateTime(person.aidDates[0]).toString().replaceAll('-', '/')} - ${HijriDateTime.fromDateTime(person.aidDates[1]).toString().replaceAll('-', '/')}";
      } else {
        dateRangeView = "لا يوجد";
        hijriDateRangeView = "لا يوجد";
      }
    }

    if (MediaQuery.of(context).size.width > 600) {
      isLargeScreen = true;
    } else {
      isLargeScreen = false;
    }
    return Directionality(
        textDirection: TextDirection.rtl,
        child: !(box.values.isNotEmpty && person != null)
            ? const NoSelectedRecord()
            : Scaffold(
                body: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar.large(
                      leading: isLargeScreen
                          ? IconButton(
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_outlined),
                              onPressed: () {
                                setState(() {
                                  selectedIdProvider.selectedId = -1;
                                });
                                Navigator.pushReplacementNamed(context, '/');
                              })
                          : const BackButton(),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: AlertDialog(
                                        icon: const Icon(
                                            Icons.delete_forever_outlined),
                                        title: Text("حذف ${person.name}؟"),
                                        content: const Text(
                                            "هل انت متأكد انك تريد حذف هذا الشخص؟"),
                                        actions: [
                                          TextButton(
                                              child: const Text("إلغاء"),
                                              onPressed: () =>
                                                  Navigator.pop(context)),
                                          TextButton(
                                              child: const Text("نعم"),
                                              onPressed: () async {
                                                if (box.values.isNotEmpty) {
                                                  box
                                                      .deleteAt(widget.id!)
                                                      .then((value) {
                                                    // selectedIdProvider
                                                    //     .selectedId = -1;

                                                    setState(() {
                                                      selectedIdProvider
                                                          .selectedId = -1;
                                                    });

                                                    if (isLargeScreen) {
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    } else {
                                                      setState(() {});

                                                      Navigator.pop(context);
                                                      Navigator.pushReplacementNamed(
                                                              context, '/')
                                                          .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1000),
                                                              backgroundColor:
                                                                  Theme.of(context)
                                                                      .colorScheme
                                                                      .primary,
                                                              content: Text(
                                                                  "تم حذف ${person.name} بنجاح",
                                                                  style: const TextStyle(
                                                                      fontSize: 15)))));
                                                    }
                                                  });
                                                } else {
                                                  Navigator.pop(context);
                                                }
                                              })
                                        ],
                                      ),
                                    ));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) =>
                                    RegisterPage(id: widget.id));
                          },
                        ),
                        IconButton(
                            icon: const Icon(Icons.share_outlined),
                            onPressed: () {
                              // Share.share("""
                              //    ${person.name.isNotEmpty ? 'الأسم : ${person.name}' : ''}\n
                              //    ${person.idNumber.isNotEmpty ? 'رقم الهوية : ${person.idNumber}' : ''}\n
                              //    ${person.phoneNumber != 0 ? 'رقم الجوال : ${person.phoneNumber}' : ''}\n
                              //    ${person.aidDates.isNotEmpty ? 'تاريخ المساعدة : ${isDateHijri ? hijriDateRangeView : dateRangeView}' : ''}\n
                              //    ${person.aidType.isNotEmpty ? 'نوع المساعدة : ${person.aidType}' : ''}\n
                              //    ${person.aidAmount != 0 ? 'مقدار المساعدة : ${person.aidAmount} ريال' : ''}\n
                              //    مدة المساعدة : ${person.isContinuousAid ? 'مستمرة' : 'منقطعة'}\n
                              //    الملاحظات: ${person.notes}\n

                              // """);
                            })
                      ],
                      pinned: true,
                      snap: true,
                      floating: true,
                      expandedHeight: 160.0,
                      title: Text(
                          person.name.split(' ').length > 3
                              ? "${person.name.split(' ')[0]} ${person.name.split(' ')[1]} ${person.name.split(' ').last}"
                              : person.name,
                          softWrap: true,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.perm_identity_outlined),
                            title: Text(person.name, softWrap: true),
                            subtitle: const Text("الإسم كامل"),
                            onLongPress: () async {
                              if (person.name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        content: const Text(
                                            "لا توجد بيانات للنسخ",
                                            style: TextStyle(fontSize: 15))));
                              } else {
                                await Clipboard.setData(
                                        ClipboardData(text: person.name))
                                    .then((value) => ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(SnackBar(
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            content: const Text(
                                                "تم نسخ الإسم الكامل",
                                                style:
                                                    TextStyle(fontSize: 15)))));
                              }
                            },
                          )),
                          Card(
                              child: ListTile(
                            onLongPress: () async {
                              if (person.phoneNumber == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        content: const Text(
                                            "لا توجد بيانات للنسخ",
                                            style: TextStyle(fontSize: 15))));
                              } else {
                                await Clipboard.setData(ClipboardData(
                                        text: person.phoneNumber.toString()))
                                    .then((value) => ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(SnackBar(
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            content: const Text(
                                                "تم نسخ رقم الهاتف",
                                                style:
                                                    TextStyle(fontSize: 15)))));
                              }
                            },
                            leading: const Icon(Icons.phone_outlined),
                            trailing: const Icon(Icons.message_outlined),
                            title: Text(person.phoneNumber == 0
                                ? "لا يوجد"
                                : "${person.phoneNumber}"),
                            subtitle: const Text("رقم الهاتف"),
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.badge_outlined),
                            title: Text(person.idNumber == "0" ||
                                    person.idNumber.isEmpty
                                ? "لا يوجد"
                                : person.idNumber),
                            subtitle: const Text("رقم الهوية"),
                            onLongPress: () async {
                              if (person.idNumber.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        content: const Text(
                                            "لا توجد بيانات للنسخ",
                                            style: TextStyle(fontSize: 15))));
                              } else {
                                await Clipboard.setData(
                                        ClipboardData(text: person.idNumber))
                                    .then((value) =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                duration: const Duration(
                                                    milliseconds: 1000),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                content: const Text(
                                                    "تم نسخ رقم الهوية",
                                                    style: TextStyle(
                                                        fontSize: 15)))));
                              }
                            },
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.date_range_outlined),
                            title: Text(isDateHijri
                                ? hijriDateRangeView
                                : dateRangeView),
                            onTap: () {
                              setState(() {
                                if (dateRangeView != "لا يوجد") {
                                  setState(() {
                                    isDateHijri = !isDateHijri;
                                  });
                                }
                              });
                            },
                            subtitle: const Text("تاريخ المساعدة"),
                            onLongPress: () async {
                              if (isDateHijri
                                  ? hijriDateRangeView.isEmpty
                                  : dateRangeView.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        content: const Text(
                                            "لا توجد بيانات للنسخ",
                                            style: TextStyle(fontSize: 15))));
                              } else {
                                await Clipboard.setData(ClipboardData(
                                        text: isDateHijri
                                            ? hijriDateRangeView
                                            : dateRangeView))
                                    .then((value) => ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            content: Text(
                                                "تم نسخ تاريخ المساعدة (${isDateHijri ? 'الهجري' : 'الميلادي'})",
                                                style: const TextStyle(
                                                    fontSize: 15)))));
                              }
                            },
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.request_quote_outlined),
                            title: Text(person.aidType.isEmpty
                                ? 'لا يوجد'
                                : person.aidType),
                            subtitle: const Text("نوع المساعدة"),
                            onLongPress: () async {
                              if (person.aidType.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        content: const Text(
                                            "لا توجد بيانات للنسخ",
                                            style: TextStyle(fontSize: 15))));
                              } else {
                                await Clipboard.setData(
                                        ClipboardData(text: person.aidType))
                                    .then((value) =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                duration: const Duration(
                                                    milliseconds: 1000),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                content: const Text(
                                                    "تم نسخ نوع المساعدة",
                                                    style: TextStyle(
                                                        fontSize: 15)))));
                              }
                            },
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.attach_money_outlined),
                            title: Text("${person.aidAmount} ريال"),
                            subtitle: const Text("مقدار المساعدة"),
                            onLongPress: () async {
                              await Clipboard.setData(ClipboardData(
                                      text: person.aidAmount.toString()))
                                  .then((value) => ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          content: const Text(
                                              "تم نسخ مقدار المساعدة",
                                              style:
                                                  TextStyle(fontSize: 15)))));
                            },
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.update_outlined),
                            title: Text(
                                person.isContinuousAid ? "مستمرة" : "منقطعة"),
                            subtitle: const Text("مدة المساعدة"),
                            onLongPress: () async {
                              await Clipboard.setData(ClipboardData(
                                      text: person.isContinuousAid
                                          ? 'مستمرة'
                                          : 'منقطعة'))
                                  .then((value) => ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          content: const Text(
                                              "تم نسخ مدة المساعدة",
                                              style:
                                                  TextStyle(fontSize: 15)))));
                            },
                          )),
                          Card(
                              child: ListTile(
                            subtitle: const Text("الملاحظات"),
                            trailing: IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () async {
                                  await Clipboard.setData(
                                          ClipboardData(text: person.notes))
                                      .then((value) =>
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration:
                                                      const Duration(
                                                          milliseconds: 1000),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  content: const Text(
                                                      "تم نسخ الملاحظات",
                                                      style: TextStyle(
                                                          fontSize: 15)))));
                                }),
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MarkdownBody(
                                shrinkWrap: false,
                                softLineBreak: true,
                                selectable: true,
                                data: person.notes.isEmpty
                                    ? 'لا يوجد'
                                    : person.notes,
                                extensionSet: md.ExtensionSet(
                                  md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                                  <md.InlineSyntax>[
                                    md.EmojiSyntax(),
                                    ...md.ExtensionSet.gitHubFlavored
                                        .inlineSyntaxes
                                  ],
                                ),
                              ),
                            ),
                          )),
                          Card(
                            child: ListTile(
                              onTap: () {
                                //share
                              },
                              title: const Text("مشاركة هذه المساعدة"),
                              subtitle: const Text("مشاركة"),
                              leading: const Icon(Icons.share_outlined),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }
}

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
