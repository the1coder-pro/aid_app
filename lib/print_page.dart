import 'package:aid_app/person.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:dart_date/dart_date.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// import 'dart:html' as html;
import 'package:universal_html/html.dart' as html;

class PrintPage extends StatefulWidget {
  const PrintPage({super.key});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  List dateRange = [];
  final box = Hive.box<Person>('personList');

  List<Person> dateRangeIncludedPersonList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      SliverAppBar.large(
        pinned: true,
        snap: true,
        floating: true,
        expandedHeight: 160.0,
        title: const Text("الطباعة"),
      ),
      SliverList(
          delegate: SliverChildListDelegate([
        const Center(
            child: Text("تاريخ المساعدة",
                style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        dateRange.isEmpty
            ? Container()
            : Center(
                child: SizedBox(
                width: 400,
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
            textDirection: TextDirection.rtl,
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
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
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
                                      dateRange.clear();
                                      dateRange.add(value.startDate!);
                                      dateRange.add(value.endDate!);
                                      setState(() {});

                                      debugPrint(
                                          "Saved DateRange is ${dateRange[0]} - ${dateRange[1]} and it's a ${dateRange[1].difference(dateRange[0]).inDays} days journey");
                                      debugPrint(
                                          "Saved DateRange is ${HijriDateTime.fromDateTime(dateRange[0])} - ${HijriDateTime.fromDateTime(dateRange[1])}");
                                      setState(() {
                                        dateRangeIncludedPersonList.clear();
                                        for (int i = 0; i < box.length; i++) {
                                          Person? person = box.getAt(i);
                                          if (dateRange.isNotEmpty) {
                                            DateTime startDate = dateRange[0];
                                            DateTime endDate = dateRange[1];
                                            DateTime personStartDate =
                                                person!.aidDates[0];
                                            DateTime personEndDate =
                                                person.aidDates[1];

                                            if (personStartDate
                                                    .isSameOrAfter(startDate) &&
                                                personEndDate
                                                    .isSameOrBefore(endDate)) {
                                              dateRangeIncludedPersonList
                                                  .add(person);
                                              //
                                            }
                                          }
                                        }
                                      });
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
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
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
                                      dateRange
                                          .add(value.startDate!.toDateTime());
                                      dateRange
                                          .add(value.endDate!.toDateTime());
                                      setState(() {});

                                      debugPrint(
                                          "Saved DateRange is ${dateRange[0]} - ${dateRange[1]} and it's a ${dateRange[1].difference(dateRange[0]).inDays} days journey");
                                      debugPrint(
                                          "Saved DateRange is ${HijriDateTime.fromDateTime(dateRange[0])} - ${HijriDateTime.fromDateTime(dateRange[1])}");
                                      setState(() {
                                        dateRangeIncludedPersonList.clear();
                                        for (int i = 0; i < box.length; i++) {
                                          Person? person = box.getAt(i);
                                          if (dateRange.isNotEmpty) {
                                            DateTime startDate = dateRange[0];
                                            DateTime endDate = dateRange[1];
                                            if (person != null) {
                                              DateTime personStartDate =
                                                  person.aidDates[0];
                                              DateTime personEndDate =
                                                  person.aidDates[1];

                                              if (personStartDate.isSameOrAfter(
                                                      startDate) &&
                                                  personEndDate.isSameOrBefore(
                                                      endDate)) {
                                                dateRangeIncludedPersonList
                                                    .add(person);
                                                //
                                              }
                                            }
                                          }
                                        }
                                      });
                                      Navigator.pop(context);
                                    }
                                  },
                                  showActionButtons: true),
                            ));
                  }),
            ]),
        SizedBox(
            height: 250,
            child: Center(
              child: ListView.separated(
                  itemCount: dateRangeIncludedPersonList.length,
                  separatorBuilder: (context, i) =>
                      const Divider(indent: 60, endIndent: 60, thickness: 2),
                  itemBuilder: (context, i) {
                    if (dateRangeIncludedPersonList.isEmpty) {
                      return const Center(
                          child: Text('لا يوجد مساعدات بهذه التواريخ'));
                    }
                    Person person = dateRangeIncludedPersonList[i];
                    return ListTile(
                        title: Center(child: Text(person.name)),
                        subtitle: Center(
                          child: Text(
                              "${intl.DateFormat('yyyy/MM/dd').format(person.aidDates[0])} - ${intl.DateFormat('yyyy/MM/dd').format(person.aidDates[1])}"),
                        ));
                  }),
            )),
        dateRangeIncludedPersonList.isEmpty
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilledButton.icon(
                    icon: const Icon(Icons.print_outlined),
                    onPressed: () async {
                      final pdf = pw.Document();
                      final font =
                          await PdfGoogleFonts.iBMPlexSansArabicRegular();
                      final boldFont =
                          await PdfGoogleFonts.iBMPlexSansArabicBold();

                      pdf.addPage(pw.Page(
                          pageFormat: PdfPageFormat.a4,
                          build: (pw.Context context) {
                            pw.TextStyle tableStyle =
                                pw.TextStyle(fontSize: 20.0, font: font);

                            pw.TextStyle tableHeaderStyle = pw.TextStyle(
                                fontSize: 15,
                                font: boldFont,
                                fontWeight: pw.FontWeight.bold);
                            return pw.Column(children: [
                              pw.Center(
                                  child: pw.Text("المساعدات",
                                      textDirection: pw.TextDirection.rtl,
                                      style: pw.TextStyle(font: font))),
                              pw.Center(
                                  child: pw.Text(
                                      "${intl.DateFormat('yyyy/MM/dd').format(dateRange[0])} - ${intl.DateFormat('yyyy/MM/dd').format(dateRange[1])}",

                                      // Text(
                                      //     "${intl.DateFormat('yyyy/MM/dd').format(startDate)} - ${intl.DateFormat('yyyy/MM/dd').format(dateRange[1])}")

                                      // Text(
                                      //     "${HijriDateTime.fromDateTime(dateRange[0]).toString().replaceAll('-', '/')} - ${HijriDateTime.fromDateTime(dateRange[1]).toString().replaceAll('-', '/')}")

                                      textDirection: pw.TextDirection.rtl,
                                      style: pw.TextStyle(font: font))),
                              pw.Directionality(
                                  textDirection: pw.TextDirection.rtl,
                                  child: pw.Table(
                                    defaultColumnWidth:
                                        const pw.FixedColumnWidth(120.0),
                                    border: pw.TableBorder.all(
                                        color: PdfColors.black,
                                        style: pw.BorderStyle.solid,
                                        width: 2),
                                    children: [
                                      pw.TableRow(children: [
                                        pw.Column(children: [
                                          pw.Text('النوع',
                                              style: tableHeaderStyle)
                                        ]),
                                        pw.Column(children: [
                                          pw.Text('القيمة',
                                              style: tableHeaderStyle)
                                        ]),
                                        pw.Column(children: [
                                          pw.Text('التاريخ',
                                              style: tableHeaderStyle)
                                        ]),
                                        pw.Column(children: [
                                          pw.Text('الاسم',
                                              style: tableHeaderStyle)
                                        ]),
                                      ]),
                                      for (Person person
                                          in dateRangeIncludedPersonList)
                                        pw.TableRow(children: [
                                          pw.Column(children: [
                                            pw.Text(person.aidType,
                                                style: tableStyle.copyWith(
                                                    fontSize: 15))
                                          ]),
                                          pw.Column(children: [
                                            pw.Text(person.aidAmount.toString(),
                                                style: tableStyle.copyWith(
                                                    fontSize: 15))
                                          ]),
                                          pw.Column(children: [
                                            pw.Text(
                                                intl.DateFormat('yyyy/MM/dd')
                                                    .format(person.aidDates[0]),
                                                style: tableStyle.copyWith(
                                                    fontSize: 15))
                                          ]),
                                          pw.Column(children: [
                                            pw.Text(person.name,
                                                style: tableStyle.copyWith(
                                                    fontSize: 15))
                                          ]),
                                        ]),
                                    ],
                                  )),
                            ]); // Center
                          }));
                      // await Printing.layoutPdf(
                      //     onLayout: (PdfPageFormat format) async =>
                      //         await Printing.convertHtml(html: '<h1>Hello</h1>'));
                      Uint8List pdfInBytes = await pdf.save();

//Create blob and link from bytes
                      final blob = html.Blob([pdfInBytes], 'application/pdf');

                      final url = html.Url.createObjectUrlFromBlob(blob);
                      final anchor =
                          html.document.createElement('a') as html.AnchorElement
                            ..href = url
                            ..style.display = 'none'
                            ..download = 'file.pdf';
                      html.document.body!.children.add(anchor);

//Trigger the download of this PDF in the browser.
                      anchor.click();
                      Navigator.pop(context);
                    },
                    label: const Text("طباعة")),
              ),
      ]))
    ]));
  }
}
