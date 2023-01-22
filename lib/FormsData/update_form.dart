import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:webviewjavascript/FormsData/read_file.dart';

import 'open_database.dart';

var updateValues = [];
var updateStatus = false;

class UpdateForm extends StatefulWidget {
  var row;
  UpdateForm({Key key, this.row}) : super(key: key);

  @override
  State<UpdateForm> createState() => _UpdateFormState();
}

class _UpdateFormState extends State<UpdateForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  var textFieldController = List();

  @override
  void initState() {
    for (int i = 0; i < tableNamesFromDb.length; i++) {
      textFieldController.add(TextEditingController(
          text: '${widget.row[tableNamesFromDb[i]['name']]}'));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Update Data'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$databaseName',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FormBuilder(
                    // enabled: tableNamesFromDb[0]['name'] != 'fid' ? true: false,
                    key: _formKey,
                    // autovalidate: true,
                    child: Column(
                      children: <Widget>[
                        for (int i = 0; i < tableNamesFromDb.length; i++)
                          Column(
                            children: [
                              getTextFieldForm(
                                  i,
                                  tableNamesFromDb[i]['name'] != 'fid'
                                      ? true
                                      : false),
                              // FormBuilderTextField(
                              //   controller: textFieldController[i],
                              //   name: '${tableNamesFromDb[i]['name']}',
                              //   decoration: InputDecoration(
                              //     isDense: true,
                              //     contentPadding:
                              //     const EdgeInsets.all(14),
                              //     border: const OutlineInputBorder(),
                              //     labelText:
                              //     '${tableNamesFromDb[i]['name']}',
                              //   ),
                              //   // onChanged: _onChanged,
                              //   // valueTransformer: (text) => num.tryParse(text),
                              //   validator: FormBuilderValidators.compose([
                              //     FormBuilderValidators.required(context),
                              //   ]),
                              //   keyboardType: TextInputType.text,
                              // ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      // Expanded(
                      //   child: MaterialButton(
                      //     color: Colors.grey,
                      //     child: Text(
                      //       "Cancel",
                      //       style: TextStyle(color: Colors.white),
                      //     ),
                      //     onPressed: () {
                      //       setState(() {
                      //         selectCheckBox = false;
                      //         buttonNameCancel = 'Filter Table';
                      //       });
                      //       Navigator.pop(context);
                      //       // _formKey.currentState.reset();
                      //     },
                      //   ),
                      // ),
                      // SizedBox(width: 20),
                      Expanded(
                        child: MaterialButton(
                          color: Theme.of(context).colorScheme.secondary,
                          child: Text(
                            "Update",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            _formKey.currentState.save();
                            if (_formKey.currentState.validate()) {
                              for (int i = 0;
                                  i < tableNamesFromDb.length;
                                  i++) {
                                updateValues.add(
                                  {
                                    'columnName': tableNamesFromDb[i]['name'],
                                    'updateValue': _formKey.currentState.fields['${tableNamesFromDb[i]['name']}'].value
                                  },
                                );
                              }

                              getList = [];

                              await DictionaryDataBaseHelper().init();

                              updateStatus = true;

                              setState(() {});

                              Navigator.pushReplacement(context, MaterialPageRoute(
                                  builder: (context) => ReadFile(tableName: databaseName, file: globalTableName,)
                              ),);

                              // if(getList.isNotEmpty){
                              //   Navigator.pop(context);
                              // }
                              // else{
                              //   print('get list is not ready yet');
                              // }

                              // print(_formKey.currentState.value);
                              // print(_formKey.currentState.fields['fid'].value);
                            } else {
                              print("validation failed");
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  getTextFieldForm(index, enabled) => FormBuilderTextField(
        enabled: enabled,
        controller: textFieldController[index],
        name: '${tableNamesFromDb[index]['name']}',
        style: TextStyle(color: enabled ? Colors.black : Colors.grey),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(14),
          border: const OutlineInputBorder(),
          labelText: '${tableNamesFromDb[index]['name']}',
        ),
        // onChanged: _onChanged,
        // valueTransformer: (text) => num.tryParse(text),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(context),
        ]),
        keyboardType: TextInputType.text,
      );
}
