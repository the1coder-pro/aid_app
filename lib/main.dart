import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'person.dart';
import 'search_widget.dart';
import 'themes.dart';
import 'color_schemes.g.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(PersonAdapter());
  await Hive.openBox<Person>('personList');

  runApp(const MyApp());
}

final colorSchemes = ["Default", "Red", "Yellow", "Device"];

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TheThemeProvider themeChangeProvider = TheThemeProvider();
  ThemeColorProvider colorChangeProvider = ThemeColorProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    getCurrentColorTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  void getCurrentColorTheme() async {
    colorChangeProvider.colorTheme =
        await colorChangeProvider.colorThemePreference.getThemeColor();
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
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<TheThemeProvider>(
        builder: (BuildContext context, value, child) => DynamicColorBuilder(
          builder: (deviceLightColorScheme, deviceDarkColorScheme) =>
              ChangeNotifierProvider(
            create: (_) {
              return colorChangeProvider;
            },
            child: Consumer<ThemeColorProvider>(
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
                  '/': (context) => const MyHomePage(title: 'المساعدات'),
                },
                initialRoute: '/',
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
  int selectedId = -1;

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
    final colorThemeChange = Provider.of<ThemeColorProvider>(context);
    isSelected = getIsSelected(colorThemeChange);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "${widget.title} - $selectedId",
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
                                        child: Scaffold(
                                          appBar: AppBar(
                                              title:
                                                  const Text('الرسم البياني')),
                                          body: const Center(child: Text("hi")),
                                        ),
                                      ))));

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
                                          body: const Center(child: Text("hi")),
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
                                      title: const Text("الإعدادات"),
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
                                                themeChange.darkTheme = value),
                                        SwitchListTile(
                                            title: const Text(
                                              "اللغة الإنقليزية",
                                              style: TextStyle(
                                                  fontFamily:
                                                      "ibmPlexSansArabic"),
                                            ),
                                            value: themeChange.darkTheme,
                                            onChanged: (bool value) =>
                                                themeChange.darkTheme = value),
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
                                                    colorThemeChange
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
                                              Icon(Icons.ac_unit),
                                              Icon(Icons.call),
                                              Icon(Icons.cake),
                                              Icon(Icons.phone_android),
                                            ],
                                          ),
                                        ),
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
                                  return ListTile(
                                    onLongPress: () {
                                      box.deleteAt(i).then((value) {
                                        debugPrint(
                                            "deleted $i - ${box.length} - ${person.key}");
                                        setState(() {});
                                      });
                                    },
                                    leading: CircleAvatar(
                                      child: Text(
                                        (person!.name)
                                            .toString()
                                            .substring(0, 1),
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    title: Text(
                                      person.name,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    subtitle: RichText(
                                        text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                          TextSpan(
                                              text: "${person.phoneNumber}\n",
                                              style: const TextStyle(
                                                  fontSize: 15)),
                                          TextSpan(
                                              text: "${person.aidAmount} ريال",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const TextSpan(text: " لأجل "),
                                          TextSpan(
                                              text: person.aidType,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const TextSpan(text: " لفترة "),
                                          TextSpan(
                                              text: person.isContinuousAid
                                                  ? "مستمرة"
                                                  : "منقطعة",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ])),
                                    isThreeLine: true,
                                    onTap: () {
                                      if (isLargeScreen) {
                                        selectedId = (box.length > i ? i : -1);
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
                                  );
                                });
                          },
                        ),
                      ),
                    ),
                    (isLargeScreen &&
                            (box.length > selectedId && selectedId != -1
                                ? true
                                : false) &&
                            box.getAt(selectedId)!.isInBox)
                        // i || selectedId || person.key
                        ? Expanded(flex: 2, child: DetailsPage(id: selectedId))
                        : Container(),
                  ]),
            );
          } else {
            return NoRecordsPage(themeChange: themeChange);
          }
        }),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => RegisterPage()),
                )),
      ),
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
      children: [
        SizedBox(
            height: 300,
            width: 300,
            child: Image(
                image: AssetImage(themeChange.darkTheme
                    ? 'assets/openBook-dark.png'
                    : 'assets/openBook-light.png'))),
        const Text("لا توجد مساعدات مسجلة",
            style: TextStyle(fontSize: 25, fontFamily: "ScheherazadeNew")),
        const SizedBox(height: 20),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text("إنشاء مساعدة", style: TextStyle(fontSize: 20)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                fullscreenDialog: true, builder: (context) => RegisterPage()),
          ),
        )
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
    Person? loadPerson = savedPersonId ? box.get(id) : null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
            title:
                Text(savedPersonId ? "تعديل المساعدة" : "إنشاء مساعدة جديدة"),
            centerTitle: true,
            actions: [
              IconButton(
                  icon: Icon(savedPersonId ? Icons.edit : Icons.check),
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
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 10),
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
                appBar: AppBar(
                    title: Text("${person.name} - ${widget.id}"),
                    leading: isLargeScreen ? Container() : const BackButton(),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          // TODO: Fix the Deleting Issue (n + 1 maybe...) (fixed)
                          // TODO: Fix the Aid Type Issue when changing it first time it doesn't change but the second time it changes
                          box.deleteAt(widget.id).then((value) {
                            if (isLargeScreen) {
                              setState(() {});
                            } else {
                              Navigator.pop(context);
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RegisterPage(id: person.key)));
                        },
                      )
                    ]),
                body: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      Card(
                          child: ListTile(
                        leading: const Icon(Icons.person_outlined),
                        title: Text(person.name),
                        subtitle: const Text("الأسم"),
                      )),

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
                        title:
                            Text(person.isContinuousAid ? "مستمرة" : "منقطعة"),
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
                )),
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
