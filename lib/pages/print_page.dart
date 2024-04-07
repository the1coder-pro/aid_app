import 'dart:convert';
import '/pages/details_page.dart';
import '/prefs.dart';
import 'package:provider/provider.dart';
import "package:universal_html/html.dart" as html;
import 'dart:io';
import '/person.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:dart_date/dart_date.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintPage extends StatefulWidget {
  const PrintPage({super.key});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  List dateRange = [];
  final box = Hive.box<Person>('personList');

  List<Person> dateRangeIncludedPersonList = [];

  pw.Document pdf = pw.Document();

  @override
  Widget build(BuildContext context) {
    final selectedIdProvider = Provider.of<SelectedIdProvider>(context);
    return Scaffold(
        appBar: AppBar(title: const Text("الطباعة"), centerTitle: true),
        body: ListView(children: [
          const Center(
              child: Text("تاريخ المساعدة",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          if (dateRange.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: SizedBox(
                width: 400,
                child: Table(
                  textDirection: TextDirection.rtl,
                  children: [
                    TableRow(children: [
                      const Text("الميلادي", style: TextStyle(fontSize: 10)),
                      Text(
                          "${intl.DateFormat('yyyy/MM/dd').format(dateRange[0])} - ${intl.DateFormat('yyyy/MM/dd').format(dateRange[1])}",
                          style: const TextStyle(fontSize: 10))
                    ]),
                    TableRow(children: [
                      const Text("الهجري", style: TextStyle(fontSize: 10)),
                      Text(
                          "${HijriDateTime.fromDateTime(dateRange[0]).toString().replaceAll('-', '/')} - ${HijriDateTime.fromDateTime(dateRange[1]).toString().replaceAll('-', '/')}",
                          style: const TextStyle(fontSize: 10))
                    ]),
                  ],
                ),
              )),
            ),
          const SizedBox(height: 10),
          Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                dateButton(context),
                hijriDateButton(context),
              ]),
          if (dateRangeIncludedPersonList.isNotEmpty)
            SizedBox(
              height: 370,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                      rows: dateRangeIncludedPersonList
                          .map((record) => DataRow(cells: [
                                DataCell(Text((dateRangeIncludedPersonList
                                            .indexOf(record) +
                                        1)
                                    .toString())),
                                DataCell(Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(record.name),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.visibility_outlined),
                                      onPressed: () {
                                        var selectedContactIndex =
                                            Provider.of<HiveServiceProvider>(
                                                    context,
                                                    listen: false)
                                                .people
                                                .indexOf(record);
                                        selectedIdProvider.selectedId =
                                            selectedContactIndex;
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return DetailsPage(record);
                                        }));
                                      },
                                    )
                                  ],
                                )),
                                DataCell(Text(intl.DateFormat('yyyy-MM-dd')
                                    .format(record.aidDates[0]))),
                                DataCell(Text(intl.DateFormat('yyyy-MM-dd')
                                    .format(record.aidDates[1]))),
                                DataCell(Text(record.idNumber.isNotEmpty
                                    ? record.idNumber
                                    : '-')),
                                DataCell(Text(record.aidType)),
                                DataCell(Text(record.aidAmount.toString())),
                                DataCell(Text(record.isContinuousAid
                                    ? 'مستمرة'
                                    : 'منقطعة')),
                                DataCell(Text(
                                    record.phoneNumber.toString().isNotEmpty
                                        ? record.phoneNumber.toString()
                                        : '-')),
                              ]))
                          .toList(),
                      columns: [
                        '#',
                        'الاسم',
                        'تاريخ البداية',
                        'تاريخ النهاية',
                        'رقم الهوية',
                        'النوع',
                        'المقدار',
                        'المدة',
                        'رقم الهاتف',
                      ]
                          .map((label) => DataColumn(label: Text(label)))
                          .toList()),
                ),
              ),
            ),
          if (dateRangeIncludedPersonList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  shareButton(),
                  downloadButton(),
                  printingButton(),
                ],
              ),
            ),
        ]));
  }

  OutlinedButton dateButton(BuildContext context) {
    return OutlinedButton.icon(
        icon: const Icon(Icons.calendar_month_outlined),
        label: const Text("تاريخ (ميلادي)"),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: Dialog(
                      child: SizedBox(
                        width: 800,
                        height: 400,
                        child: SfDateRangePicker(
                            headerStyle: const DateRangePickerHeaderStyle(
                                textStyle: TextStyle(
                                    fontFamily: 'ibmPlexSansArabic',
                                    fontSize: 20)),
                            initialSelectedRange: dateRange.isNotEmpty
                                ? PickerDateRange(dateRange[0], dateRange[1])
                                : null,
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            startRangeSelectionColor:
                                Theme.of(context).colorScheme.primary,
                            endRangeSelectionColor:
                                Theme.of(context).colorScheme.primary,
                            rangeSelectionColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.2),
                            selectionMode: DateRangePickerSelectionMode.range,
                            confirmText: "تأكيد",
                            cancelText: "إلغاء",
                            onCancel: () {
                              Navigator.pop(context);
                            },
                            onSubmit: (Object? value) {
                              if (value is PickerDateRange) {
                                dateRange.clear();
                                dateRange.add(value.startDate!);
                                if (value.endDate == null) {
                                  dateRange.add(value.startDate!
                                      .add(const Duration(days: 10)));
                                } else if (value.endDate != null) {
                                  dateRange.add(value.endDate!);
                                }
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
                                      if (person != null &&
                                          person.aidDates.isNotEmpty) {
                                        DateTime personStartDate =
                                            person.aidDates[0];
                                        DateTime personEndDate =
                                            person.aidDates[1];
                                        if (personStartDate
                                                .isSameOrAfter(startDate) &&
                                            personEndDate
                                                .isSameOrBefore(endDate) &&
                                            person.aidDates.isNotEmpty) {
                                          dateRangeIncludedPersonList
                                              .add(person);
                                        }
                                      }
                                    }
                                  }
                                });
                                Navigator.pop(context);
                                if (dateRangeIncludedPersonList.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          content: const Text(
                                              "لا توجد مساعدات في هذه التواريخ.")));
                                }
                              }
                            },
                            showActionButtons: true),
                      ),
                    ),
                  ));
        });
  }

  OutlinedButton hijriDateButton(BuildContext context) {
    return OutlinedButton.icon(
        icon: const Icon(Icons.calendar_month_outlined),
        label: const Text("تاريخ (هجري)"),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: Dialog(
                      child: SizedBox(
                        width: 800,
                        height: 400,
                        child: SfHijriDateRangePicker(
                            headerStyle: const DateRangePickerHeaderStyle(
                                textStyle: TextStyle(
                                    fontFamily: 'ibmPlexSansArabic',
                                    fontSize: 20)),
                            initialSelectedRange: dateRange.isNotEmpty
                                ? HijriDateRange(
                                    HijriDateTime.fromDateTime(dateRange[0]),
                                    HijriDateTime.fromDateTime(dateRange[1]))
                                : null,
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            startRangeSelectionColor:
                                Theme.of(context).colorScheme.primary,
                            endRangeSelectionColor:
                                Theme.of(context).colorScheme.primary,
                            rangeSelectionColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.2),
                            selectionMode: DateRangePickerSelectionMode.range,
                            confirmText: "تأكيد",
                            cancelText: "إلغاء",
                            onCancel: () {
                              Navigator.pop(context);
                            },
                            onSubmit: (Object? value) {
                              if (value is HijriDateRange) {
                                dateRange.clear();
                                dateRange.add(value.startDate!.toDateTime());
                                if (value.endDate == null) {
                                  dateRange.add(value.startDate!
                                      .toDateTime()
                                      .add(const Duration(days: 10)));
                                } else if (value.endDate != null) {
                                  dateRange.add(value.endDate!.toDateTime());
                                }
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
                                      if (person != null &&
                                          person.aidDates.isNotEmpty) {
                                        DateTime personStartDate =
                                            person.aidDates[0];
                                        DateTime personEndDate =
                                            person.aidDates[1];

                                        if (personStartDate
                                                .isSameOrAfter(startDate) &&
                                            personEndDate
                                                .isSameOrBefore(endDate) &&
                                            person.aidDates.isNotEmpty) {
                                          dateRangeIncludedPersonList
                                              .add(person);
                                        }
                                      }
                                    }
                                  }
                                });
                                Navigator.pop(context);
                                if (dateRangeIncludedPersonList.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          content: const Text(
                                              "لا توجد مساعدات في هذه التواريخ.")));
                                }
                              }
                            },
                            showActionButtons: true),
                      ),
                    ),
                  ));
        });
  }

  Expanded printingButton() {
    return Expanded(
      flex: 2,
      child: FilledButton.icon(
          onPressed: () async {
            await generatePdf();
            setState(() {});
            await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdf.save());
          },
          label: const Text("طباعة"),
          icon: const Icon(Icons.print_outlined)),
    );
  }

  IconButton shareButton() {
    return IconButton(
        onPressed: () async {
          await generatePdf();
          setState(() {});
          await Printing.sharePdf(
              bytes: await pdf.save(),
              filename:
                  'file_${intl.DateFormat('yyyy-MM-dd').format(dateRange[0])}_${intl.DateFormat('yyyy-MM-dd').format(dateRange[1])}.pdf');
        },
        icon: const Icon(Icons.share_outlined));
  }

  IconButton downloadButton() {
    return IconButton(
        icon: const Icon(Icons.download_outlined),
        onPressed: () async {
          await generatePdf();
          setState(() {});
          try {
            // which os is it?
            if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
              String? outputFile = await FilePicker.platform.saveFile(
                dialogTitle: 'Please select an output file:',
                fileName:
                    'file_${intl.DateFormat('yyyy-MM-dd').format(dateRange[0])}_${intl.DateFormat('yyyy-MM-dd').format(dateRange[1])}.pdf',
              );

              if (outputFile == null) {
                debugPrint("User canceled the picker");
              } else {
                final file = File(outputFile);
                await file.writeAsBytes(await pdf.save());
              }
            } else if (Platform.isAndroid || Platform.isIOS) {
              String? selectedDirectory =
                  await FilePicker.platform.getDirectoryPath();

              if (selectedDirectory == null) {
                debugPrint("User canceled the picker");
              } else {
                final file = File(
                    "$selectedDirectory/file_${intl.DateFormat('yyyy-MM-dd').format(dateRange[0])}_${intl.DateFormat('yyyy-MM-dd').format(dateRange[1])}.pdf");
                await file.writeAsBytes(await pdf.save());
              }
            }
          } catch (e) {
            var savedFile = await pdf.save();
            List<int> fileInts = List.from(savedFile);
            html.AnchorElement(
                href:
                    "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}")
              ..setAttribute("download",
                  "file_${intl.DateFormat('yyyy-MM-dd').format(dateRange[0])}_${intl.DateFormat('yyyy-MM-dd').format(dateRange[1])}.pdf")
              ..click();
          }
        });
  }

  Future<void> generatePdf() async {
    final font =
        await fontFromAssetBundle('fonts/IBMPlexSansArabic-Regular.ttf');
    final boldFont =
        await fontFromAssetBundle('fonts/IBMPlexSansArabic-Bold.ttf');
    pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
        maxPages: 40,
        margin: const pw.EdgeInsets.all(20),
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          pw.TextStyle tableStyle = pw.TextStyle(fontSize: 20.0, font: font);

          pw.TextStyle tableHeaderStyle = pw.TextStyle(
              fontSize: 10, font: boldFont, fontWeight: pw.FontWeight.bold);
          debugPrint(dateRangeIncludedPersonList.toString());

          return [
            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(children: [
                    pw.Center(
                        child: pw.Text(
                            "الميلادي: ${intl.DateFormat('yyyy/MM/dd').format(dateRange[0])} - ${intl.DateFormat('yyyy/MM/dd').format(dateRange[1])}",
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(font: font))),
                    pw.Center(
                        child: pw.Text(
                            "الهجري: ${HijriDateTime.fromDateTime(dateRange[0]).toString().replaceAll('-', '/')} - ${HijriDateTime.fromDateTime(dateRange[1]).toString().replaceAll('-', '/')}",
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(font: font))),
                  ]),
                  pw.Center(
                      child: pw.Text("فترة المساعدات",
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 25,
                              fontWeight: pw.FontWeight.bold))),
                ]),
            pw.SizedBox(height: 5),
            pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Table(
                  border: pw.TableBorder.all(
                      color: PdfColors.black,
                      style: pw.BorderStyle.solid,
                      width: 1),
                  children: [
                    pw.TableRow(children: [
                      pw.Column(children: [
                        pw.Padding(
                            child:
                                pw.Text('رقم الهاتف', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('المدة', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('المقدار', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('النوع', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child:
                                pw.Text('رقم الهوية', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('تاريخ النهاية',
                                style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('تاريخ البداية',
                                style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('الاسم', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                    ]),
                    for (Person person in dateRangeIncludedPersonList)
                      pw.TableRow(children: [
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(person.phoneNumber.toString(),
                                  style: tableStyle.copyWith(fontSize: 10)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(
                                  person.isContinuousAid ? 'مستمرة' : 'منقطعة',
                                  style: tableStyle.copyWith(fontSize: 10)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(person.aidAmount.toString(),
                                  style: tableStyle.copyWith(fontSize: 10)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(person.aidType,
                                  style: tableStyle.copyWith(fontSize: 10)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(
                                  person.idNumber == ''
                                      ? '-'
                                      : person.idNumber.toString(),
                                  style: tableStyle.copyWith(fontSize: 10)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(
                                  intl.DateFormat('yyyy/MM/dd')
                                      .format(person.aidDates[1]),
                                  style: tableStyle.copyWith(fontSize: 10)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(
                                  intl.DateFormat('yyyy/MM/dd')
                                      .format(person.aidDates[0]),
                                  style: tableStyle.copyWith(fontSize: 10)))
                        ]),
                        pw.Column(children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Text(person.name,
                                  style: tableStyle.copyWith(fontSize: 10)))
                        ]),
                      ]),
                  ],
                )),
          ];
        }));
  }
}
