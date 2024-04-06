import '/prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/core.dart';
import '../main.dart';
import '../person.dart';

class RegisterPage extends StatefulWidget {
  final int? id;
  const RegisterPage({super.key, this.id});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _typeDetailsController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  String description = '';

  final box = Hive.box<Person>('personList');

  AidDuration? _duration = AidDuration.continuous;

  String? aidType = aidTypes[7];

  List<DateTime> dateRange = [];

  // make a focus node for every field
  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode idNumberFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode dateFocusNode = FocusNode();
  FocusNode amountFocusNode = FocusNode();
  FocusNode typeFocusNode = FocusNode();
  FocusNode typeDetailsFocusNode = FocusNode();
  FocusNode notesFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    Person? loadPerson = widget.id != null ? box.getAt(widget.id!) : null;
    loadData(loadPerson);

    // add listener to every focus node
    firstNameFocusNode.addListener(() {
      if (!firstNameFocusNode.hasFocus) {
        // save the value of the field
        _firstNameController.text = _firstNameController.text.trim();
      }
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    phoneFocusNode.dispose();
    idNumberFocusNode.dispose();
    amountFocusNode.dispose();
    typeFocusNode.dispose();
    typeDetailsFocusNode.dispose();
    notesFocusNode.dispose();

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
      dateRange = loadPerson.aidDates;
      if (aidTypes.contains(loadPerson.aidType)) {
        aidType = loadPerson.aidType;
        debugPrint(aidTypes.contains(loadPerson.aidType).toString());
      } else {
        aidType = aidTypes.last;
        _typeController.text = loadPerson.aidType;
      }
      if (loadPerson.aidType == 'عينية' || loadPerson.aidType == 'رمضانية') {
        if (loadPerson.aidTypeDetails != null) {
          _typeDetailsController.text = loadPerson.aidTypeDetails!;
        }
      } else {
        _amountController.text = loadPerson.aidAmount.toString();
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
      return Directionality(
          textDirection: TextDirection.rtl,
          child: createPageScaffold(context, id: widget.id));
    }
    return Directionality(
        textDirection: TextDirection.rtl, child: createPageScaffold(context));
  }

  Widget clearButton(TextEditingController controller) {
    return IconButton(
        icon: const Icon(Icons.clear), onPressed: () => controller.text = '');
  }

  Scaffold createPageScaffold(BuildContext context, {int? id}) {
    final hiveProvider = Provider.of<HiveServiceProvider>(context);
    final selectedIdProvider = Provider.of<SelectedIdProvider>(context);

    bool savedPersonId = id != null;
    Person? loadPerson = savedPersonId ? box.getAt(id) : null;
    return Scaffold(
        appBar: AppBar(
            title:
                Text(savedPersonId ? "تعديل المساعدة" : "إنشاء مساعدة جديدة"),
            centerTitle: true,
            actions: [
              saveButton(savedPersonId, hiveProvider, selectedIdProvider,
                  loadPerson, context)
            ]),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(children: [
            ListTile(
              title: TextFormField(
                focusNode: firstNameFocusNode,
                autofocus: true,
                onFieldSubmitted: (value) {
                  firstNameFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(lastNameFocusNode);
                },
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                    suffixIcon: clearButton(_firstNameController),
                    label: const Text('الاسم الأول'),
                    border: const OutlineInputBorder(),
                    isDense: true),
                controller: _firstNameController,
                textInputAction: TextInputAction.next,
              ),
            ),
            ListTile(
              title: TextFormField(
                focusNode: lastNameFocusNode,
                onFieldSubmitted: (value) {
                  lastNameFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(idNumberFocusNode);
                },
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                    suffixIcon: clearButton(_lastNameController),
                    label: const Text('الاسم الأخير'),
                    border: const OutlineInputBorder(),
                    isDense: true),
                controller: _lastNameController,
                textInputAction: TextInputAction.next,
              ),
            ),
            ListTile(
              title: TextFormField(
                focusNode: idNumberFocusNode,
                onFieldSubmitted: (value) {
                  idNumberFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(phoneFocusNode);
                },
                decoration: InputDecoration(
                    suffixIcon: clearButton(_idNumberController),
                    label: const Text("رقم الهوية"),
                    border: const OutlineInputBorder(),
                    isDense: true),
                controller: _idNumberController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
              ),
            ),
            ListTile(
              title: TextFormField(
                focusNode: phoneFocusNode,
                onFieldSubmitted: (value) {
                  phoneFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(dateFocusNode);
                },
                decoration: InputDecoration(
                    suffixIcon: clearButton(_phoneController),
                    label: const Text("رقم الهاتف"),
                    border: const OutlineInputBorder(),
                    isDense: true),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                // onChanged: (value) {},
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 5),
            const Center(
                child: Text("تاريخ المساعدة",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 5),
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
                        const Text("الميلادي", style: TextStyle(fontSize: 15)),
                        Text(
                            "${intl.DateFormat('yyyy/MM/dd').format(dateRange[0])} - ${intl.DateFormat('yyyy/MM/dd').format(dateRange[1])}",
                            style: const TextStyle(fontSize: 15))
                      ]),
                      TableRow(children: [
                        const Text("الهجري", style: TextStyle(fontSize: 15)),
                        Text(
                            "${HijriDateTime.fromDateTime(dateRange[0]).toString().replaceAll('-', '/')} - ${HijriDateTime.fromDateTime(dateRange[1]).toString().replaceAll('-', '/')}",
                            style: const TextStyle(fontSize: 15))
                      ]),
                    ],
                  ),
                )),
              ),
            const SizedBox(height: 5),
            Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton.icon(
                      focusNode: dateFocusNode,
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
                                          headerStyle:
                                              const DateRangePickerHeaderStyle(
                                                  textStyle: TextStyle(
                                                      fontFamily:
                                                          'ibmPlexSansArabic',
                                                      fontSize: 20)),
                                          initialSelectedRange: dateRange
                                                  .isNotEmpty
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
                                              .withOpacity(0.2),
                                          selectionMode:
                                              DateRangePickerSelectionMode
                                                  .range,
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
                                                    .add(const Duration(
                                                        days: 10)));
                                              } else if (value.endDate !=
                                                  null) {
                                                dateRange.add(value.endDate!);
                                              }
                                              print(dateRange);
                                              setState(() {});

                                              Navigator.pop(context);
                                            }
                                          },
                                          showActionButtons: true),
                                    ),
                                  ),
                                ));
                        dateFocusNode.unfocus();
                        FocusScope.of(context).requestFocus(typeFocusNode);
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
                                  child: Dialog(
                                    child: SizedBox(
                                      width: 800,
                                      height: 400,
                                      child: SfHijriDateRangePicker(
                                          headerStyle:
                                              const DateRangePickerHeaderStyle(
                                                  textStyle: TextStyle(
                                                      fontFamily:
                                                          'ibmPlexSansArabic',
                                                      fontSize: 20)),
                                          initialSelectedRange: dateRange
                                                  .isNotEmpty
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
                                              .withOpacity(0.2),
                                          selectionMode:
                                              DateRangePickerSelectionMode
                                                  .range,
                                          confirmText: "تأكيد",
                                          cancelText: "إلغاء",
                                          onCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onSubmit: (Object? value) {
                                            if (value is HijriDateRange) {
                                              dateRange.clear();
                                              dateRange.add(value.startDate!
                                                  .toDateTime());
                                              if (value.endDate == null) {
                                                dateRange.add(value.startDate!
                                                    .toDateTime()
                                                    .add(const Duration(
                                                        days: 10)));
                                              } else if (value.endDate !=
                                                  null) {
                                                dateRange.add(value.endDate!
                                                    .toDateTime());
                                              }
                                              setState(() {});

                                              debugPrint(
                                                  "Saved DateRange is ${dateRange[0]} - ${dateRange[1]} and it's a ${dateRange[1].difference(dateRange[0]).inDays} days journey");
                                              debugPrint(
                                                  "Saved DateRange is ${HijriDateTime.fromDateTime(dateRange[0])} - ${HijriDateTime.fromDateTime(dateRange[1])}");
                                              Navigator.pop(context);
                                            }
                                          },
                                          showActionButtons: true),
                                    ),
                                  ),
                                ));
                      }),
                ]),
            const SizedBox(height: 20),
            ListTile(
              title: DropdownButtonFormField(
                focusNode: typeFocusNode,
                value: (aidTypes.contains(loadPerson?.aidType) ||
                        aidTypes.contains(aidType))
                    ? aidType
                    : aidTypes.last,
                decoration: const InputDecoration(
                    label: Text("نوع المساعدة"), border: OutlineInputBorder()),
                items: aidTypes
                    .map((e) => DropdownMenuItem(
                        value: e,
                        alignment: AlignmentDirectional.center,
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: 15),
                        )))
                    .toList(),
                onChanged: (value) {
                  setState(() => aidType = value);
                  if (aidType == aidTypes.last) {
                    FocusScope.of(context).requestFocus(typeDetailsFocusNode);
                  } else {
                    FocusScope.of(context).requestFocus(amountFocusNode);
                  }
                },
                onTap: () => TextInputAction.next,
              ),
            ),
            const SizedBox(height: 5),
            Visibility(
              visible: aidType == aidTypes.last,
              child: ListTile(
                title: TextFormField(
                  focusNode: typeDetailsFocusNode,
                  onFieldSubmitted: (value) {
                    typeDetailsFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(amountFocusNode);
                  },
                  decoration: InputDecoration(
                      suffixIcon: clearButton(_typeController),
                      label: const Text("نوع اخر"),
                      border: const OutlineInputBorder(),
                      isDense: true),
                  controller: _typeController,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Visibility(
              visible: aidType == 'عينية' || aidType == 'رمضانية',
              child: ListTile(
                title: TextFormField(
                  focusNode: amountFocusNode,
                  onFieldSubmitted: (value) {
                    amountFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(notesFocusNode);
                  },
                  decoration: InputDecoration(
                      suffixIcon: clearButton(_typeController),
                      label: const Text("تفاصيل"),
                      border: const OutlineInputBorder(),
                      isDense: true),
                  controller: _typeDetailsController,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Visibility(
              visible: aidType != 'عينية' && aidType != 'رمضانية',
              child: ListTile(
                title: TextFormField(
                  focusNode: amountFocusNode,
                  onFieldSubmitted: (value) {
                    amountFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(notesFocusNode);
                  },
                  decoration: InputDecoration(
                      suffixIcon: clearButton(_amountController),
                      label: const Text("مقدار المساعدة"),
                      border: const OutlineInputBorder(),
                      isDense: true),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ),
            const SizedBox(height: 5),
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
            ListTile(
              title: TextFormField(
                focusNode: notesFocusNode,
                textDirection: TextDirection.rtl,
                maxLines: null,
                minLines: 5,
                keyboardType: TextInputType.multiline,
                controller: _notesController,
                decoration: InputDecoration(
                    suffixIcon: clearButton(_amountController),
                    label: const Text("الملاحظات"),
                    border: const OutlineInputBorder(),
                    isDense: true),
              ),
            )
          ]),
        ));
  }

  IconButton saveButton(
      bool savedPersonId,
      HiveServiceProvider hiveProvider,
      SelectedIdProvider selectedIdProvider,
      Person? loadPerson,
      BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.check),
        onPressed: () {
          if (savedPersonId) {
            hiveProvider.updateItem(
                selectedIdProvider.selectedId,
                Person(
                    name:
                        "${_firstNameController.text} ${_lastNameController.text}",
                    idNumber: _idNumberController.text,
                    phoneNumber: _phoneController.text,
                    aidDates: dateRange,
                    aidType: aidType == aidTypes.last
                        ? _typeController.text
                        : aidType ?? aidTypes.last,
                    aidAmount: aidType != 'عينية' &&
                            aidType != 'رمضانية' &&
                            _amountController.text.isNotEmpty
                        ? double.parse(_amountController.text)
                        : 0.0,
                    aidTypeDetails: aidType == 'عينية' || aidType == 'رمضانية'
                        ? _typeDetailsController.text
                        : 'غير مسجل',
                    isContinuousAid:
                        _duration == AidDuration.continuous ? true : false,
                    notes: _notesController.text));
            debugPrint(
                "${loadPerson!.name} is now ${_firstNameController.text}");
          } else {
            hiveProvider.createItem(Person(
                name:
                    "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
                idNumber: _idNumberController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                aidDates: dateRange,
                aidType: aidType == aidTypes.last
                    ? _typeController.text.trim()
                    : (aidType ?? aidTypes[5]),
                aidAmount: aidType != 'عينية' &&
                        aidType != 'رمضانية' &&
                        _amountController.text.trim().isNotEmpty
                    ? double.parse(_amountController.text.trim())
                    : 0.0,
                aidTypeDetails: aidType == 'عينية' || aidType == 'رمضانية'
                    ? _typeDetailsController.text
                    : 'غير مسجل',
                isContinuousAid:
                    _duration == AidDuration.continuous ? true : false,
                notes: _notesController.text));
          }

          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(milliseconds: 1000),
              backgroundColor: Theme.of(context).colorScheme.primary,
              content: Text(
                  'تم حفظ "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}" بنجاح',
                  style: const TextStyle(fontSize: 15))));
        });
  }
}
