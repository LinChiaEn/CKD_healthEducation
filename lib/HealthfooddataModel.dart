class HealthfoodDataModel {
  int? id ;
  String Healthfoodname ;
  String HealthfoodEattime ;
  String HealthfoodBuyplace;
  String Healthfoodremark ;

  //String subtitle;
  HealthfoodDataModel({this.id, required this.Healthfoodname, required this.HealthfoodEattime, required this.HealthfoodBuyplace,required this.Healthfoodremark});

  factory HealthfoodDataModel.fromMap(Map<String, dynamic> json) => HealthfoodDataModel(
      id: json['id'], Healthfoodname: json["Healthfoodname"], HealthfoodEattime: json["HealthfoodEattime"], HealthfoodBuyplace: json["HealthfoodBuyplace"],Healthfoodremark: json["Healthfoodremark"]);

  Map<String, dynamic> toMap() => {
    "id": id,
    "Healthfoodname": Healthfoodname,
    "HealthfoodEattime": HealthfoodEattime,
    "HealthfoodBuyplace": HealthfoodBuyplace,
    "Healthfoodremark": Healthfoodremark
  };
}