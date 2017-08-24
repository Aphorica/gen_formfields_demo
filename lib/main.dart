import 'dart:async';

import 'package:flutter/material.dart';
import 'package:form_fields/form_fields.dart';


void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'General FormFields Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new DemoPage(title: 'General FormFields Demo'),
    );
  }
}

class DemoPage extends StatefulWidget {
  DemoPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _DemoPageState createState() => new _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  ScrollController formScrollController = new ScrollController();


  // persister instance lives at this level
  //
  FormFieldStatePersister fieldStatePersister;

  bool _autovalidate = false;
  bool _formWasEdited = false;

  void _update() {
    setState(() {
    });
  }

  _DemoPageState() : super() {
    fieldStatePersister = new FormFieldStatePersister(_update);
    fieldStatePersister.addSimplePersister('Check_1', true, FormFieldStatePersister.checkboxPersisterToString);
    fieldStatePersister.addSimplePersister('Check_2', false, FormFieldStatePersister.checkboxPersisterToString);
    fieldStatePersister.addSimplePersister('Check_3', false, FormFieldStatePersister.checkboxPersisterToString);
    fieldStatePersister.addSimplePersister('Check_4', false, FormFieldStatePersister.checkboxPersisterToString);
    fieldStatePersister.addSimplePersister('Switch_1', true, FormFieldStatePersister.switchPersisterToString);
    fieldStatePersister.addSimplePersister('Switch_2', false, FormFieldStatePersister.switchPersisterToString);
    fieldStatePersister.addSimplePersister('Switch_3', false, FormFieldStatePersister.switchPersisterToString);
  }

  @override
  Widget build(BuildContext context) {
    CheckboxListTileFormField check_1 = new CheckboxListTileFormField(
      persister: fieldStatePersister['Check_1'].persister,
      title: new Text('Check 1 (True - trailing)'),
      controlAffinity: ListTileControlAffinity.trailing
    );

    CheckboxListTileFormField check_2 = new CheckboxListTileFormField(
      persister: fieldStatePersister['Check_2'].persister,
      title: new Text('Check 2 (False - leading)'),
      controlAffinity: ListTileControlAffinity.leading
    );

    CheckboxListTileFormField check_3 = new CheckboxListTileFormField(
      persister: fieldStatePersister['Check_3'].persister,
      title: new Text('Check 3 (True - platform)'),
      controlAffinity: ListTileControlAffinity.platform
    );


    CheckboxListTileFormField check_4 = new CheckboxListTileFormField(
      persister: fieldStatePersister['Check_4'].persister,
      title: new Text('Check 4 (False - Three line)'),
      subtitle: new Text('Some more info\nhere'),
      isThreeLine: true,
    );

    SwitchListTileFormField switch_1 = new SwitchListTileFormField(
      persister: fieldStatePersister['Switch_1'].persister,
      title: new Text('Switch 1 (On)'),
    );

    SwitchListTileFormField switch_2 = new SwitchListTileFormField(
      persister: fieldStatePersister['Switch_2'].persister,
      title: new Text('Switch 2 (Off)')
    );

    SwitchListTileFormField switch_3 = new SwitchListTileFormField(
      persister: fieldStatePersister['Switch_3'].persister,
      title: new Text('Switch 3 (Off - Three line)'),
      subtitle: new Text('Some more info\nhere'),
      isThreeLine: true,
    );

    ListView formListView = new ListView(
    controller: formScrollController,
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    children: <Widget>[ check_1, check_2, check_3, check_4,
                        new Divider(),
                        switch_1, switch_2, switch_3]);

    Form form = new Form(
      key: _formKey,
      autovalidate: _autovalidate,
      onWillPop: _warnUserAboutInvalidData,
      child: formListView);


    Container submitRow = new Container(
      alignment: FractionalOffset.center,
      padding: const EdgeInsets.only(
        top: 10.0, left: 20.0, right: 20.0, bottom: 20.0 ),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          new RaisedButton(
            child: const Text('RESET'),
            onPressed: _reset
          ),
          new Container(width: 10.0),
          new RaisedButton(
            child: const Text('SUBMIT'),
            onPressed:() { _handleSubmitted(fieldStatePersister); },
          )
        ]
      )
    );

    Column mainColumn = new Column(
      children: <Widget>[
        new Flexible(flex:10, child: form),
        new Flexible(flex:1, child: submitRow)
      ]
    );

    Scaffold scaffold = new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(title: const Text('Checkboxes and switches')),
      body: mainColumn);

    return scaffold;
  }

//////////////////////////////////////////////////////////////////////////////
// end form
// beg support funcs
//////////////////////////////////////////////////////////////////////////////
  Future<bool> _warnUserAboutInvalidData() async {
    final FormState form = _formKey.currentState;
    if (form == null || !_formWasEdited || form.validate()) return true;

    return await showDialog<bool>(
      context: context,
      child: new AlertDialog(
        title: const Text('This form has errors'),
        content: const Text('Really leave this form?'),
        actions: <Widget>[
          new FlatButton(
            child: const Text('YES'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          new FlatButton(
            child: const Text('NO'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    ) ??
      false;
  }

  void _reset() {
    fieldStatePersister.resetToInitialValues();
    _update();
    new Future.delayed(new Duration(milliseconds:50)).then((dynamic a) {
      _formKey.currentState.reset();
    });
  }

  void _handleSubmitted(FormFieldStatePersister fieldStatePersister) {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
      _update();
    } else {
      showInSnackBar('Check 1 is ${fieldStatePersister['Check_1']}\n'
                     'Check 2 is ${fieldStatePersister['Check_2']}\n'
                     'Check 3 is ${fieldStatePersister['Check_3']}\n'
                     'Check 4 is ${fieldStatePersister['Check_4']}\n'
                     'Switch 1 is ${fieldStatePersister['Switch_1']}\n'
                     'Switch 2 is ${fieldStatePersister['Switch_2']}\n'
                     'Switch 3 is ${fieldStatePersister['Switch_3']}\n'
      );
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
      .showSnackBar(new SnackBar(content:
                      new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new IconButton(
                                icon: new Icon(Icons.close, size: 12.0),
                                onPressed: () { _scaffoldKey.currentState.hideCurrentSnackBar(); }
                              )
                            ]
                          ),
                          new Text(value)
                        ]
                      ),
                    duration: new Duration(seconds: 10),
                  ));
  }
}
