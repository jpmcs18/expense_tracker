import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/models/bills/person.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/modals/modal_base.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool?> showPersonManager(context, person) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return PersonManager(person);
    },
  );
}

class PersonManager extends StatefulWidget {
  final Person person;

  const PersonManager(this.person);

  @override
  State<StatefulWidget> createState() {
    return PersonManagerState();
  }
}

class PersonManagerState extends State<PersonManager> {
  final MainDB db = MainDB.instance;

  Person _person = Person();

  final _ctrlPersonDesc = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _person = widget.person;
      _ctrlPersonDesc.text = _person.name ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return generateModalBody(
        TextField(
          controller: _ctrlPersonDesc,
          decoration: InputDecoration(labelText: 'Name'),
          onChanged: (value) {
            setState(() {
              _person.name = value;
            });
          },
        ),
        [
          Expanded(child: TextButton(onPressed: _cancel, child: Text('Cancel'))),
          VerticalDivider(thickness: 1.5, indent: 7, endIndent: 7,),
          Expanded(
            child: TextButton(
                onPressed: _savePerson,
                child: Text(_person.id == null ? 'Insert' : 'Update')),
          )
        ],
        header: "Manage Person");
  }

  _cancel() {
    setState(() {
      _person = Person();
      _ctrlPersonDesc.clear();
    });
    Navigator.of(context).pop(false);
  }

  _savePerson() async {
    try {
      if (_person.id == null)
        await db.insertPerson(_person);
      else
        await db.updatePerson(_person);
      setState(() {
        _person = Person();
        _ctrlPersonDesc.clear();
      });
      Navigator.of(context).pop(true);
    } catch (_) {
      Fluttertoast.showToast(
          msg:
              "Unable to ${_person.id == null ? 'insert' : 'update'} person");
    }
  }
}
