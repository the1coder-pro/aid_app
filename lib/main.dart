import 'package:aid_app/chart_page.dart';
import 'package:aid_app/print_page.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
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
  "Red",
  "Yellow",
  "Green",
  "Grey",
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
        return darkMode ? blueDarkColorScheme : blueLightColorScheme;
      case "Red":
        return darkMode ? redDarkColorScheme : redLightColorScheme;
      case "Yellow":
        return darkMode ? yellowDarkColorScheme : yellowLightColorScheme;
      case "Grey":
        return darkMode ? greyDarkColorScheme : greyLightColorScheme;
      case "Green":
        return darkMode ? greenDarkColorScheme : greenLightColorScheme;
      case "Device":
        return darkMode
            ? (deviceDarkColorTheme ?? blueDarkColorScheme)
            : (deviceLightColorTheme ?? blueLightColorScheme);
    }
    return darkMode ? blueDarkColorScheme : blueLightColorScheme;
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
                      // maybe consider removing the `title` argument from the `MyHomePage` Widget
                      '/': (context) => const MyHomePage(title: 'المساعدات'),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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
  Widget build(BuildContext context) {
    final themeChange = Provider.of<TheThemeProvider>(context);
    final colorChangeProvider = Provider.of<ThemeColorProvider>(context);
    final selectedIdProvider = Provider.of<SelectedIdProvider>(context);
    isSelected = getIsSelected(colorChangeProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.title,
              style: const TextStyle(fontFamily: "ScheherazadeNew"),
              // style: GoogleFonts.ibmPlexSansArabic(),
            ),
            centerTitle: true,
            actions: box.isEmpty
                ? [Container()]
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
                                MaterialPageRoute(
                                    builder: ((context) => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: ChartPage()))));

                            break;
                          // Printing Page
                          case SampleItem.itemTwo:
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => const Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: PrintPage()))));
                            break;

                          // Settings Page
                          case SampleItem.itemThree:
                            showModalBottomSheet<void>(
                                context: context,
                                elevation: 1,
                                builder: (BuildContext context) {
                                  return Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Scaffold(
                                      appBar: AppBar(
                                        leading: IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () =>
                                                Navigator.pop(context)),
                                        title: const Text("الإعدادات"),
                                        centerTitle: true,
                                      ),
                                      body: Center(
                                          child: ListView(
                                        children: [
                                          SwitchListTile(
                                              thumbIcon: MaterialStateProperty
                                                  .resolveWith<Icon?>(
                                                      (Set<MaterialState>
                                                          states) {
                                                if (states.contains(
                                                    MaterialState.selected)) {
                                                  return const Icon(
                                                      Icons.dark_mode);
                                                }
                                                return const Icon(Icons
                                                    .light_mode); // All other states will use the default thumbIcon.
                                              }),
                                              title: const Text(
                                                "الوضع الداكن",
                                                style: TextStyle(
                                                    fontFamily:
                                                        "ibmPlexSansArabic"),
                                              ),
                                              value: themeChange.darkTheme,
                                              onChanged: (bool value) =>
                                                  themeChange.darkTheme =
                                                      value),
                                          // TODO: ADDING ENGLISH SUPPORT
                                          // SwitchListTile(
                                          //     title: const Text(
                                          //       "اللغة الإنقليزية",
                                          //       style: TextStyle(
                                          //           fontFamily:
                                          //               "ibmPlexSansArabic"),
                                          //     ),
                                          //     value: themeChange.darkTheme,
                                          //     onChanged: (bool value) =>
                                          //         themeChange.darkTheme = value),
                                          const SizedBox(height: 10),
                                          Center(
                                            child: ToggleButtons(
                                              isSelected: isSelected,
                                              onPressed: (int index) {
                                                setState(() {
                                                  for (int buttonIndex = 0;
                                                      buttonIndex <
                                                          isSelected.length;
                                                      buttonIndex++) {
                                                    if (buttonIndex == index) {
                                                      isSelected[buttonIndex] =
                                                          true;
                                                      colorChangeProvider
                                                              .colorTheme =
                                                          buttonIndex;
                                                    } else {
                                                      isSelected[buttonIndex] =
                                                          false;
                                                    }
                                                  }
                                                });
                                              },
                                              children: const <Widget>[
                                                Text("ازرق"),
                                                Text("احمر"),
                                                Text("اصفر"),
                                                Text("اخضر"),
                                                Text("اسود"),
                                                Icon(Icons.phone_android),
                                              ],
                                            ),
                                          ),

                                          // TODO: "Export Data" Button

                                          // Padding(
                                          //   padding: const EdgeInsets.all(8.0),
                                          //   child: Center(
                                          //     child: OutlinedButton.icon(
                                          //         icon: const Icon(
                                          //             Icons.save_alt_outlined),
                                          //         label: const Text(
                                          //             "استخراج البيانات"),
                                          //         onPressed: () {}),
                                          //   ),
                                          // ),

                                          const SizedBox(height: 15),
                                          Center(
                                              child: Text(
                                                  "إصدار رقم $VERSION_NUMBER",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall!
                                                      .copyWith(fontSize: 15)))
                                        ],
                                      )),
                                    ),
                                  );
                                });
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
                                                DeleteDialog(context, person,
                                                    box, i, selectedIdProvider),
                                            backgroundColor:
                                                // themeChange.darkTheme
                                                //     ? Theme.of(context)
                                                //         .colorScheme
                                                //         .error
                                                //     :
                                                Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                            foregroundColor:
                                                // themeChange
                                                //         .darkTheme
                                                //     ? redDarkColorScheme.onPrimary
                                                //     :
                                                Theme.of(context)
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
                                            backgroundColor:
                                                // themeChange
                                                //         .darkTheme
                                                //     ? blueDarkColorScheme.primary
                                                //     :
                                                Theme.of(context)
                                                    .colorScheme
                                                    .tertiary,
                                            foregroundColor:
                                                // themeChange
                                                //         .darkTheme
                                                //     ? blueDarkColorScheme.onPrimary
                                                //     :
                                                Theme.of(context)
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
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                              builder: (context) {
                                                return DetailsPage(
                                                    id: selectedIdProvider
                                                        .selectedId);
                                              },
                                            ));
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
              return NoRecordsPage(themeChange: themeChange);
            }
          }),
          floatingActionButton: box.isEmpty
              ? Container()
              : FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        return RegisterPage();
                      }))),
    );
  }

  Future<dynamic> DeleteDialog(BuildContext context, Person? person,
      Box<Person> box, int i, SelectedIdProvider selectedIdProvider) {
    return showDialog(
        context: context,
        builder: (context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                icon: const Icon(Icons.delete_forever_outlined),
                title: const Text("هل انت متأكد ؟"),
                content: RichText(
                  textDirection: TextDirection.rtl,
                  text: TextSpan(children: [
                    const TextSpan(text: "هل انت متأكد انك تريد حذف \n'"),
                    TextSpan(
                        text: person!.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const TextSpan(text: "' ؟")
                  ]),
                ),
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
                              })
                            : Navigator.pop(context);
                      })
                ],
              ),
            ));
  }
}

