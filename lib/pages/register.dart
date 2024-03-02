import 'package:aid_app/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/core.dart';
import '../main.dart';
import '../person.dart';

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

  String description = '';

  final box = Hive.box<Person>('personList');

  AidDuration? _duration = AidDuration.continuous;

  String? aidType = aidTypes[5];

  List<DateTime> dateRange = [];

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
      fullName.removeAt(0);
      _lastNameController.text = fullName.join(' ');
      // "${fullName[1]} ${fullName.last != fullName[1] ? fullName.join('') : ''}";
      _phoneController.text = loadPerson.phoneNumber.toString();
      _idNumberController.text = loadPerson.idNumber.toString();
      _amountController.text = loadPerson.aidAmount.toString();
      dateRange = loadPerson.aidDates;
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
      description = _notesController.text;
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
    final hiveProvider = Provider.of<HiveServiceProvider>(context);

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
              IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    if (savedPersonId) {
                      // don't save empty fields by default

                      hiveProvider.updateItem(
                          id,
                          Person(
                              name:
                                  "${_firstNameController.text} ${_lastNameController.text}",
                              idNumber: _idNumberController.text,
                              phoneNumber: _phoneController.text.isNotEmpty
                                  ? int.parse(_phoneController.text)
                                  : 0,
                              aidDates: dateRange,
                              aidType: aidType == aidTypes.last
                                  ? _typeController.text
                                  : aidType ?? aidTypes.last,
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
                      hiveProvider.createItem(Person(
                          name:
                              "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
                          idNumber: _idNumberController.text.trim(),
                          phoneNumber: _phoneController.text.trim().isNotEmpty
                              ? int.parse(_phoneController.text.trim())
                              : 0,
                          aidDates: dateRange,
                          aidType: aidType == aidTypes.last
                              ? _typeController.text.trim()
                              : (aidType ?? aidTypes[5]),
                          aidAmount: _amountController.text.trim().isNotEmpty
                              ? int.parse(_amountController.text.trim())
                              : 0,
                          isContinuousAid: _duration == AidDuration.continuous
                              ? true
                              : false,
                          notes: _notesController.text));
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        content: Text(
                            'تم حفظ "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}" بنجاح',
                            style: const TextStyle(fontSize: 15))));
                  })
            ]),
        body: registerationForm(context, loadPerson),
      ),
    );
  }

  Form registerationForm(BuildContext context, Person? loadPerson) {
    return Form(
      // canPop: true,
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 15),
            ListTile(
              title: TextFormField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                    suffixIcon: clearButton(_firstNameController),
                    label: const Text("الأسم الأول"),
                    border: const OutlineInputBorder(),
                    isDense: true),
                controller: _firstNameController,
                onChanged: (value) => setState(() {}),
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 5),
            ListTile(
              title: TextFormField(
                decoration: InputDecoration(
                    suffixIcon: clearButton(_lastNameController),
                    label: const Text("الأسم الأخير"),
                    border: const OutlineInputBorder(),
                    isDense: true),
                controller: _lastNameController,
                onChanged: (value) => setState(() {}),
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 5),
            ListTile(
              title: TextFormField(
                decoration: InputDecoration(
                    suffixIcon: clearButton(_idNumberController),
                    label: const Text("رقم الهوية"),
                    border: const OutlineInputBorder(),
                    isDense: true),
                controller: _idNumberController,
                onChanged: (value) => setState(() {}),
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 5),
            ListTile(
              title: TextFormField(
                decoration: InputDecoration(
                    suffixIcon: clearButton(_phoneController),
                    label: const Text("رقم الهاتف"),
                    border: const OutlineInputBorder(),
                    isDense: true),
                controller: _phoneController,
                onChanged: (value) => setState(() {}),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 12),
            const Center(
                child: Text("تاريخ المساعدة",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            dateRange.isEmpty
                ? Container()
                : Center(
                    child: SizedBox(
                    width: 350,
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
            ListTile(
              title: Row(
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
                                        initialSelectedRange:
                                            dateRange.isNotEmpty
                                                ? PickerDateRange(
                                                    dateRange[0], dateRange[1])
                                                : null,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        startRangeSelectionColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                        endRangeSelectionColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                        rangeSelectionColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                            .withOpacity(0.5),
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
                                        initialSelectedRange:
                                            dateRange.isNotEmpty
                                                ? HijriDateRange(
                                                    HijriDateTime.fromDateTime(
                                                        dateRange[0]),
                                                    HijriDateTime.fromDateTime(
                                                        dateRange[1]))
                                                : null,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        startRangeSelectionColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                        endRangeSelectionColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                        rangeSelectionColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                            .withOpacity(0.5),
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
                                            dateRange.add(
                                                value.startDate!.toDateTime());
                                            dateRange.add(
                                                value.endDate!.toDateTime());
                                            setState(() {});

                                            debugPrint(
                                                "Saved DateRange is ${dateRange[0]} - ${dateRange[1]} and it's a ${dateRange[1].difference(dateRange[0]).inDays} days journey");
                                            debugPrint(
                                                "Saved DateRange is ${HijriDateTime.fromDateTime(dateRange[0])} - ${HijriDateTime.fromDateTime(dateRange[1])}");
                                            Navigator.pop(context);
                                          }
                                        },
                                        showActionButtons: true),
                                  ));
                        }),
                  ]),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: DropdownButtonFormField(
                value: (aidTypes.contains(loadPerson?.aidType) ||
                        aidTypes.contains(aidType))
                    ? aidType
                    : aidTypes.last,
                decoration: const InputDecoration(
                  label: Text("نوع المساعدة"),
                  border: OutlineInputBorder(),
                ),
                items: aidTypes
                    .map((e) => DropdownMenuItem(
                        value: e,
                        alignment: AlignmentDirectional.center,
                        child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => aidType = value),
                onTap: () => TextInputAction.next,
              ),
            ),
            const SizedBox(height: 5),
            Visibility(
              visible: aidType == aidTypes.last,
              child: ListTile(
                title: TextFormField(
                  decoration: InputDecoration(
                      suffixIcon: clearButton(_typeController),
                      label: const Text("نوع اخر"),
                      border: const OutlineInputBorder(),
                      isDense: true),
                  controller: _typeController,
                  onChanged: (value) => setState(() {}),
                  textInputAction: TextInputAction.next,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ListTile(
              title: TextFormField(
                decoration: InputDecoration(
                    suffixIcon: clearButton(_amountController),
                    label: const Text("مقدار المساعدة"),
                    border: const OutlineInputBorder(),
                    isDense: true),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _amountController,
                onChanged: (value) => setState(() {}),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 12),
            const Center(
                child: Text("مدة المساعدة",
                    style: TextStyle(fontWeight: FontWeight.bold))),
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
            MarkdownTextInput(
              (String value) {
                if (description != value) {
                  setState(() => description = value);
                }
              },
              description,
              label: 'الملاحظات',
              textDirection: TextDirection.rtl,
              maxLines: null,
              actions: const [
                MarkdownType.bold,
                MarkdownType.italic,
                MarkdownType.list,
                MarkdownType.blockquote,
                MarkdownType.title,
                MarkdownType.strikethrough,
                MarkdownType.separator
              ],
              controller: _notesController,
              textStyle: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
