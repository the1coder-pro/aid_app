import 'package:aid_app/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive/hive.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
// import 'package:markdown/markdown.dart' as md;
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_core/core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../person.dart';
import 'register_page.dart';

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
    final hiveServiceProvider = Provider.of<HiveServiceProvider>(context);
    Person? person = (selectedIdProvider.selectedId != -1 || widget.id! >= 0)
        // widget.id! >= 0 &&  box.get(widget.id!)!.isInBox)
        ? hiveServiceProvider.getItem(widget.id!)
        : null;
    // Person? person = (selected)
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
    // debugPrint("${hiveServiceProvider.people}");
    return Directionality(
        textDirection: TextDirection.rtl,
        child: !(hiveServiceProvider.people.isNotEmpty && person != null)
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
                            icon: const Icon(Icons.contact_page_outlined),
                            onPressed: () async {
                              // print record pdf
                              final pdf = await generatePersonRecordPdf(person);

                              await Printing.sharePdf(
                                  bytes: await pdf.save(),
                                  filename: 'file_${person.name}.pdf');
                            }),
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
                                        title: Text("حذف ${person.name}؟"),
                                        content: const Text(
                                            "هل انت متأكد انك تريد حذف هذا الشخص؟"),
                                        actions: [
                                          TextButton(
                                              child: const Text("إلغاء"),
                                              onPressed: () =>
                                                  Navigator.pop(context)),
                                          TextButton(
                                              child: const Text("نعم"),
                                              onPressed: () async {
                                                if (hiveServiceProvider
                                                    .people.isNotEmpty) {
                                                  hiveServiceProvider
                                                      .deleteItem(widget.id!)
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

                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1000),
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                              content: Text(
                                                                  "تم حذف ${person.name} بنجاح",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          15))));
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
                        ),
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
                            onLongPress: () async {
                              if (person.name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        content: const Text(
                                            "لا توجد بيانات للنسخ",
                                            style: TextStyle(fontSize: 15))));
                              } else {
                                await Clipboard.setData(
                                        ClipboardData(text: person.name))
                                    .then((value) => ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(SnackBar(
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            content: const Text(
                                                "تم نسخ الإسم الكامل",
                                                style:
                                                    TextStyle(fontSize: 15)))));
                              }
                            },
                          )),
                          Card(
                              child: ListTile(
                            onLongPress: () async {
                              if (person.phoneNumber.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        content: const Text(
                                            "لا توجد بيانات للنسخ",
                                            style: TextStyle(fontSize: 15))));
                              } else {
                                await Clipboard.setData(ClipboardData(
                                        text: person.phoneNumber.toString()))
                                    .then((value) => ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(SnackBar(
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            content: const Text(
                                                "تم نسخ رقم الهاتف",
                                                style:
                                                    TextStyle(fontSize: 15)))));
                              }
                            },
                            leading: IconButton(
                                icon: const Icon(Icons.phone_outlined),
                                onPressed: () async {
                                  if (person.phoneNumber.isNotEmpty) {
                                    var url =
                                        Uri.parse('tel:${person.phoneNumber}');
                                    if (!await launchUrl(url)) {
                                      throw Exception('Could not launch $url');
                                    }
                                  }
                                }),
                            trailing: IconButton(
                                icon: const Icon(Icons.message_outlined),
                                onPressed: () async {
                                  if (person.phoneNumber.isNotEmpty) {
                                    var url =
                                        Uri.parse('sms:${person.phoneNumber}');
                                    if (!await launchUrl(url)) {
                                      throw Exception('Could not launch $url');
                                    }
                                  }
                                }),
                            title: Text(person.phoneNumber.isEmpty
                                ? "لا يوجد"
                                : person.phoneNumber),
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
                            onLongPress: () async {
                              if (person.idNumber.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        content: const Text(
                                            "لا توجد بيانات للنسخ",
                                            style: TextStyle(fontSize: 15))));
                              } else {
                                await Clipboard.setData(
                                        ClipboardData(text: person.idNumber))
                                    .then((value) =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                duration: const Duration(
                                                    milliseconds: 1000),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                content: const Text(
                                                    "تم نسخ رقم الهوية",
                                                    style: TextStyle(
                                                        fontSize: 15)))));
                              }
                            },
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
                            onLongPress: () async {
                              if (isDateHijri
                                  ? hijriDateRangeView.isEmpty
                                  : dateRangeView.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        content: const Text(
                                            "لا توجد بيانات للنسخ",
                                            style: TextStyle(fontSize: 15))));
                              } else {
                                await Clipboard.setData(ClipboardData(
                                        text: isDateHijri
                                            ? hijriDateRangeView
                                            : dateRangeView))
                                    .then((value) => ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            content: Text(
                                                "تم نسخ تاريخ المساعدة (${isDateHijri ? 'الهجري' : 'الميلادي'})",
                                                style: const TextStyle(
                                                    fontSize: 15)))));
                              }
                            },
                          )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.request_quote_outlined),
                            title: Text(person.aidType.isEmpty
                                ? 'لا يوجد'
                                : person.aidType),
                            subtitle: const Text("نوع المساعدة"),
                            onLongPress: () async {
                              if (person.aidType.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        content: const Text(
                                            "لا توجد بيانات للنسخ",
                                            style: TextStyle(fontSize: 15))));
                              } else {
                                await Clipboard.setData(
                                        ClipboardData(text: person.aidType))
                                    .then((value) =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                duration: const Duration(
                                                    milliseconds: 1000),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                content: const Text(
                                                    "تم نسخ نوع المساعدة",
                                                    style: TextStyle(
                                                        fontSize: 15)))));
                              }
                            },
                          )),
                          person.aidType != 'عينية' &&
                                  person.aidType != 'رمضانية'
                              ? Card(
                                  child: ListTile(
                                  leading:
                                      const Icon(Icons.attach_money_outlined),
                                  title: Text("${person.aidAmount} ريال"),
                                  subtitle: const Text("مقدار المساعدة"),
                                  onLongPress: () async {
                                    await Clipboard.setData(ClipboardData(
                                            text: person.aidAmount.toString()))
                                        .then((value) => ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                duration: const Duration(
                                                    milliseconds: 1000),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                content: const Text(
                                                    "تم نسخ مقدار المساعدة",
                                                    style: TextStyle(
                                                        fontSize: 15)))));
                                  },
                                ))
                              : Card(
                                  child: ListTile(
                                  leading: const Icon(Icons.kitchen_outlined),
                                  title: Text(person.aidTypeDetails!),
                                  subtitle: const Text("تفاصيل المساعدة"),
                                  onLongPress: () async {
                                    await Clipboard.setData(ClipboardData(
                                            text: person.aidTypeDetails!))
                                        .then((value) => ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(SnackBar(
                                                duration: const Duration(
                                                    milliseconds: 1000),
                                                backgroundColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                content: const Text(
                                                    "تم نسخ تفاصيل المساعدة",
                                                    style:
                                                        TextStyle(fontSize: 15)))));
                                  },
                                )),
                          Card(
                              child: ListTile(
                            leading: const Icon(Icons.update_outlined),
                            title: Text(
                                person.isContinuousAid ? "مستمرة" : "منقطعة"),
                            subtitle: const Text("مدة المساعدة"),
                            onLongPress: () async {
                              await Clipboard.setData(ClipboardData(
                                      text: person.isContinuousAid
                                          ? 'مستمرة'
                                          : 'منقطعة'))
                                  .then((value) => ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          content: const Text(
                                              "تم نسخ مدة المساعدة",
                                              style:
                                                  TextStyle(fontSize: 15)))));
                            },
                          )),
                          Card(
                              child: ListTile(
                            subtitle: const Text("الملاحظات"),
                            trailing: IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () async {
                                  await Clipboard.setData(
                                          ClipboardData(text: person.notes))
                                      .then((value) =>
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration:
                                                      const Duration(
                                                          milliseconds: 1000),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  content: const Text(
                                                      "تم نسخ الملاحظات",
                                                      style: TextStyle(
                                                          fontSize: 15)))));
                                }),
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(person.notes.isNotEmpty
                                  ? person.notes
                                  : 'لا يوجد'),

                              // MarkdownBody(
                              //   shrinkWrap: false,
                              //   softLineBreak: true,
                              //   selectable: true,
                              //   data: person.notes.isEmpty
                              //       ? 'لا يوجد'
                              //       : person.notes,

                              // extensionSet: md.ExtensionSet(
                              //   md.ExtensionSet..blockSyntaxes,
                              //   <md.InlineSyntax>[
                              //     md.EmojiSyntax(),
                              //     ...md.ExtensionSet.gitHubFlavored
                              //         .inlineSyntaxes
                              //   ],
                              // ),
                            ),
                          )),
                          Card(
                            child: ListTile(
                              onTap: () {
                                Share.share("""
                                الاسم: ${person.name}
رقم الهوية: ${person.idNumber}
رقم الهاتف: ${person.phoneNumber}
تاريخ المساعدة: ${isDateHijri ? hijriDateRangeView : dateRangeView}
نوع المساعدة: ${person.aidType}
مقدار المساعدة: ${person.aidAmount} ريال
مدة المساعدة: ${person.isContinuousAid ? 'مستمرة' : 'منقطعة'}
ملاحظات: ${person.notes.isNotEmpty ? person.notes : 'لا توجد'}
                              """);
                              },
                              title: const Text("مشاركة هذه المساعدة"),
                              subtitle: const Text("مشاركة"),
                              leading: const Icon(Icons.share_outlined),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }

  Future<pw.Document> generatePersonRecordPdf(Person personRecord) async {
    final font =
        await fontFromAssetBundle('fonts/IBMPlexSansArabic-Regular.ttf');
    final titleFont = await fontFromAssetBundle('fonts/Amiri-Regular.ttf');
    final boldFont =
        await fontFromAssetBundle('fonts/IBMPlexSansArabic-Bold.ttf');
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        margin: const pw.EdgeInsets.all(25),
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          pw.TextStyle tableStyle = pw.TextStyle(fontSize: 24, font: font);

          pw.TextStyle tableHeaderStyle = pw.TextStyle(
              fontSize: 24, font: boldFont, fontWeight: pw.FontWeight.bold);
          return pw.Column(children: [
            pw.Center(
                child: pw.Text("سجل مساعدة لـ",
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(font: titleFont, fontSize: 25))),
            pw.SizedBox(height: 5),
            pw.Center(
                child: pw.Text(personRecord.name,
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(font: font, fontSize: 30))),
            pw.SizedBox(height: 5),
            personRecord.aidDates.isNotEmpty
                ? pw.Center(
                    child: pw.Text(
                        "${intl.DateFormat('yyyy/MM/dd').format(personRecord.aidDates[0])} - ${intl.DateFormat('yyyy/MM/dd').format(personRecord.aidDates[1])}"),
                  )
                : pw.Container(),
            pw.SizedBox(height: 10),
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
                            child: pw.Text(
                                personRecord.idNumber.isEmpty
                                    ? '-'
                                    : personRecord.idNumber,
                                style: tableStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child:
                                pw.Text('رقم الهوية', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                    ]),
                    pw.TableRow(children: [
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text(personRecord.phoneNumber.toString(),
                                style: tableStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child:
                                pw.Text('رقم الهاتف', style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                    ]),
                    pw.TableRow(children: [
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text(personRecord.aidType,
                                style: tableStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('نوع المساعدة',
                                style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                    ]),
                    personRecord.aidType != 'عينية' &&
                            personRecord.aidType != 'رمضانية'
                        ? pw.TableRow(children: [
                            pw.Column(children: [
                              pw.Padding(
                                  child: pw.Text(
                                      "${personRecord.aidAmount} ريال",
                                      style: tableStyle),
                                  padding: const pw.EdgeInsets.all(4))
                            ]),
                            pw.Column(children: [
                              pw.Padding(
                                  child: pw.Text('مقدار المساعدة',
                                      style: tableHeaderStyle),
                                  padding: const pw.EdgeInsets.all(4))
                            ]),
                          ])
                        : pw.TableRow(children: [
                            pw.Column(children: [
                              pw.Padding(
                                  child: pw.Text(
                                      "${personRecord.aidTypeDetails}",
                                      style: tableStyle),
                                  padding: const pw.EdgeInsets.all(4))
                            ]),
                            pw.Column(children: [
                              pw.Padding(
                                  child: pw.Text('تفاصيل المساعدة',
                                      style: tableHeaderStyle),
                                  padding: const pw.EdgeInsets.all(4))
                            ]),
                          ]),
                    pw.TableRow(children: [
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text(
                                personRecord.isContinuousAid
                                    ? 'مستمرة'
                                    : 'منقطعة',
                                style: tableStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                      pw.Column(children: [
                        pw.Padding(
                            child: pw.Text('مدة المساعدة',
                                style: tableHeaderStyle),
                            padding: const pw.EdgeInsets.all(4))
                      ]),
                    ]),
                  ],
                )),
            pw.SizedBox(height: 20),
            pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("الملاحظات",
                    style: pw.TextStyle(font: font, fontSize: 20))),
            pw.Divider(height: 4),
            pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    personRecord.notes.isNotEmpty
                        ? personRecord.notes
                        : 'لا توجد',
                    style: pw.TextStyle(font: font, fontSize: 15)))
          ]); // Center
        }));
    return pdf;
  }
}
