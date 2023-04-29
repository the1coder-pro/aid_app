import 'package:aid_app/chart_page.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'person.dart';
import 'search_widget.dart';
import 'themes.dart';
import 'color_schemes.g.dart';

// ignore: non_constant_identifier_names
String VERSION_NUMBER = "0.63";
List<String> colorSchemes = ["Default", "Red", "Yellow", "Blue", "Device"];

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
        return darkMode ? defaultDarkColorScheme : defaultLightColorScheme;
      case "Red":
        return darkMode ? redDarkColorScheme : redLightColorScheme;
      case "Yellow":
        return darkMode ? yellowDarkColorScheme : yellowLightColorScheme;
      case "Blue":
        return darkMode ? blueDarkColorScheme : blueLightColorScheme;
      case "Device":
        return darkMode
            ? (deviceDarkColorTheme ?? defaultDarkColorScheme)
            : (deviceLightColorTheme ?? defaultLightColorScheme);
    }
    return darkMode ? defaultDarkColorScheme : defaultLightColorScheme;
  }

  // convert the colorChangeProvider.colorTheme to Numbers like this => colorSchemes[colorChangeProvider.colorTheme]
  // so it will be more easier and faster than making Ifs/Elses Or Switchs

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
                                    builder: ((context) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Scaffold(
                                            appBar: AppBar(
                                                title: const Text('الطباعة')),
                                            body: const Center(
                                                child:
                                                    Text("صفحة الطباعة هنا")),
                                          ),
                                        ))));
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
                                                Icon(Icons.book),
                                                Icon(Icons.call),
                                                Icon(Icons.cake),
                                                Icon(Icons.ac_unit),
                                                Icon(Icons.phone_android),
                                              ],
                                            ),
                                          ),
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
                      PopupMenuItem<SampleItem>(
                        value: SampleItem.itemOne,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.bar_chart_outlined),
                            Spacer(),
                            Text('الرسم البياني'),
                          ],
                        ),
                      ),
                      PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.print_outlined),
                            Spacer(),
                            Text('الطباعة'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<SampleItem>(
                        value: SampleItem.itemThree,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
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
                                            onPressed: (context) => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    Directionality(
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      child: AlertDialog(
                                                        icon: const Icon(Icons
                                                            .delete_forever_outlined),
                                                        title: const Text(
                                                            "هل انت متأكد ؟"),
                                                        content: Text(
                                                            "هل انت متأكد انك تريد حذف \n'${person!.name}' ؟"),
                                                        actions: [
                                                          TextButton(
                                                              child: const Text(
                                                                  "إلغاء"),
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context)),
                                                          TextButton(
                                                              child: const Text(
                                                                  "نعم"),
                                                              onPressed: () {
                                                                box
                                                                    .deleteAt(i)
                                                                    .then(
                                                                        (value) {
                                                                  // TODO: does it work? if it work then do we need the setState((){}) ?
                                                                  selectedIdProvider
                                                                      .selectedId = -1;
                                                                  setState(
                                                                      () {});

                                                                  Navigator.pop(
                                                                      context);
                                                                });
                                                              })
                                                        ],
                                                      ),
                                                    )),
                                            backgroundColor: themeChange
                                                    .darkTheme
                                                ? redDarkColorScheme.primary
                                                : redLightColorScheme.primary,
                                            foregroundColor: themeChange
                                                    .darkTheme
                                                ? redDarkColorScheme.onPrimary
                                                : redLightColorScheme.onPrimary,
                                            icon: Icons.delete,
                                            label: 'حذف',
                                          ),
                                          SlidableAction(
                                            onPressed: (context) => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    RegisterPage(id: i)),
                                            backgroundColor: themeChange
                                                    .darkTheme
                                                ? blueDarkColorScheme.primary
                                                : blueLightColorScheme.primary,
                                            foregroundColor: themeChange
                                                    .darkTheme
                                                ? blueDarkColorScheme.onPrimary
                                                : blueLightColorScheme
                                                    .onPrimary,
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
                                          person.name,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        subtitle: RichText(
                                            text: TextSpan(
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                                children: [
                                              TextSpan(
                                                  text:
                                                      "${person.phoneNumber}\n",
                                                  style: const TextStyle(
                                                      fontSize: 15)),
                                              TextSpan(
                                                  text:
                                                      "${person.aidAmount} ريال",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const TextSpan(text: " لأجل "),
                                              TextSpan(
                                                  text: person.aidType,
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
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                              builder: (context) {
                                                return DetailsPage(id: i);
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
                      (isLargeScreen &&
                              (box.length > selectedIdProvider.selectedId &&
                                      selectedIdProvider.selectedId != -1
                                  ? true
                                  : false) &&
                              box.getAt(selectedIdProvider.selectedId)!.isInBox)
                          // i || selectedId || person.key
                          ? Expanded(
                              flex: 2,
                              child: DetailsPage(
                                  id: selectedIdProvider.selectedId))
                          : Container(),
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
            label: const Text("إنشاء مساعدة", style: TextStyle(fontSize: 20)),
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
      _lastNameController.text =
          "${fullName[1]} ${fullName.last != fullName[1] ? fullName.last : ''}";
      _phoneController.text = loadPerson.phoneNumber.toString();
      _idNumberController.text = loadPerson.idNumber.toString();
      _amountController.text = loadPerson.aidAmount.toString();
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
                              aidDates: [],
                              aidType: aidType == aidTypes.last
                                  ? _typeController.text
                                  : aidType ??
                                      aidTypes
                                          .last, // Always Shows "غير محددة" fix this...
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
                          aidDates: [],
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
                const SizedBox(height: 10),
                OutlinedButton(
                    child: const Text("تاريخ المساعدة (ميلادي)"),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: SfDateRangePicker(
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
                                      if (value is PickerDateRange) {
                                        final rangeStartDate = value.startDate!;
                                        final rangeEndDate = value.endDate!;
                                        debugPrint(
                                            "Saved DateRange is $rangeStartDate - $rangeEndDate");
                                      } else if (value is DateTime) {
                                        final DateTime selectedDate = value;
                                      } else if (value is List<DateTime>) {
                                        final List<DateTime> selectedDates =
                                            value;
                                      } else if (value
                                          is List<PickerDateRange>) {
                                        final List<PickerDateRange>
                                            selectedRanges = value;
                                      }
                                    },
                                    showActionButtons: true),
                              ));
                    }),
                const SizedBox(height: 10),
                OutlinedButton(
                    child: const Text("تاريخ المساعدة (هجري)"),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: SfHijriDateRangePicker(
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
                                        final rangeStartDate = value.startDate!;
                                        final rangeEndDate = value.endDate!;
                                        debugPrint(
                                            "Saved Hijri DateRange is $rangeStartDate - $rangeEndDate");
                                      } else if (value is DateTime) {
                                        final DateTime selectedDate = value;
                                      } else if (value is List<DateTime>) {
                                        final List<DateTime> selectedDates =
                                            value;
                                      } else if (value
                                          is List<PickerDateRange>) {
                                        final List<PickerDateRange>
                                            selectedRanges = value;
                                      }
                                    },
                                    showActionButtons: true),
                              ));
                    }),
                const SizedBox(height: 10),
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
                if (!(aidTypes.contains(loadPerson?.aidType)) &&
                    aidType == aidTypes.last)
                  TextFormField(
                    decoration: InputDecoration(
                        suffixIcon: clearButton(_typeController),
                        label: const Text("نوع اخر"),
                        border: const OutlineInputBorder(),
                        isDense: true),
                    controller: _typeController,
                    textInputAction: TextInputAction.next,
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text("مدة المساعدة")),
                ),
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
  final int id;
  const DetailsPage({super.key, required this.id});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final box = Hive.box<Person>('personList');
  bool isLargeScreen = false;

  @override
  Widget build(BuildContext context) {
    final selectedIdProvider = Provider.of<SelectedIdProvider>(context);
    Person? person = widget.id >= 0 && box.getAt(widget.id)!.isInBox
        ? box.getAt(widget.id)
        : null;
    if (MediaQuery.of(context).size.width > 600) {
      isLargeScreen = true;
    } else {
      isLargeScreen = false;
    }
    return Directionality(
        textDirection: TextDirection.rtl,
        child: !(person != null)
            ? const NoSelectedRecord()
            : Scaffold(
                body: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar.large(
                      leading: isLargeScreen ? Container() : const BackButton(),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            // TODO: Fix the Deleting Issue (n + 1 maybe...) (fixed)
                            // TODO: Fix the Aid Type Issue when changing it first time it doesn't change but the second time it changes (fixed)
                            showDialog(
                                context: context,
                                builder: (context) => Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: AlertDialog(
                                        icon: const Icon(
                                            Icons.delete_forever_outlined),
                                        title: const Text("هل انت متأكد ؟"),
                                        content: Text(
                                            "هل انت متأكد انك تريد حذف \n'${person.name}' ؟"),
                                        actions: [
                                          TextButton(
                                              child: const Text("إلغاء"),
                                              onPressed: () =>
                                                  Navigator.pop(context)),
                                          TextButton(
                                              child: const Text("نعم"),
                                              onPressed: () {
                                                box
                                                    .deleteAt(widget.id)
                                                    .then((value) {
                                                  // TODO: does it work? if it work then do we need the setState((){}) ?
                                                  selectedIdProvider
                                                      .selectedId = -1;
                                                  if (isLargeScreen) {
                                                    setState(() {});
                                                  } else {
                                                    Navigator.pop(context);
                                                    Navigator
                                                        .pushReplacementNamed(
                                                            context, '/');
                                                  }
                                                });
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
                      title: Text(person.name),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          // Card(
                          //     child: ListTile(
                          //   leading: const Icon(Icons.person_outlined),
                          //   title: Text(person.name),
                          //   subtitle: const Text("الأسم"),
                          // )),

                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.phone_outlined),
                            title: Text("${person.phoneNumber}"),
                            subtitle: const Text("رقم الهاتف"),
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.badge_outlined),
                            title: Text(person.idNumber),
                            subtitle: const Text("رقم الهوية"),
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.date_range_outlined),
                            title: Text(person.aidDates.length >= 2
                                ? "${person.aidDates[0]} - ${person.aidDates[1]}"
                                : "لا يوجد"),
                            subtitle: const Text("تاريخ المساعدة"),
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.request_quote_outlined),
                            title: Text(person.aidType),
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
                            title: Text(person.notes),
                            subtitle: const Text("الملاحظات"),
                          )),
                          //  Card(
                          //     child: ListTile(
                          //   title: Text(widget.person.name),
                          //   subtitle: Text("مشاركة"),
                          // )),
                        ],
                      ),
                    ),
                  ],
                ),

                //  Center(
                //     child: Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: ListView(
                //     children: [
                //       Card(
                //           child: ListTile(
                //         leading: const Icon(Icons.person_outlined),
                //         title: Text(person.name),
                //         subtitle: const Text("الأسم"),
                //       )),

                //       Card(
                //           child: ListTile(
                //         leading: const Icon(Icons.phone_outlined),
                //         title: Text("${person.phoneNumber}"),
                //         subtitle: const Text("رقم الهاتف"),
                //       )),
                //       Card(
                //           child: ListTile(
                //         leading: const Icon(Icons.badge_outlined),
                //         title: Text(person.idNumber),
                //         subtitle: const Text("رقم الهوية"),
                //       )),
                //       Card(
                //           child: ListTile(
                //         leading: const Icon(Icons.date_range_outlined),
                //         title: Text(person.aidDates.length >= 2
                //             ? "${person.aidDates[0]} - ${person.aidDates[1]}"
                //             : "لا يوجد"),
                //         subtitle: const Text("تاريخ المساعدة"),
                //       )),
                //       Card(
                //           child: ListTile(
                //         leading: const Icon(Icons.request_quote_outlined),
                //         title: Text(person.aidType),
                //         subtitle: const Text("نوع المساعدة"),
                //       )),
                //       Card(
                //           child: ListTile(
                //         leading: const Icon(Icons.attach_money_outlined),
                //         title: Text("${person.aidAmount} ريال"),
                //         subtitle: const Text("مقدار المساعدة"),
                //       )),
                //       Card(
                //           child: ListTile(
                //         leading: const Icon(Icons.update_outlined),
                //         title:
                //             Text(person.isContinuousAid ? "مستمرة" : "منقطعة"),
                //         subtitle: const Text("مدة المساعدة"),
                //       )),
                //       Card(
                //           child: ListTile(
                //         leading: const Icon(Icons.description_outlined),
                //         title: Text(person.notes),
                //         subtitle: const Text("الملاحظات"),
                //       )),
                //       //  Card(
                //       //     child: ListTile(
                //       //   title: Text(widget.person.name),
                //       //   subtitle: Text("مشاركة"),
                //       // )),
                //     ],
                //   ),
                // )),
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
