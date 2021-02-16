class ItemType {
  static const tblName = 'item_type';
  static const colId = 'id';
  static const colDescription = 'description';

  int id;
  String description;

  ItemType() {
    id = null;
    description = '';
  }

  ItemType.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    description = map[colDescription];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colDescription: description
    };
    if (id != null) map[colId] = id;
    return map;
  }
}
