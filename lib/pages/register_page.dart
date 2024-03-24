import 'package:aidapp/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/core.dart';
import '../main.dart';
import '../person.dart';

// ignore: must_be_immutable
class RegisterPage extends StatefulWidget {
  int? id;
  RegisterPage({super.key, this.id});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _hijriDateController = TextEditingController();

  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _typeDetailsController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  String description = '';

  final box = Hive.box<Person>('personList');

  AidDuration? _duration = AidDuration.continuous;

  String? aidType = aidTypes[7];

  List<DateTime> dateRange = [];

  // make a focusnode for every field
  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode idNumberFocus = FocusNode();
  FocusNode amountFocus = FocusNode();
  FocusNode typeFocus = FocusNode();
  FocusNode dateFocus = FocusNode();
  FocusNode hijriDateFocus = FocusNode();
  FocusNode otherTypeFocus = FocusNode();
  FocusNode typeDetailsFocus = FocusNode();
  FocusNode firstDurationFocus = FocusNode();
  FocusNode lastDurationFocus = FocusNode();
  FocusNode notesFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    Person? loadPerson = widget.id != null ? box.getAt(widget.id!) : null;
    loadData(loadPerson);

    // Add listeners to the focus nodes
    firstNameFocus.addListener(() {
      if (!firstNameFocus.hasFocus) {
        _firstNameController.text = _firstNameController.text.trim();
      }
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    phoneFocus.dispose();
    idNumberFocus.dispose();
    amountFocus.dispose();
    typeFocus.dispose();
    dateFocus.dispose();
    hijriDateFocus.dispose();
    typeDetailsFocus.dispose();
    firstDurationFocus.dispose();
    lastDurationFocus.dispose();
    otherTypeFocus.dispose();
    notesFocus.dispose();

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
      _dateController.text =
          "${intl.DateFormat('yyyy-MM-dd').format(dateRange[0])} - ${intl.DateFormat('yyyy-MM-dd').format(dateRange[1])}";
      _hijriDateController.text =
          "${HijriDateTime.fromDateTime(dateRange[0]).toString().replaceAll('-', '/')} - ${HijriDateTime.fromDateTime(dateRange[1]).toString().replaceAll('-', '/')}";
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

  // getDateRange from controllers
  List<DateTime> getDateRange() {
    List<DateTime> dateRange = [];
    if (_dateController.text.isNotEmpty) {
      List<String> dates = _dateController.text.split(" - ");
      dateRange.add(intl.DateFormat('yyyy-MM-dd').parse(dates[0]));
      dateRange.add(intl.DateFormat('yyyy-MM-dd').parse(dates[1]));
    }
    return dateRange;
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

    bool savedPersonId = id != null;
    Person? loadPerson = savedPersonId ? box.getAt(id) : null;
    return Scaffold(
        appBar: AppBar(
            title:
                Text(savedPersonId ? "تعديل المساعدة" : "إنشاء مساعدة جديدة"),
            centerTitle: true,
            actions: [
              IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    if (savedPersonId) {
                      hiveProvider.updateItem(
                          id,
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
                              aidTypeDetails:
                                  aidType == 'عينية' || aidType == 'رمضانية'
                                      ? _typeDetailsController.text
                                      : 'غير مسجل',
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
                          phoneNumber: _phoneController.text.trim(),
                          aidDates: getDateRange(),
                          aidType: aidType == aidTypes.last
                              ? _typeController.text.trim()
                              : (aidType ?? aidTypes[5]),
                          aidAmount: aidType != 'عينية' &&
                                  aidType != 'رمضانية' &&
                                  _amountController.text.trim().isNotEmpty
                              ? double.parse(_amountController.text.trim())
                              : 0.0,
                          aidTypeDetails:
                              aidType == 'عينية' || aidType == 'رمضانية'
                                  ? _typeDetailsController.text
                                  : 'غير مسجل',
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(children: [
            // const SizedBox(height: 15),
            textFieldListTile('الاسم الأول', _firstNameController,
                firstNameFocus, lastNameFocus),
            const SizedBox(height: 2),
            textFieldListTile('الاسم الأخير', _lastNameController,
                lastNameFocus, idNumberFocus),
            // const SizedBox(height: 2),
            ListTile(
              title: TextFormField(
                focusNode: idNumberFocus,
                onFieldSubmitted: (value) {
                  idNumberFocus.unfocus();
                  FocusScope.of(context).requestFocus(phoneFocus);
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
            // const SizedBox(height: 2),
            ListTile(
              title: TextFormField(
                focusNode: phoneFocus,
                onFieldSubmitted: (value) {
                  phoneFocus.unfocus();
                  FocusScope.of(context).requestFocus(dateFocus);
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

            ListTile(
              trailing: IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
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
                                    initialSelectedRange: dateRange.isNotEmpty
                                        ? PickerDateRange(
                                            dateRange[0], dateRange[1])
                                        : null,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    startRangeSelectionColor:
                                        Theme.of(context).colorScheme.primary,
                                    endRangeSelectionColor:
                                        Theme.of(context).colorScheme.primary,
                                    rangeSelectionColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withOpacity(0.2),
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
                                        // check if the end date is null
                                        if (value.endDate != null) {
                                          dateRange.add(value.endDate!);
                                        } else {
                                          dateRange.add(value.startDate!
                                              .add(const Duration(days: 10)));
                                        }

                                        setState(() {});

                                        _dateController.text =
                                            "${intl.DateFormat('yyyy-MM-dd').format(dateRange[0])} - ${intl.DateFormat('yyyy-MM-dd').format(dateRange[1])}";
                                        _hijriDateController.text =
                                            "${HijriDateTime.fromDateTime(dateRange[0]).toString().replaceAll('-', '/')} - ${HijriDateTime.fromDateTime(dateRange[1]).toString().replaceAll('-', '/')}";
                                        Navigator.pop(context);
                                      }
                                    },
                                    showActionButtons: true),
                              ),
                            ),
                          ));
                },
              ),
              title: TextFormField(
                focusNode: dateFocus,
                decoration: const InputDecoration(
                    label: Text("تاريخ (ميلادي)"),
                    border: OutlineInputBorder(),
                    isDense: true),
                controller: _dateController,
                onFieldSubmitted: (value) {
                  dateFocus.unfocus();
                  FocusScope.of(context).requestFocus(hijriDateFocus);
                },
              ),
            ),
            const SizedBox(height: 5),
            ListTile(
              trailing: IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
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
                                    initialSelectedRange: dateRange.isNotEmpty
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
                                        Theme.of(context).colorScheme.primary,
                                    endRangeSelectionColor:
                                        Theme.of(context).colorScheme.primary,
                                    rangeSelectionColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withOpacity(0.2),
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
                                        _dateController.text =
                                            "${intl.DateFormat('yyyy-MM-dd').format(dateRange[0])} - ${intl.DateFormat('yyyy-MM-dd').format(dateRange[1])}";
                                        _hijriDateController.text =
                                            "${HijriDateTime.fromDateTime(dateRange[0]).toString().replaceAll('-', '/')} - ${HijriDateTime.fromDateTime(dateRange[1]).toString().replaceAll('-', '/')}";
                                        Navigator.pop(context);
                                      }
                                    },
                                    showActionButtons: true),
                              ),
                            ),
                          ));
                },
              ),
              title: TextFormField(
                focusNode: hijriDateFocus,
                decoration: const InputDecoration(
                    label: Text("تاريخ (هجري)"),
                    border: OutlineInputBorder(),
                    isDense: true),
                controller: _hijriDateController,
                onFieldSubmitted: (value) {
                  hijriDateFocus.unfocus();
                  FocusScope.of(context).requestFocus(typeFocus);
                },
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 24, right: 16),
              child: DropdownButtonFormField(
                focusNode: typeFocus,
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
                    typeFocus.unfocus();
                    FocusScope.of(context).requestFocus(otherTypeFocus);
                  } else if (aidType == 'عينية' || aidType == 'رمضانية') {
                    typeFocus.unfocus();
                    FocusScope.of(context).requestFocus(typeDetailsFocus);
                  } else {
                    typeFocus.unfocus();
                    FocusScope.of(context).requestFocus(amountFocus);
                  }
                },
                onTap: () {
                  if (aidType == aidTypes.last) {
                    typeFocus.unfocus();
                    FocusScope.of(context).requestFocus(otherTypeFocus);
                  } else if (aidType == 'عينية' || aidType == 'رمضانية') {
                    typeFocus.unfocus();
                    FocusScope.of(context).requestFocus(typeDetailsFocus);
                  } else {
                    typeFocus.unfocus();
                    FocusScope.of(context).requestFocus(amountFocus);
                  }
                },
              ),
            ),
            const SizedBox(height: 2),
            Visibility(
              visible: aidType == aidTypes.last,
              child: ListTile(
                title: TextFormField(
                  focusNode: otherTypeFocus,
                  onFieldSubmitted: (value) {
                    otherTypeFocus.unfocus();
                    FocusScope.of(context).requestFocus(firstDurationFocus);
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
                  focusNode: typeDetailsFocus,
                  onFieldSubmitted: (value) {
                    typeDetailsFocus.unfocus();
                    FocusScope.of(context).requestFocus(amountFocus);
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
            const SizedBox(height: 15),
            Visibility(
              visible: aidType != 'عينية' && aidType != 'رمضانية',
              child: ListTile(
                title: TextFormField(
                  focusNode: amountFocus,
                  onFieldSubmitted: (value) {
                    amountFocus.unfocus();
                    FocusScope.of(context).requestFocus(firstDurationFocus);
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
            const SizedBox(height: 12),
            const Center(
                child: Text("مدة المساعدة",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            RadioListTile<AidDuration>(
              focusNode: firstDurationFocus,
              onFocusChange: (value) {
                if (!value) {
                  firstDurationFocus.unfocus();
                  FocusScope.of(context).requestFocus(lastDurationFocus);
                }
              },
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
              focusNode: lastDurationFocus,
              onFocusChange: (value) {
                if (!value) {
                  lastDurationFocus.unfocus();
                  FocusScope.of(context).requestFocus(notesFocus);
                }
              },
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
                focusNode: notesFocus,
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

  ListTile textFieldListTile(String label, TextEditingController controller,
      FocusNode focusNode, FocusNode nextFocusNode) {
    return ListTile(
      title: TextFormField(
        autofocus: true,
        focusNode: focusNode,
        onFieldSubmitted: (value) {
          focusNode.unfocus();
          FocusScope.of(context).requestFocus(nextFocusNode);
        },
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
            suffixIcon: clearButton(controller),
            label: Text(label),
            border: const OutlineInputBorder(),
            isDense: true),
        controller: controller,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
