class ExtraDataModel {
  int? id ;
  String Extramedicinename ;
  String ExtraEattime ;
  String ExtraBuyplace;
  String ExtraMedremark ;

  //String subtitle;
  ExtraDataModel({this.id, required this.Extramedicinename, required this.ExtraEattime, required this.ExtraBuyplace,required this.ExtraMedremark});

  factory ExtraDataModel.fromMap(Map<String, dynamic> json) => ExtraDataModel(
      id: json['id'], Extramedicinename: json["Extramedicinename"], ExtraEattime: json["ExtraEattime"], ExtraBuyplace: json["ExtraBuyplace"],ExtraMedremark: json["ExtraMedremark"]);

  Map<String, dynamic> toMap() => {
    "id": id,
    "Extramedicinename": Extramedicinename,
    "ExtraEattime": ExtraEattime,
    "ExtraBuyplace": ExtraBuyplace,
    "ExtraMedremark": ExtraMedremark
  };
}