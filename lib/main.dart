import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';
import 'themes.dart';

void main() {
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
              colorScheme: lightColorScheme ??
                  ColorScheme.fromSeed(seedColor: Colors.lightBlue),
            ),
            darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: darkColorScheme ??
                    ColorScheme.fromSeed(seedColor: Colors.lightBlue)),
            themeMode: themeChangeProvider.darkTheme
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const Directionality(
                textDirection: TextDirection.rtl,
                child: MyHomePage(title: 'المساعدات')),
          ),
        ),
      ),
    );
  }
}

enum SampleItem { itemOne, itemTwo, itemThree }

List users = [
  {"name": "Mohammed", "age": 18, "job": "Developer"},
  {"name": "Ahmed Hassan", "age": 20, "job": "Marketing"},
  {"name": "Ali", "age": 25, "job": "Manager"},
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  SampleItem? selectedMenu;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<TheThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
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
                              title: const Text("الإعدادات"),
                            ),
                            body: Center(
                                child: ListView(
                              children: [
                                SwitchListTile(
                                    title: const Text("الوضع الليلي"),
                                    value: themeChange.darkTheme,
                                    onChanged: (bool value) =>
                                        themeChange.darkTheme = value)
                              ],
                            )
                                //     Switch(
                                //   value: themeChange.darkTheme,
                                //   onChanged: (bool value) {
                                //     themeChange.darkTheme = value;
                                //   },
                                // )
                                ),
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
        child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text((users[i]["name"]).toString().substring(0, 2)),
                ),
                title: Text(users[i]["name"]),
                subtitle: Text(users[i]["job"]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scaffold(
                              appBar: AppBar(title: Text(users[i]["name"])),
                              body: Center(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Card(
                                        elevation: 0.5,
                                        child: ListTile(
                                          title: Text(
                                              "hello,\n my name is ${users[i]["name"]},\n i'm a ${users[i]["age"]} year old."),
                                        ))
                                  ],
                                ),
                              )),
                            )),
                  );
                },
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text("إنشاء مساعدة جديدة")),
                        body: const Center(child: Text("Create")),
                      )),
            );
          }),
    );
  }
}
