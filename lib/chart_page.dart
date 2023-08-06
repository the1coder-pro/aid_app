import 'package:aid_app/person.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ChartPage({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      SliverAppBar.large(
        pinned: true,
        snap: true,
        floating: true,
        expandedHeight: 160.0,
        title: const Text("الرسم البياني"),
      ),
      SliverList(
          delegate: SliverChildListDelegate([
        Center(
            child: SfCartesianChart(
                title: ChartTitle(text: 'تقرير لمجموع أنواع المساعدة'),
                legend: const Legend(isVisible: false),
                primaryXAxis:
                    CategoryAxis(labelStyle: const TextStyle(fontSize: 15)),
                series: <ChartSeries<ChartAidData, String>>[
              // Renders column chart
              ColumnSeries<ChartAidData, String>(
                  dataSource: peopleDataList,
                  xValueMapper: (ChartAidData data, _) => data.type,
                  yValueMapper: (ChartAidData data, _) => data.amount,
                  dataLabelMapper: (ChartAidData data, _) => "${data.amount}",
                  dataLabelSettings: const DataLabelSettings(
                      isVisible: true, textStyle: TextStyle(fontSize: 20)),
                  color: Theme.of(context).colorScheme.primary),
            ])),
        const SizedBox(height: 15),
        const Center(
            child: Text("المجموع كامل", style: TextStyle(fontSize: 20))),
        Center(
            child: Container(
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(2)),
              border: Border.all(color: Theme.of(context).colorScheme.primary)),
          child: Text(
            "$totalAmount ريال",
            style: const TextStyle(fontSize: 30),
            textDirection: TextDirection.rtl,
          ),
        )),
      ]))
    ]));
  }
}

class ChartAidData {
  ChartAidData(this.type, this.amount);
  final String type;
  final double amount;
}
