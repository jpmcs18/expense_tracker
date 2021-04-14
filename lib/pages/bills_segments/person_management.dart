import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/bills/person_manager.dart';
import 'package:expense_management/modals/delete_record.dart';
import 'package:expense_management/models/bills/person.dart';
import 'package:expense_management/pages/components/custom_dismissible.dart';
import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';

class PersonManagement extends StatefulWidget {
  @override
  PersonManagementState createState() => PersonManagementState();
}

class PersonManagementState extends State<PersonManagement> {
  MainDB db = MainDB.instance;
  List<Person> _persons = [];
  Person _selectedPerson = Person();

  @override
  void initState() {
    super.initState();
    _getPersons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Persons')),
            IconButton(icon: Icon(Icons.add), onPressed: _addNewPerson),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _persons.length,
        itemBuilder: (context, index) {
          return CustomDismissible(
              isTop: index == 0,
              isBottom: index == _persons.length - 1,
              id: _persons[index].id.toString(),
              child: ListTile(
                title: Container(
                    child: Row(
                  children: [
                    Expanded(
                        child: Text(_persons[index].name ?? "",
                            style: cardTitleStyle2))
                  ],
                )),
                subtitle: Text(_persons[index].createdOn.formatLocalize()),
              ),
              onDelete: () async {
                return await _deletePerson(_persons[index]) ?? false;
              },
              onEdit: () async {
                setState(() {
                  _selectedPerson = _persons[index];
                });
                _managePerson();
                return false;
              });
        },
      ),
    );
  }

  Future<bool?> _deletePerson(Person obj) async {
    if (obj.reference > 0) {
      Fluttertoast.showToast(msg: "Unable to delete ${obj.name}");
      return false;
    }
    if ((await showDeleteRecordManager(
            context, "Deleting", "Do you want to delete ${obj.name}?")) ??
        false) {
      if ((await db.deletePerson(obj.id ?? 0)) > 0) {
        await _getPersons();
        return true;
      }
    }
    return false;
  }

  _addNewPerson() {
    setState(() {
      _selectedPerson = Person();
    });
    _managePerson();
  }

  _managePerson() async {
    if ((await showPersonManager(context, _selectedPerson)) ?? false)
      _getPersons();
  }

  _getPersons() async {
    var persons = await db.getPersons();
    if (this.mounted) {
      setState(() {
        _persons = persons;
      });
    }
  }
}
