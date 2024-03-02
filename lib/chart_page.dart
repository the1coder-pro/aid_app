import 'package:aid_app/person.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ChartPage({super.key});

  @override
  ChartPageState createState() => ChartPageState();
}

class ChartPageState extends State<ChartPage> {
  final box = Hive.box<Person>('personList');

  List<ChartAidData> peopleDataList = [];
  double totalAmount = 0;
  Map<String, double> chartAidMap = {};

  loadData() {
    for (Person person in box.values) {
      if (chartAidMap.containsKey(person.aidType)) {
        if (person.aidType.trim().isNotEmpty) {
          chartAidMap.update(person.aidType,
              (value) => ((value) + person.aidAmount.toDouble()));
        }
      } else {
        if (person.aidType.isNotEmpty) {
          chartAidMap[person.aidType] = person.aidAmount.toDouble();
        }
      }
    }
    for (MapEntry<String, double> entry in chartAidMap.entries) {
      peopleDataList.add(ChartAidData(entry.key, entry.value));
    }
    for (double value in chartAidMap.values) {
      totalAmount += value;
    }

    debugPrint(chartAidMap.toString());
  }

  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String Function(Match) mathFunc = (Match match) => '${match[1]},';

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      const SliverAppBar.large(
        pinned: true,
        snap: true,
        floating: true,
        expandedHeight: 160.0,
        title: Text("الرسم البياني"),
      ),
      SliverList(
          delegate: SliverChildListDelegate([
        Center(
            child: SfCartesianChart(
                title: const ChartTitle(
                    text: 'تقرير لمجموع أنواع المساعدة',
                    textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ibmPlexSansArabic')),
                legend: const Legend(isVisible: false),
                primaryXAxis:
                    const CategoryAxis(labelStyle: TextStyle(fontSize: 15)),
                series: <CartesianSeries<ChartAidData, String>>[
              // Renders column chart
              ColumnSeries<ChartAidData, String>(
                  dataSource: peopleDataList,
                  xValueMapper: (ChartAidData data, _) => data.type,
                  yValueMapper: (ChartAidData data, _) => data.amount,
                  dataLabelMapper: (ChartAidData data, _) => "${data.amount}",
                  dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                          fontSize: 20, fontFamily: 'ibmPlexSansArabic')),
                  color: Theme.of(context).colorScheme.primary),
            ])),
        const SizedBox(height: 15),
        const Center(
            child: Text("المجموع كامل",
                style:
                    TextStyle(fontSize: 20, fontFamily: 'ibmPlexSansArabic'))),
        Center(
            child: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary)),
                child: RichText(
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                      style: TextStyle(
                          color:
                              Theme.of(context).textTheme.displayLarge!.color,
                          fontSize: 30,
                          fontFamily: 'ibmPlexSansArabic'),
                      children: [
                        TextSpan(
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            text: totalAmount
                                .toString()
                                .replaceAllMapped(reg, mathFunc)),
                        const TextSpan(text: ' ريال')
                      ]),
                ))),
        Center(
            child: Text(
          "عدد  المساعدات الكلي :${peopleDataList.length}",
          style: const TextStyle(fontFamily: 'ibmPlexSansArabic'),
        ))
      ]))
    ]));
  }
}

class ChartAidData {
  ChartAidData(this.type, this.amount);
  final String type;
  final double amount;
}
