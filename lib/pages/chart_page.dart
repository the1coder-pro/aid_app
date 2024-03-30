import '/person.dart';
import '/prefs.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:numeral/numeral.dart';

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
      if (entry.value > 0 && entry.key.toString().trim().isNotEmpty) {
        peopleDataList.add(ChartAidData(entry.key, entry.value));
      }
    }
    for (double value in chartAidMap.values) {
      totalAmount += value;
    }

    // debugPrint(chartAidMap.toString());
    // debugPrint(peopleDataList.length.toString());
  }

  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String Function(Match) mathFunc = (Match match) => '${match[1]},';
  String formatAmount(double amount) =>
      "\u202B${(double.parse(amount.toString())).numeral().replaceAll('K', ' ألف').replaceAll('M', ' مليون').replaceAll('B', ' مليار').replaceAll('T', ' ترليون ')}\u202C ريال\n";

  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(

        // Enables pinch zooming
        enablePinching: true,
        enableDoubleTapZooming: true);
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final hiveServiceProivder = Provider.of<HiveServiceProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("الرسم البياني"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              child: SfCartesianChart(
                  zoomPanBehavior: _zoomPanBehavior,
                  title: const ChartTitle(
                      text: 'تقرير لمجموع أنواع المساعدة',
                      textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ibmPlexSansArabic')),
                  legend: const Legend(isVisible: false),
                  primaryXAxis:
                      const CategoryAxis(labelStyle: TextStyle(fontSize: 20)),
                  series: <CartesianSeries<ChartAidData, String>>[
                // Renders column chart

                ColumnSeries<ChartAidData, String>(
                  dataSource: peopleDataList,
                  xValueMapper: (ChartAidData data, _) => data.type,
                  yValueMapper: (ChartAidData data, _) => data.amount,
                  dataLabelMapper: (ChartAidData data, _) =>
                      formatAmount(data.amount),
                  dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                          fontSize: 20, fontFamily: 'ibmPlexSansArabic')),
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ])),
          const SizedBox(height: 10),
          Divider(height: 2, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 10),
          Center(child: rowOfDetails(context, hiveServiceProivder)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Row rowOfDetails(
      BuildContext context, HiveServiceProvider hiveServiceProivder) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            const Center(
                child: Text("المجموع كامل",
                    style: TextStyle(
                        fontSize: 20, fontFamily: 'ibmPlexSansArabic'))),
            Center(
                child: RichText(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                      color: Theme.of(context).textTheme.displayLarge!.color,
                      fontSize: 20,
                      fontFamily: 'ibmPlexSansArabic'),
                  children: [
                    TextSpan(
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        text: formatAmount(totalAmount)),
                    TextSpan(
                        style: const TextStyle(fontSize: 16),
                        text:
                            "${totalAmount.toString().replaceAllMapped(reg, mathFunc)} ريال"),
                  ]),
            )),
          ],
        ),
        Column(
          children: [
            const Center(
                child: Text("عدد  المساعدات الكلي",
                    style: TextStyle(
                        fontSize: 20, fontFamily: 'ibmPlexSansArabic'))),
            Center(
                child: Text(
              hiveServiceProivder.people.length.toString(),
              style: TextStyle(
                  color: Theme.of(context).textTheme.displayLarge!.color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ibmPlexSansArabic'),
            ))
          ],
        )
      ],
    );
  }
}

class ChartAidData {
  ChartAidData(this.type, this.amount);
  final String type;
  final double amount;
}
