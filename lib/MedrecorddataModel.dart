class DataModel {
  int? id ;
  String Medicinename ;
  String Eattime ;
  String Medremark ;
  //String title;
  //String subtitle;
  DataModel({this.id, required this.Medicinename, required this.Eattime, required this.Medremark});

  factory DataModel.fromMap(Map<String, dynamic> json) => DataModel(
      id: json['id'], Medicinename: json["Medicinename"], Eattime: json["Eattime"], Medremark: json["Medremark"]);

  Map<String, dynamic> toMap() => {
    "id": id,
    "Medicinename": Medicinename,
    "Eattime": Eattime,
    "Medremark": Medremark
  };
}