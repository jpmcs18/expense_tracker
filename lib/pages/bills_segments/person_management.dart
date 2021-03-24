import 'package:flutter/material.dart';

class PersonManagement extends StatefulWidget {
  @override
  _PersonManagementState createState() => _PersonManagementState();
}

class _PersonManagementState extends State<PersonManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Persons')),
            IconButton(icon: Icon(Icons.add), onPressed: _addNewItem),
          ],
        ),
      ),
      // body: ListView.builder(
      //   itemCount: _itemTypes.length,
      //   itemBuilder: (context, index) {
      //     return CustomDismissible(
      //         isTop: index == 0,
      //         isBottom: index == _itemTypes.length - 1,
      //         id: _itemTypes[index].id.toString(),
      //         child: ListTile(
      //           title: Container(
      //               child: Row(
      //             children: [
      //               Expanded(
      //                   child: Text(_itemTypes[index].description ?? "",
      //                       style: cardTitleStyle2))
      //             ],
      //           )),
      //           subtitle: Text(_itemTypes[index].createdOn.formatLocalize()),
      //         ),
      //         onDelete: () async {
      //           return await _deleteItemType(_itemTypes[index]) ?? false;
      //         },
      //         onEdit: () async {
      //           setState(() {
      //             _selectedItemType = _itemTypes[index];
      //           });
      //           _manageItemType();
      //           return false;
      //         });
      //   },
      // ),
    );
  }

  void _addNewItem() {
  }
}
