import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:json_to_form_with_theme/exceptions/parsing_exception.dart';
import 'package:json_to_form_with_theme/json_to_form_with_theme.dart';
import 'package:json_to_form_with_theme/parsers/widget_parser.dart';
import 'package:json_to_form_with_theme/parsers/widget_parser_factory.dart';
import 'package:json_to_form_with_theme/themes/inherited_json_form_theme.dart';
import 'package:json_to_form_with_theme/widgets/line_wrapper.dart';
import 'package:json_to_form_with_theme/widgets/name_description_widget.dart';
class DropDownWidget2 extends StatefulWidget {
  DropDownWidget2(
      {Key key,
         this.name,
         this.id,
         this.values,
         this.description,
         this.onValueChanged,
        this.chosenValue,
        this.dateBuilder,
        this.time,
         this.isBeforeHeader})
      : super(key: key);

  final String name;
  final String description;
  final String id;
  final List<String> values;
  String chosenValue;
  final OnValueChanged onValueChanged;
  final bool isBeforeHeader;
  final Widget Function(int date, String id) dateBuilder;
  int time;

  @override
  State<DropDownWidget2> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<DropDownWidget2> {
  String dropdownValue;

  @override
  void initState() {
    dropdownValue = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dropdownValue ??= widget.chosenValue;
    return LineWrapper(
      isBeforeHeader: widget.isBeforeHeader,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: TextDirection.ltr,
          children: <Widget>[
            NameWidgetDescription(width: InheritedJsonFormTheme.of(context).theme.dropDownWidthOfHeader, id: widget.id,
                name: widget.name, description: widget.description,    dateBuilder: widget.dateBuilder,
                time: widget.time),
            Container(
              alignment: Alignment.center,
              child: DropdownButton<String>(
                dropdownColor: const Color(0xff222222),
                value: dropdownValue,
                icon: InheritedJsonFormTheme.of(context).theme.dropDownIcon !=
                    null
                    ? InheritedJsonFormTheme.of(context).theme.dropDownIcon
                    : const Icon(
                  Icons.arrow_drop_down_sharp,
                  color: Colors.white,
                ),
                iconSize: 24,
                underline: InheritedJsonFormTheme.of(context)
                    .theme
                    .underLineWidget !=
                    null
                    ? InheritedJsonFormTheme.of(context).theme.underLineWidget
                    : Container(
                  height: 2,
                ),
                style: const TextStyle(
                  color: Color(0xff8A8B8F),
                  fontSize: 16,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue = newValue;
                    if(widget.onValueChanged!= null) {
                      widget.onValueChanged(widget.id, dropdownValue);
                    }
                  });
                },
                selectedItemBuilder: (BuildContext context) {
                  return widget.values.map((String value) {
                    return Center(
                      child: Text(
                        dropdownValue,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList();
                },
                items:
                widget.values.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            )
          ]),
    );
  }
}
class DropDownParser2 implements WidgetParser {
  DropDownParser2(
      this.name,
      this.description,
      this.id,
      this.chosenValue,
      this.values,
      this.onValueChanged,
      this.isBeforeHeader,
      this.index,
      this.dateBuilder) {
    onValueChangedLocal = (String id, dynamic value) async{
      chosenValue = value;
      if (onValueChanged != null) {
        return await onValueChanged(id, value);
      }
      return Future.value(true);
    };
  }

  final OnValueChanged onValueChanged;
  final bool isBeforeHeader;
  final String description;
  final String name;
  final String id;
  final List<String> values;
  OnValueChanged onValueChangedLocal;
  final Widget Function(int date, String id) dateBuilder;
  int time;

  DropDownParser2.fromJson(Map<String, dynamic> json, this.onValueChanged,
      this.isBeforeHeader, this.index,
      [this.dateBuilder])
      : name = json['name'],
        description = json['description'],
        id = json['id'],
        time = json['time'],
        values = json['values'].cast<String>(),
        chosenValue = json['chosen_value'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'id': id,
    'time': time,
    'values': values,
    'chosen_value': chosenValue,
  };

  Widget getWidget(bool refresh) {
    return DropDownWidget2(
        key: ValueKey(chosenValue),
        name: name,
        id: id,
        values: values,
        description: description,
        chosenValue: chosenValue,
        dateBuilder: dateBuilder,
        time: time,
        isBeforeHeader: isBeforeHeader,
        onValueChanged: onValueChanged);
  }

  @override
  dynamic chosenValue;

  @override
  set id(String _id) {
    // TODO: implement id
  }

  @override
  int index;

  @override
  setChosenValue(value) {
    // TODO: implement setChosenValue
    chosenValue = value ?? "";
  }

}
class MyWidgetParserFactory implements WidgetParserFactory{
  @override
  WidgetParser getWidgetParser(
      String type,
      int index,
      Map<String, dynamic> widgetJson,
      bool isBeforeHeader,
      OnValueChanged onValueChanged,
      Widget Function(int date, String id) dateBuilder) {
    switch (type) {
      case "drop_down2":
        try {
          return DropDownParser2.fromJson(
              widgetJson, onValueChanged, isBeforeHeader, index, dateBuilder);
        } catch (e) {
          throw const ParsingException("Bad drop_down2 format");
        }
    }
    return null;
  }
}
