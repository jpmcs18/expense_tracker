class Item {
  static const tblName = 'Item';
  static const colId = 'id';
  static const colDescription = 'description';

  int id;
  String description;
  Item(this.description);
  
  Item.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    description = map[colDescription];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colDescription: description,
    };
    if (id != null) map[colId] = id;
    return map;
  }
}
