import 'package:aidapp/pages/custom_additions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/core.dart';

import 'package:aidapp/main.dart';

import '../person.dart';
import '/prefs.dart';

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
  FocusNode otherTypeFocusNode = FocusNode();
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
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    phoneFocusNode.dispose();
    idNumberFocusNode.dispose();
    amountFocusNode.dispose();
    typeFocusNode.dispose();
    typeDetailsFocusNode.dispose();
    otherTypeFocusNode.dispose();
    notesFocusNode.dispose();
    dateFocusNode.dispose();
    _notesController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    _amountController.dispose();
    _typeController.dispose();
    _typeDetailsController.dispose();

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
      }
      _amountController.text = loadPerson.aidAmount.toString();

      _duration = loadPerson.isContinuousAid
          ? AidDuration.continuous
          : AidDuration.interrupted;
      _notesController.text = loadPerson.notes;
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
            const DividerWithTitle("تاريخ المساعدة"),
            const SizedBox(height: 5),
            if (dateRange.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: SizedBox(
                  width: 400,
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2)
                    },
                    textDirection: TextDirection.rtl,
                    children: [
                      TableRow(children: [
                        const Align(
                            alignment: Alignment.center,
                            child: Text("الميلادي",
                                style: TextStyle(fontSize: 14))),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                              "${intl.DateFormat('yyyy/MM/dd').format(dateRange[0])} - ${intl.DateFormat('yyyy/MM/dd').format(dateRange[1])}",
                              style: const TextStyle(fontSize: 14)),
                        )
                      ]),
                      TableRow(children: [
                        const Align(
                            alignment: Alignment.center,
                            child:
                                Text("الهجري", style: TextStyle(fontSize: 14))),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                              "${HijriDateTime.fromDateTime(dateRange[0]).toString().replaceAll('-', '/')} - ${HijriDateTime.fromDateTime(dateRange[1]).toString().replaceAll('-', '/')}",
                              style: const TextStyle(fontSize: 14)),
                        )
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
                                              debugPrint(dateRange.toString());
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
                    FocusScope.of(context).requestFocus(otherTypeFocusNode);
                  } else if (aidType == 'عينية' || aidType == 'رمضانية') {
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
                  focusNode: otherTypeFocusNode,
                  onFieldSubmitted: (value) {
                    otherTypeFocusNode.unfocus();
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
                  focusNode: typeDetailsFocusNode,
                  onFieldSubmitted: (value) {
                    typeDetailsFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(amountFocusNode);
                  },
                  decoration: InputDecoration(
                      suffixIcon: clearButton(_typeDetailsController),
                      label: const Text("تفاصيل"),
                      border: const OutlineInputBorder(),
                      isDense: true),
                  controller: _typeDetailsController,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ),
            const SizedBox(height: 2),
            ListTile(
              title: TextFormField(
                focusNode: amountFocusNode,
                onFieldSubmitted: (value) async {
                  amountFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(notesFocusNode);
                },
                decoration: InputDecoration(
                    suffixIcon: clearButton(_amountController),
                    label: const Text("مقدار المساعدة"),
                    border: const OutlineInputBorder(),
                    isDense: true),
                controller: _amountController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                ],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 5),
            const DividerWithTitle("مدة المساعدة"),
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

            ListTile(
              title: TextField(
                controller: _notesController,
                showCursor: true,
                focusNode: notesFocusNode,
                textDirection: TextDirection.rtl,
                minLines: 4,
                textAlign: TextAlign.right,

                decoration: InputDecoration(
                    suffixIcon: clearButton(_notesController),
                    labelText: "الملاحظات",
                    border: const OutlineInputBorder(),
                    isDense: true),
                // reverse the cursor direction of movement
                inputFormatters: [EndSpaceFormatter()],
                maxLines: null,
                keyboardType: TextInputType.multiline,
                cursorColor: Theme.of(context).colorScheme.onBackground,
              ),
            ),

            // Directionality(
            //   textDirection: TextDirection.rtl,
            //   child: NativeTextInput(
            //     controller: _notesController,
            //     onChanged: (value) {},
            //     textAlign: TextAlign.right,

            //     minLines: 3,
            //     focusNode: notesFocusNode,
            //     returnKeyType: ReturnKeyType.next,

            //     style: TextStyle(
            //         color: Theme.of(context).colorScheme.onBackground,
            //         fontSize: 20),
            //     placeholderColor: Theme.of(context).colorScheme.onBackground,
            //     decoration: BoxDecoration(
            //         color: Theme.of(context).colorScheme.background,
            //         border: Border.all(
            //             color: Theme.of(context).colorScheme.onBackground)),
            //     // get the number of lines from _notesController
            //     maxLines: 5,
            //   ),
            // ),

            // NativeTextInput(
            //   controller: myController,
            //   onChanged: (value) {
            //     setState(() {
            //       _notesController.text = value;
            //     });
            //   },
            //   minLines: 3,
            //   focusNode: notesFocusNode,
            //   returnKeyType: ReturnKeyType.next,

            //   style: TextStyle(
            //       color: Theme.of(context).colorScheme.onBackground,
            //       fontSize: 20),
            //   placeholderColor: Theme.of(context).colorScheme.onBackground,
            //   decoration: BoxDecoration(
            //       color: Theme.of(context).colorScheme.background,
            //       border: Border.all(
            //           color: Theme.of(context).colorScheme.onBackground)),
            //   // get the number of lines from _notesController
            //   maxLines: 5,
            // ),

            // ListTile(
            //   title: SizedBox(
            //       height: 200,
            //       child: WebViewWidget(
            //         key: UniqueKey(),
            //         gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            //           Factory<EagerGestureRecognizer>(
            //               () => EagerGestureRecognizer()),
            //         },
            //         controller: webViewcontroller,
            //       )),
            // ),

            // ListTile(
            //   title: TextField(
            //     focusNode: notesFocusNode,
            //     maxLines: null,
            //     minLines: 5,
            //     // don't change cursor position when language changes
            //     textDirection: TextDirection.rtl,
            //     textAlign: TextAlign.left,
            //     //cursor

            //     keyboardType: TextInputType.multiline,
            //     controller: _notesController,

            //     decoration: InputDecoration(
            //         suffixIcon: clearButton(_notesController),
            //         label: const Text("الملاحظات"),
            //         border: const OutlineInputBorder(),
            //         isDense: true),
            //   ),
            // ),
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
        onPressed: () async {
          if (savedPersonId) {
            if ("${_firstNameController.text} ${_lastNameController.text}"
                .trim()
                .isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(milliseconds: 1000),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  content: const Text('الرجاء إدخال الاسم',
                      style: TextStyle(fontSize: 15))));
              return;
            } else {
              // check if id number is unique
              if (_idNumberController.text.isNotEmpty &&
                  box.values
                      .toList()
                      .map((element) => element.idNumber)
                      .toList()
                      .contains(_idNumberController.text.trim()) &&
                  box.values
                          .toList()
                          .map((element) => element.idNumber)
                          .toList()
                          .indexOf(_idNumberController.text.trim()) !=
                      selectedIdProvider.selectedId) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(milliseconds: 1000),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    content: const Text(
                        'رقم الهوية موجود بالفعل في قاعدة البيانات',
                        style: TextStyle(fontSize: 15))));
                return;
              }
            }

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
                    aidAmount: _amountController.text.isNotEmpty
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
            if ("${_firstNameController.text} ${_lastNameController.text}"
                .trim()
                .isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(milliseconds: 1000),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  content: const Text('الرجاء إدخال الاسم',
                      style: TextStyle(fontSize: 15))));
              return;
            } else {
              // check if id number is unique
              if (_idNumberController.text.isNotEmpty &&
                  box.values
                      .toList()
                      .map((element) => element.idNumber)
                      .toList()
                      .contains(_idNumberController.text.trim())) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(milliseconds: 1000),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    content: const Text(
                        'رقم الهوية موجود بالفعل في قاعدة البيانات',
                        style: TextStyle(fontSize: 15))));
                return;
              }
            }

            hiveProvider.createItem(Person(
                name:
                    "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
                idNumber: _idNumberController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                aidDates: dateRange,
                aidType: aidType == aidTypes.last
                    ? _typeController.text.trim()
                    : (aidType ?? aidTypes[5]),
                aidAmount: _amountController.text.trim().isNotEmpty
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

class DividerWithTitle extends StatelessWidget {
  final String title;
  const DividerWithTitle(
    this.title, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.only(right: 8, left: 8),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      const Expanded(child: Divider()),
    ]);
  }
}
