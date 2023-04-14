import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:google_fonts/google_fonts.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TheThemeProvider themeChangeProvider = TheThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<TheThemeProvider>(
        builder: (BuildContext context, value, child) => DynamicColorBuilder(
          builder: (lightColorScheme, darkColorScheme) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Aid App',
            theme: ThemeData(
              useMaterial3: true,
              textTheme: textThemeDefault,
              colorScheme: lightColorScheme ?? lightColorSchemeDefault,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              textTheme: textThemeDefault,
              colorScheme: darkColorScheme ?? darkColorSchemeDefault,
            ),
            themeMode: themeChangeProvider.darkTheme
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const Directionality(
                textDirection: TextDirection.rtl,
                child: MyHomePage(title: 'الْمُسَاعَدَات')),
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
  int currentPageIndex = 0;
  SampleItem? selectedMenu;
  final box = Hive.box<Person>('personList');

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<TheThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.scheherazadeNew(),
          // style: GoogleFonts.ibmPlexSansArabic(),
        ),
        centerTitle: true,
        actions: [
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
        leading: PopupMenuButton<SampleItem>(
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
                          builder: ((context) => const Scaffold(
                                body: Center(child: Text("hi")),
                              ))));

                  break;
                // Printing Page
                case SampleItem.itemTwo:
                  debugPrint("open Printing Page");
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
                              title: Text(
                                "الإعدادات",
                                style: GoogleFonts.scheherazadeNew(),
                              ),
                            ),
                            body: Center(
                                child: ListView(
                              children: [
                                SwitchListTile(
                                    title: Text(
                                      "الوضع الليلي",
                                      style: GoogleFonts.ibmPlexSansArabic(),
                                    ),
                                    value: themeChange.darkTheme,
                                    onChanged: (bool value) =>
                                        themeChange.darkTheme = value)
                              ],
                            )),
                          ),
                        );
                      });
                  break;
              }
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
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
      body: Center(
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<Person> box, _) {
            if (box.isNotEmpty) {
              return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, i) {
                    var person = box.getAt(i);
                    return ListTile(
                      onLongPress: () => box
                          .delete(i)
                          .then((value) => debugPrint('deleted $i')),
                      leading: CircleAvatar(
                        child: Text(
                          (person!.name).toString().substring(0, 1),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        person.name,
                        style: const TextStyle(fontSize: 15),
                      ),
                      subtitle: RichText(
                          text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                            TextSpan(
                                text: "${person.phoneNumber}\n",
                                style: const TextStyle(fontSize: 15)),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: DetailsPage(
                                      id: i,
                                      person: person,
                                    ),
                                  )),
                        );
                      },
                    );
                  });
            } else {
              return Center(
                  child: Column(
                children: [
                  SizedBox(
                      height: 450,
                      width: 450,
                      child: Image.asset(themeChange.darkTheme
                          ? 'openBook-dark.png'
                          : 'openBook-light.png')),
                  Text("لا يوجد شيء"),
                ],
              ));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => const Directionality(
                        textDirection: TextDirection.rtl,
                        child: RegisterPage(),
                      )),
            );
          }),
    );
  }
}

enum AidDuration { continuous, interrupted }

const List<String> aidTypes = <String>[
  'صدقة',
  'زواج',
  'مؤونة',
  'اجار',
  'بناء',
  'أخرى'
];

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final box = Hive.box<Person>('personList');

  AidDuration? _duration = AidDuration.continuous;

  String? aidType = 'غير محددة';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("إنشاء مساعدة جديدة"),
          centerTitle: true,
          actions: [
            IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  box.add(Person(
                      name: _nameController.text,
                      idNumber: _idNumberController.text,
                      phoneNumber: _phoneController.text.isNotEmpty
                          ? int.parse(_phoneController.text)
                          : 0,
                      aidDates: [],
                      aidType: aidType == 'أخرى'
                          ? _typeController.text
                          : (aidType ?? 'غير محددة'),
                      aidAmount: _amountController.text.isNotEmpty
                          ? int.parse(_amountController.text)
                          : 0,
                      isContinuousAid:
                          _duration == AidDuration.continuous ? true : false,
                      notes: _notesController.text));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('تم حفظ "${_nameController.text}" بنجاح')),
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
                decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.clear),
                    label: Text("الأسم الكامل"),
                    border: OutlineInputBorder(),
                    isDense: true),
                controller: _nameController,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                    label: Text("رقم الهاتف"),
                    border: OutlineInputBorder(),
                    isDense: true),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                    label: Text("رقم الهوية"),
                    border: OutlineInputBorder(),
                    isDense: true),
                controller: _idNumberController,
                keyboardType: TextInputType.number,
                maxLength: 10,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                  decoration: const InputDecoration(
                    label: Text("نوع المساعدة"),
                    border: OutlineInputBorder(),
                  ),
                  items: aidTypes
                      .map((e) => DropdownMenuItem(
                          value: e,
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => aidType = value)),
              const SizedBox(height: 5),
              if (aidType == 'أخرى')
                TextFormField(
                  decoration: const InputDecoration(
                      label: Text("نوع اخر"),
                      border: OutlineInputBorder(),
                      isDense: true),
                  controller: _typeController,
                ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                    label: Text("مقدار المساعدة"),
                    border: OutlineInputBorder(),
                    isDense: true),
                controller: _amountController,
                keyboardType: TextInputType.number,
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
                decoration: const InputDecoration(
                    label: Text("الملاحظات"),
                    border: OutlineInputBorder(),
                    isDense: true),
                controller: _notesController,
                keyboardType: TextInputType.multiline,
                maxLines: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final int id;
  final Person person;
  const DetailsPage({super.key, required this.id, required this.person});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final box = Hive.box<Person>('personList');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.person.name), actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            box.delete(widget.id).then((value) => Navigator.pop(context));
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
              title: Text(widget.person.name),
              subtitle: const Text("الأسم"),
            )),

            Card(
                child: ListTile(
              title: Text("${widget.person.phoneNumber}"),
              subtitle: const Text("رقم الهاتف"),
            )),
            Card(
                child: ListTile(
              title: Text(widget.person.idNumber),
              subtitle: const Text("رقم الهوية"),
            )),
            Card(
                child: ListTile(
              title: Text(widget.person.aidDates.length >= 2
                  ? "${widget.person.aidDates[0]} - ${widget.person.aidDates[1]}"
                  : "لا يوجد"),
              subtitle: const Text("تاريخ المساعدة"),
            )),
            Card(
                child: ListTile(
              title: Text(widget.person.aidType),
              subtitle: const Text("نوع المساعدة"),
            )),
            Card(
                child: ListTile(
              title: Text("${widget.person.aidAmount} ريال"),
              subtitle: const Text("مقدار المساعدة"),
            )),
            Card(
                child: ListTile(
              title: Text(widget.person.isContinuousAid ? "مستمرة" : "منقطعة"),
              subtitle: const Text("مدة المساعدة"),
            )),
            Card(
                child: ListTile(
              title: Text(widget.person.notes),
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
    );
  }
}