class NoRecordsPage extends StatelessWidget {
  const NoRecordsPage({
    super.key,
    required this.themeChange,
  });

  final TheThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        SizedBox(
            height: 250,
            width: 250,
            child: SvgPicture.asset(
              'assets/openBook-light.svg',
              semanticsLabel: 'open book',
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary, BlendMode.srcIn),
            )),
        const Text("لا توجد مساعدات مسجلة",
            style: TextStyle(fontSize: 25, fontFamily: "Amiri")),
        const SizedBox(height: 20),
        TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("إنشاء مساعدة",
                style: TextStyle(
                  fontSize: 20,
                )),
            onPressed: () => showDialog(
                context: context,
                builder: (context) {
                  return RegisterPage();
                }))
      ],
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
      child: Scaffold(
        appBar: AppBar(
            title:
                Text(savedPersonId ? "تعديل المساعدة" : "إنشاء مساعدة جديدة"),
            centerTitle: true,
            actions: [
              TextButton(
                  child: Text(savedPersonId ? 'حفظ' : 'إنشاء'),
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
                              "${_firstNameController.text} ${_lastNameController.text}",
                          idNumber: _idNumberController.text,
                          phoneNumber: _phoneController.text.isNotEmpty
                              ? int.parse(_phoneController.text)
                              : 0,
                          aidDates: dateRange,
                          aidType: aidType == aidTypes.last
                              ? _typeController.text
                              : (aidType ?? aidTypes[5]),
                          aidAmount: _amountController.text.isNotEmpty
                              ? int.parse(_amountController.text)
                              : 0,
                          isContinuousAid: _duration == AidDuration.continuous
                              ? true
                              : false,
                          notes: _notesController.text));
                    }
                    // Navigator.pushReplacementNamed(context, '/');
                    Navigator.pushReplacementNamed(context, '/');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'تم حفظ "${_firstNameController.text} ${_lastNameController.text}" بنجاح')),
                    );
                  })
            ],
            leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context))),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                      suffixIcon: clearButton(_firstNameController),
                      label: const Text("الأسم الأول"),
                      border: const OutlineInputBorder(),
                      isDense: true),
                  controller: _firstNameController,
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
                  keyboardType: TextInputType.number,
                  maxLength: 10,
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
                  keyboardType: TextInputType.phone,
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
                                          initialSelectedRange: dateRange
                                                  .isNotEmpty
                                              ? PickerDateRange(
                                                  dateRange[0], dateRange[1])
                                              : null,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          startRangeSelectionColor:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          endRangeSelectionColor:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          rangeSelectionColor: Theme
                                                  .of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          selectionMode:
                                              DateRangePickerSelectionMode
                                                  .range,
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
                                          initialSelectedRange: dateRange
                                                  .isNotEmpty
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
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          endRangeSelectionColor:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          rangeSelectionColor: Theme
                                                  .of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          selectionMode:
                                              DateRangePickerSelectionMode
                                                  .range,
                                          confirmText: "تأكيد",
                                          cancelText: "إلغاء",
                                          onCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onSubmit: (Object? value) {
                                            if (value is HijriDateRange) {
                                              dateRange.clear();
                                              dateRange.add(value.startDate!
                                                  .toDateTime());
                                              dateRange.add(
                                                  value.endDate!.toDateTime());
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
                    // contentPadding:
                    //     EdgeInsets.symmetric(vertical: -40.0, horizontal: 10.0),
                  ),
                  items: aidTypes
                      .map((e) => DropdownMenuItem(
                          value: e,
                          alignment: AlignmentDirectional.centerEnd,
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
                  controller: _amountController,
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
                TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      suffixIcon: clearButton(_notesController),
                      label: const Text("الملاحظات"),
                      border: const OutlineInputBorder(),
                      isDense: true),
                  controller: _notesController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                ),
              ],
            ),
          ),
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
            widget.id! >= 0 && box.getAt(widget.id!)!.isInBox)
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
                                        title: const Text("هل انت متأكد ؟"),
                                        content: RichText(
                                          textDirection: TextDirection.rtl,
                                          text: TextSpan(children: [
                                            const TextSpan(
                                                text:
                                                    "هل انت متأكد انك تريد حذف \n'"),
                                            TextSpan(
                                                text: person!.name,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const TextSpan(text: "' ؟")
                                          ]),
                                        ),
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
                                                      Navigator
                                                          .pushReplacementNamed(
                                                              context, '/');
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
                        )
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
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.phone_outlined),
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
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.request_quote_outlined),
                            title: Text(person.aidType.isEmpty
                                ? 'لا يوجد'
                                : person.aidType),
                            subtitle: const Text("نوع المساعدة"),
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.attach_money_outlined),
                            title: Text("${person.aidAmount} ريال"),
                            subtitle: const Text("مقدار المساعدة"),
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.update_outlined),
                            title: Text(
                                person.isContinuousAid ? "مستمرة" : "منقطعة"),
                            subtitle: const Text("مدة المساعدة"),
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.description_outlined),
                            title: Text(person.notes.isEmpty
                                ? 'لا يوجد'
                                : person.notes),
                            subtitle: const Text("الملاحظات"),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
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
