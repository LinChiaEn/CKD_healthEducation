import 'dart:io';
import 'package:flutter/services.dart';

import 'bloodpressurealarmpage.dart';
import 'glucosealarmpage.dart';
import 'socket_tts.dart';
import 'sound_player.dart';
import 'sound_recorder.dart';
import 'flutter_tts.dart';
import 'calendar2.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'socket_stt.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:io';
import 'package:Finalproject/Healthfood&Extramedicine.dart';
import 'db_test.dart';
import 'package:Finalproject/Medicinerecord.dart';
import 'profile_db.dart';
import 'bloodpressure_db.dart';
import 'glucose_db.dart';

import 'package:rxdart/rxdart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Finalproject/flutter_tts.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
 final onNotifications = BehaviorSubject<String?>();
//--------profile-----------------------
String name = "";
String age = "";
String hospital = "";
String phone = "";
String thing = "";
//---------bloodpressure---------------------
String daySBP = "尚未填寫";
String dayDBP = "尚未填寫";
String nightSBP = "尚未填寫";
String nightDBP = "尚未填寫";
String dayORnight = "day";
int checkDaySBP = 0;
int checkDayDBP = 0;
int checkNightSBP = 0;
int checkNightDBP = 0;
//---------glucose------------------------------
String before1 = "尚未填寫";
String after1 = "尚未填寫";
String before2 = "尚未填寫";
String after2 = "尚未填寫";
String before3 = "尚未填寫";
String after3 = "尚未填寫";
int glucoseTime = 1;
int checkBefore1 = 0;
int checkAfter1 = 0;
int checkBefore2 = 0;
int checkAfter2 = 0;
int checkBefore3 = 0;
int checkAfter3 = 0;

//----------------------------------------
List<int> bpWeekNumList = [];
List<int> bpWeekTimeList = [];
List<String> bpWeekLineList = [];

List<int> bpMonthNumList = [];
List<int> bpMonthTimeList = [];
List<String> bpMonthLineList = [];

//--------------------------------------
List<int> gpWeekNumList = [];
List<int> gpWeekTimeList = [];
List<String> gpWeekLineList = [];

List<int> gpMonthNumList = [];
List<int> gpMonthTimeList = [];
List<String> gpMonthLineList = [];
//----藥品搜尋-----------------------------------
List<String> listName = [];
List<String> listNameEng = [];
List<String> listIndication = [];
List<String> listIngredient = [];

List<String> nameCh = [];
List<String> nameEng = [];
List<String> ingredient = [];
List<String> indication = [];
//------------------------------------------
bool disease1 = false;
bool disease2 = false;
//------------------------------------
String Language = '中文';
String sex = 'female';

List<String> SBPList = [];
List<String> DBPList = [];
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  var initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int? id, String? title, String? body, String? payload) async {});
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  //When app is closed
  var details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (details!=null&&details.didNotificationLaunchApp){
   // onNotifications.add(details.payload);
    debugPrint('notification payload: ' + details.payload!);
  }
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {
         // onNotifications.add(payload);
          debugPrint('notification payload: ' + payload);
        }
      });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Health Care",
      initialRoute: '/',
      routes: {
        '/': (context) => Calendar2(),
        '/profile': (context) => ProfileInPage(),
        '/bloodpressure': (context) => PressureInPage(),
        '/nightbloodpressure': (context) => NightPressureInPage(),
        '/bloodpressuretest': (context) => RecordPressureInPage(),
        '/bloodpressurechart': (context) => RecordPressureChartInPage(),
        '/glucosetest': (context) => RecordGlucoseInPage(),
        '/glucosechart': (context) => RecordGlucoseChartInPage(),
        '/medicinerecord': (context) => MedicineRecordInPage(),
        '/extramedicine': (context) => ExtramedicineInPage(),
        '/medicinesearch': (context) => MedicineSearchInPage(),
        '/showmedicine': (context) => ShowMedicineInPage(),
        '/knowledge': (context) => KnowledgeInPage(),
        '/modifyProfile': (context) => ModifyProfileInPage(),
        '/glucose1': (context) => GlucoseInPage1(),
        '/glucose2': (context) => GlucoseInPage2(),
        '/glucose3': (context) => GlucoseInPage3(),
        '/BPKnowledge': (context) => BPKnowledgeInPage(),
        '/GKnowledge': (context) => GKnowledgeInPage(),
        '/QAKnowledge': (context) => QAKnowledgeInPage(),
        '/foodKnowledge': (context) => foodKnowledgeInPage(),
      },
      //home: Calendar(),
    );
  }
}

//Drawer
class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Text(
              '目錄',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Color(0xFF18b6b2),
            ),
          ),
          ListTile(
            title: Text('行事曆'),
            onTap: () {
              Navigator.popAndPushNamed(context, '/');
            },
          ),
          ListTile(
            title: Text('個人資料'),
            onTap: () async {
              print(MediaQuery.of(context).size);
              var pp = new ProfileDBProvider();
              await pp.open();
              await pp.getProfileDB(1);
              print(profileIntial);
              if (profileIntial == 1) {
                await pp.getProfileName(1);
              }

              //print("p:" + pName);
              name = pName;
              age = pAge;
              hospital = pHospital;
              phone = pPhone;
              thing = pThing;
              Navigator.popAndPushNamed(context, '/profile');
            },
          ),
          ListTile(
            title: Text('血壓測量'),
            onTap: () async {
              String now = DateTime.now().toString();
              var bp = new BloodpressureDBProvider();
              await bp.open();
              await bp.checkUpdate1(DateTime.now().weekday.toString(),
                  now.toString().substring(0, 10));
              Navigator.popAndPushNamed(context, '/bloodpressure');
            },
          ),
          ListTile(
            title: Text('血壓折線圖'),
            onTap: () async {
              var now = DateTime.now();
              var dtStr = now.toIso8601String();
              now = DateTime.parse(dtStr);

              var bp = new BloodpressureDBProvider();
              await bp.open();

              await bp.bloodpressureNumWeek1();
              bpWeekNumList = getBloodpressureWeekNum1();
              bpWeekTimeList = getBloodpressureWeekTime();
              bpWeekLineList = getBloodpressureWeekLine();
              print('bpWeekNumList');
              print(bpWeekNumList);
              sbpDayWeek = [
                new bloodpressureDataWeek(0, 0),
              ];
              dbpDayWeek = [
                new bloodpressureDataWeek(0, 0),
              ];
              sbpNightWeek = [
                new bloodpressureDataWeek(0, 0),
              ];
              dbpNightWeek = [
                new bloodpressureDataWeek(0, 0),
              ];
              for (int i = 0; i < bpWeekNumList.length; i++) {
                if (bpWeekLineList[i] == 'sDay')
                  sbpDayWeek.add(new bloodpressureDataWeek(
                      bpWeekTimeList[i], bpWeekNumList[i]));
                if (bpWeekLineList[i] == 'dDay')
                  dbpDayWeek.add(new bloodpressureDataWeek(
                      bpWeekTimeList[i], bpWeekNumList[i]));
                if (bpWeekLineList[i] == 'sNight')
                  sbpNightWeek.add(new bloodpressureDataWeek(
                      bpWeekTimeList[i], bpWeekNumList[i]));
                if (bpWeekLineList[i] == 'dNight')
                  dbpNightWeek.add(new bloodpressureDataWeek(
                      bpWeekTimeList[i], bpWeekNumList[i]));
              }
              await bp.bloodpressureNumMonth(now.toString());
              bpMonthNumList = getBloodpressureMonthNum();
              bpMonthTimeList = getBloodpressureMonthTime();
              bpMonthLineList = getBloodpressureMonthLine();
              print('bpMonthNumList');
              print(bpMonthNumList);
              sbpDayMonth = [
                new bloodpressureDataMonth(0, 0),
              ];
              dbpDayMonth = [
                new bloodpressureDataMonth(0, 0),
              ];
              sbpNightMonth = [
                new bloodpressureDataMonth(0, 0),
              ];
              dbpNightMonth = [
                new bloodpressureDataMonth(0, 0),
              ];
              for (int i = 0; i < bpMonthNumList.length; i++) {
                if (bpMonthLineList[i] == 'sDay')
                  sbpDayMonth.add(new bloodpressureDataMonth(
                      bpMonthTimeList[i], bpMonthNumList[i]));
                if (bpMonthLineList[i] == 'dDay')
                  dbpDayMonth.add(new bloodpressureDataMonth(
                      bpMonthTimeList[i], bpMonthNumList[i]));
                if (bpMonthLineList[i] == 'sNight')
                  sbpNightMonth.add(new bloodpressureDataMonth(
                      bpMonthTimeList[i], bpMonthNumList[i]));
                if (bpMonthLineList[i] == 'dNight')
                  dbpNightMonth.add(new bloodpressureDataMonth(
                      bpMonthTimeList[i], bpMonthNumList[i]));
              }

              Navigator.popAndPushNamed(context, '/bloodpressurechart');
            },
          ),
          ListTile(
            title: Text('血糖測量'),
            onTap: () async {
              String now = DateTime.now().toString();

              var gp = new GlucoseDBProvider();
              await gp.open();
              await gp.checkUpdate(DateTime.now().weekday.toString(),
                  now.toString().substring(0, 10));
              Navigator.popAndPushNamed(context, '/glucose1');
            },
          ),
          ListTile(
            title: Text('血糖折線圖'),
            onTap: () async {
              var now = DateTime.now();
              var dtStr = now.toIso8601String();
              now = DateTime.parse(dtStr);

              var gp = new GlucoseDBProvider();
              await gp.open();

              await gp.glucoseNumWeek();
              gpWeekNumList = getGlucoseWeekNum();
              gpWeekTimeList = getGlucoseWeekTime();
              gpWeekLineList = getGlucoseWeekLine();
              print('gpWeekNumList');
              print(gpWeekNumList);
              a1Week = [new glucoseDataWeek(0, 0)];
              a2Week = [new glucoseDataWeek(0, 0)];
              a3Week = [new glucoseDataWeek(0, 0)];
              b1Week = [new glucoseDataWeek(0, 0)];
              b2Week = [new glucoseDataWeek(0, 0)];
              b3Week = [new glucoseDataWeek(0, 0)];
              for (int i = 0; i < gpWeekNumList.length; i++) {
                if (gpWeekLineList[i] == 'a1')
                  a1Week.add(
                      new glucoseDataWeek(gpWeekTimeList[i], gpWeekNumList[i]));
                if (gpWeekLineList[i] == 'b1')
                  b1Week.add(
                      new glucoseDataWeek(gpWeekTimeList[i], gpWeekNumList[i]));
                if (gpWeekLineList[i] == 'a2')
                  a2Week.add(
                      new glucoseDataWeek(gpWeekTimeList[i], gpWeekNumList[i]));
                if (gpWeekLineList[i] == 'b2')
                  b2Week.add(
                      new glucoseDataWeek(gpWeekTimeList[i], gpWeekNumList[i]));
                if (gpWeekLineList[i] == 'a3')
                  a3Week.add(
                      new glucoseDataWeek(gpWeekTimeList[i], gpWeekNumList[i]));
                if (gpWeekLineList[i] == 'b3')
                  b3Week.add(
                      new glucoseDataWeek(gpWeekTimeList[i], gpWeekNumList[i]));
              }
              await gp.glucoseNumMonth(now.toString());
              gpMonthNumList = getGlucoseMonthNum();
              gpMonthTimeList = getGlucoseMonthTime();
              gpMonthLineList = getGlucoseMonthLine();
              print('gpMonthNumList');
              print(gpMonthNumList);

              a1Month = [new glucoseDataMonth(0, 0)];
              a2Month = [new glucoseDataMonth(0, 0)];
              a3Month = [new glucoseDataMonth(0, 0)];
              b1Month = [new glucoseDataMonth(0, 0)];
              b2Month = [new glucoseDataMonth(0, 0)];
              b3Month = [new glucoseDataMonth(0, 0)];

              for (int i = 0; i < gpMonthNumList.length; i++) {
                if (gpMonthLineList[i] == 'a1')
                  a1Month.add(new glucoseDataMonth(
                      gpMonthTimeList[i], gpMonthNumList[i]));
                if (gpMonthLineList[i] == 'b1')
                  b1Month.add(new glucoseDataMonth(
                      gpMonthTimeList[i], gpMonthNumList[i]));
                if (gpMonthLineList[i] == 'a2')
                  a2Month.add(new glucoseDataMonth(
                      gpMonthTimeList[i], gpMonthNumList[i]));
                if (gpMonthLineList[i] == 'b2')
                  b2Month.add(new glucoseDataMonth(
                      gpMonthTimeList[i], gpMonthNumList[i]));
                if (gpMonthLineList[i] == 'a3')
                  a3Month.add(new glucoseDataMonth(
                      gpMonthTimeList[i], gpMonthNumList[i]));
                if (gpMonthLineList[i] == 'b3')
                  b3Month.add(new glucoseDataMonth(
                      gpMonthTimeList[i], gpMonthNumList[i]));
              }
              Navigator.popAndPushNamed(context, '/glucosechart');
            },
          ),
          ListTile(
            title: Text('藥品紀錄'),
            onTap: () {
              Navigator.popAndPushNamed(context, '/medicinerecord');
            },
          ),
          ListTile(
            title: Text('保健食品與額外藥品'),
            onTap: () {
              Navigator.popAndPushNamed(context, '/extramedicine');
            },
          ),
          ListTile(
            title: Text('藥品搜尋'),
            onTap: () {
              Navigator.popAndPushNamed(context, '/medicinesearch');
            },
          ),
          ListTile(
            title: Text('衛教知識'),
            onTap: () {
              Navigator.popAndPushNamed(context, '/knowledge');
            },
          ),
        ],
      ),
    );
  }
}
//個人資料

class ProfileInPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('個人資料'),
          backgroundColor: Color(0xFF18b6b2),
        ),
        drawer: MyDrawer(),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
              Container(
                height: 75,
                width: 400,
                child: Text(
                  "姓名:" + name,
                  style: TextStyle(fontSize: 30, color: Colors.blue),
                ),
              ),
              Container(
                height: 75,
                width: 400,
                child: Text(
                  "年齡:" + age,
                  style: TextStyle(fontSize: 30, color: Colors.blue),
                ),
              ),
              Container(
                height: 75,
                width: 400,
                child: Text(
                  "就醫診所:" + hospital,
                  style: TextStyle(fontSize: 30, color: Colors.blue),
                ),
              ),
              Container(
                height: 75,
                width: 400,
                child: Text(
                  "電話:" + phone,
                  style: TextStyle(fontSize: 30, color: Colors.blue),
                ),
              ),
              Container(
                  height: 200,
                  width: 400,
                  child: Row(
                    children: [
                      Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "病史:",
                            style: TextStyle(fontSize: 30, color: Colors.blue),
                          )),
                      Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            thing,
                            style: TextStyle(fontSize: 30, color: Colors.blue),
                          )),
                    ],
                  )),
              RaisedButton(
                  child: Text("修改資料"),
                  onPressed: () async {
                    //print("p:" + pName + pHospital);
                    var pp = new ProfileDBProvider();
                    await pp.open();
                    pp.getProfileDB(1);
                    if (profileIntial == 0) {
                      var p = new ProfileDB();
                      p.name = name;
                      p.age = age;
                      p.hospital = hospital;
                      p.phone = phone;
                      p.thing = thing;
                      await pp.insert(p);
                      print(pp.getProfileDB(1));
                      //name = 'change';
                    }
                    Navigator.popAndPushNamed(context, '/modifyProfile');
                  }),
            ])));
  }
}

//修改個人資料
class ModifyProfileInPage extends StatefulWidget {
  const ModifyProfileInPage({Key? key}) : super(key: key);
  @override
  State<ModifyProfileInPage> createState() => _ModifyProfileInPage();
}

class _ModifyProfileInPage extends State<ModifyProfileInPage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = new TextEditingController();
    final TextEditingController ageController = new TextEditingController();
    final TextEditingController hospitalController =
    new TextEditingController();
    final TextEditingController phoneController = new TextEditingController();
    final TextEditingController thingController = new TextEditingController();
    return Scaffold(
        appBar: AppBar(
          title: Text('修改個人資料'),
          backgroundColor: Color(0xFF18b6b2),
        ),
        drawer: MyDrawer(),
        body: SingleChildScrollView(
            child: Column(children: [
              Container(
                  height: 100,
                  width: 400,
                  child: Row(
                    children: [
                      Flexible(
                          child: Text(
                            "姓名:",
                            style: TextStyle(fontSize: 30, color: Colors.blue),
                          )),
                      Flexible(
                          child: TextField(
                            style: TextStyle(fontSize: 20, color: Colors.blue),
                            controller: nameController,
                            decoration: InputDecoration(hintText: name),
                          )),
                    ],
                  )),
              Container(
                  height: 100,
                  width: 400,
                  child: Row(
                    children: [
                      Flexible(
                          child: Text(
                            "年齡:",
                            style: TextStyle(fontSize: 30, color: Colors.blue),
                          )),
                      Flexible(
                          child: TextField(
                            style: TextStyle(fontSize: 20, color: Colors.blue),
                            controller: ageController,
                            decoration: InputDecoration(hintText: age),
                          )),
                    ],
                  )),
              Container(
                  height: 100,
                  width: 400,
                  child: Row(
                    children: [
                      Flexible(
                          child: Text(
                            "醫院:",
                            style: TextStyle(fontSize: 30, color: Colors.blue),
                          )),
                      Flexible(
                          child: TextField(
                            style: TextStyle(fontSize: 20, color: Colors.blue),
                            controller: hospitalController,
                            decoration: InputDecoration(hintText: hospital),
                          )),
                    ],
                  )),
              Container(
                  height: 100,
                  width: 400,
                  child: Row(
                    children: [
                      Flexible(
                          child: Text(
                            "電話:",
                            style: TextStyle(fontSize: 30, color: Colors.blue),
                          )),
                      Flexible(
                          child: TextField(
                            style: TextStyle(fontSize: 20, color: Colors.blue),
                            controller: phoneController,
                            decoration: InputDecoration(hintText: phone),
                          )),
                    ],
                  )),
              Container(
                  height: 100,
                  width: 400,
                  child: Row(
                    children: [
                      Flexible(
                          child: Text(
                            "病史:",
                            style: TextStyle(fontSize: 30, color: Colors.blue),
                          )),
                      Flexible(
                          child: Column(children: [
                            Container(
                                child: Row(children: <Widget>[
                                  Text("糖尿病"),
                                  Checkbox(
                                      value: disease1,
                                      onChanged: (isMan) {
                                        setState(() {
                                          if (isMan == true && disease1 == false) {
                                            disease1 = true;
                                          } else {
                                            disease1 = false;
                                          }
                                        });
                                      })
                                ])),
                            Container(
                                child: Row(children: <Widget>[
                                  Text("高血壓"),
                                  Checkbox(
                                      value: disease2,
                                      onChanged: (isMan) {
                                        setState(() {
                                          if (isMan == true && disease2 == false) {
                                            disease2 = true;
                                          } else {
                                            disease2 = false;
                                          }
                                        });
                                      })
                                ])),
                          ])),
                    ],
                  )),
              RaisedButton(
                  child: Text("修改完成"),
                  onPressed: () async {
                    var pp = new ProfileDBProvider();
                    await pp.open();
                    var p = new ProfileDB();
                    p.id = 1;
                    //-----------------------------
                    if (nameController.text != "") {
                      p.name = nameController.text;
                      name = nameController.text;
                    } else {
                      p.name = name;
                    }
                    if (ageController.text != "") {
                      p.age = ageController.text;
                      age = ageController.text;
                    } else {
                      p.age = age;
                    }
                    if (hospitalController.text != "") {
                      p.hospital = hospitalController.text;
                      hospital = hospitalController.text;
                    } else {
                      p.hospital = hospital;
                    }
                    if (phoneController.text != "") {
                      p.phone = phoneController.text;
                      phone = phoneController.text;
                    } else {
                      p.phone = phone;
                    }
                    String diseaseStr = "";
                    if (disease1 == true) {
                      diseaseStr += "糖尿病\n";
                    }
                    if (disease2 == true) {
                      diseaseStr += "高血壓\n";
                    }
                    p.thing = diseaseStr;
                    thing = diseaseStr;
                    // if (thingController.text != "") {
                    //   p.thing = thingController.text;
                    //   thing = thingController.text;
                    // } else {
                    //   p.thing = thing;
                    // }
                    await pp.update(p);
                    print(pp.getProfileDB(1));
                    Navigator.popAndPushNamed(context, '/profile');
                  }),
            ])));
  }
}

//早上血壓
class PressureInPage extends StatelessWidget {
  get floatingActionButton => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('血壓測量'),
          backgroundColor: Color(0xFF18b6b2),
        ),
        drawer: MyDrawer(),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(children: [
            Expanded(
                child: Column(children: [
                  Container(
                    height: 250,
                    child: Center(
                      child: Text(
// content of text
                        "早上血壓",
// Setup size and color of Text
                        style: TextStyle(fontSize: 30, color: Colors.blue),
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Text(
                      "收縮壓:" + daySBP,
                      style: TextStyle(fontSize: 30, color: Colors.blue),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Text(
                      "舒張壓:" + dayDBP,
                      style: TextStyle(fontSize: 30, color: Colors.blue),
                    ),
                  ),
                  Container(
                      height: 35,
                      child: Row(children: [RaisedButton(
                          child: Text("填寫或修改"),
                          onPressed: () async {
                            dayORnight = 'day';
                            Navigator.popAndPushNamed(
                                context, '/bloodpressuretest');
                          }),   Text("               ") ,  RaisedButton(

                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          color:Colors.pinkAccent,
                          onPressed: (){
                            Navigator.push(
                              context,
                              new MaterialPageRoute(builder: (context) => bloodpressureAlarmPage()),
                            );
                          },
                          child: Text('新增提醒鬧鐘',
                            style:
                            TextStyle(fontSize: 20,color: Colors.white),)),],)), ])),
            Container(
              height: 100,
              alignment: Alignment.bottomCenter,
              child: MaterialButton(
                color: Color.fromARGB(255, 185, 246, 229),
                child: Text("晚上血壓"),
                onPressed: () =>
                    Navigator.popAndPushNamed(context, '/nightbloodpressure'),
                minWidth: double.infinity,
                height: 50,
              ),
            ),
          ]),
        ));
  }
}

//晚上血壓
class NightPressureInPage extends StatelessWidget {
  get floatingActionButton => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('血壓測量'),
          backgroundColor: Color(0xFF18b6b2),
        ),
        drawer: MyDrawer(),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(children: [
            Expanded(
                child: Column(children: [
                  Container(
                    height: 250,
                    child: Center(
                      child: Text(
// content of text
                        "晚上血壓",
// Setup size and color of Text
                        style: TextStyle(fontSize: 30, color: Colors.blue),
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Text(
                      "收縮壓:" + nightSBP,
                      style: TextStyle(fontSize: 30, color: Colors.blue),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Text(
                      "舒張壓:" + nightDBP,
                      style: TextStyle(fontSize: 30, color: Colors.blue),
                    ),
                  ),
                  Container(
                      height: 35,
                      child: Row(children: [RaisedButton(
                      child: Text("填寫或修改"),
                      onPressed: () async {
                        dayORnight = 'night';
                        Navigator.popAndPushNamed(
                            context, '/bloodpressuretest');
                      }),      RaisedButton(

                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                color:Colors.pinkAccent,
                onPressed: (){
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => bloodpressureAlarmPage()),
                  );
                },
                child: Text('新增提醒鬧鐘',
                  style:
                  TextStyle(fontSize: 20,color: Colors.white),)),],) ) ])),
            Container(
              height: 100,
              alignment: Alignment.bottomCenter,
              child: MaterialButton(
                color: Color.fromARGB(255, 185, 246, 229),
                child: Text("早上血壓"),
                onPressed: () =>
                    Navigator.popAndPushNamed(context, '/bloodpressure'),
                minWidth: double.infinity,
                height: 50,
              ),
            ),
          ]),
        ));
  }
}

//-----------------------------------------------------------------------------
//血壓測量
class RecordPressureInPage extends StatelessWidget {
  TextEditingController SBPController = TextEditingController();
  TextEditingController DBPController = TextEditingController();

  get floatingActionButton => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('血壓測量'),
          backgroundColor: Color(0xFF18b6b2),
        ),
        drawer: MyDrawer(),
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              height: 150,
              child: Center(
                child: Text(
// content of text
                  "血壓",
// Setup size and color of Text
                  style: TextStyle(fontSize: 30, color: Colors.blue),
                ),
              ),
            ),
            Container(
              height: 100,
              child: buildSBPField("收縮壓"),
            ),
            Container(
              height: 100,
              child: buildDBPField("舒張壓"),
            ),
            Container(
              child: RaisedButton(
                color: Colors.white54,
                child: Text("填寫完成"),
                onPressed: () async {
                  var numberSBP = 0;
                  var numberDBP = 0;
                  if (SBPController.text != "")
                    numberSBP = int.parse(SBPController.text);
                  if (DBPController.text != "")
                    numberDBP = int.parse(DBPController.text);

                  var now = DateTime.now();
                  var bp = new BloodpressureDBProvider();
                  await bp.open();
                  await bp.checkUpdate1(
                      now.weekday.toString(), now.toString().substring(0, 10));

                  var s = new BloodpressureDB();
                  s.num = numberSBP.toString();
                  s.time = now.toString();
                  //s.time = now.toString();
                  s.weekday = DateTime.now().weekday.toString();
                  //s.sd = 's';
                  var d = new BloodpressureDB();
                  d.num = numberDBP.toString();
                  //d.time = now.toString();
                  d.time = now.toString();
                  d.weekday = DateTime.now().weekday.toString();
                  //d.sd = 'd';

                  if (dayORnight == 'day') {
                    s.sd = 'sDay';
                    d.sd = 'dDay';
                  } else {
                    s.sd = 'sNight';
                    d.sd = 'dNight';
                  }
                  //白天
                  if (dayORnight == 'day') {
                    //如果已經有資料
                    if (checkDaySBP > 0) await bp.delete(checkDaySBP);
                    await bp.insert(s);
                    if (checkDayDBP > 0) await bp.delete(checkDayDBP);
                    await bp.insert(d);
                    daySBP = numberSBP.toString(); //update
                    dayDBP = numberDBP.toString();
                    Navigator.popAndPushNamed(context, '/bloodpressure');
                    //晚上
                  } else {
                    //如果已經有資料
                    if (checkNightSBP > 0) await bp.delete(checkNightSBP);
                    await bp.insert(s);
                    if (checkNightDBP > 0) await bp.delete(checkNightDBP);
                    await bp.insert(d);
                    nightSBP = numberSBP.toString(); //update
                    nightDBP = numberDBP.toString();
                    Navigator.popAndPushNamed(context, '/nightbloodpressure');
                  }
                },
              ),
            ),

            RaisedButton(

                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                color:Colors.pinkAccent,
                onPressed: (){
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => bloodpressureAlarmPage()),
                  );
                },
                child: Text('新增提醒鬧鐘',
                  style:
                  TextStyle(fontSize: 20,color: Colors.white),)),]),
        ));
  }

  Widget buildSBPField(txt) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: TextField(
        controller: SBPController, // 為了獲得TextField中的value
        decoration: InputDecoration(
          fillColor: Colors.white,
          // 背景顏色，必須結合filled: true,才有效
          filled: true,
          // 重點，必須設定為true，fillColor才有效
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)), // 設定邊框圓角弧度
            borderSide: BorderSide(
              color: Colors.black87, // 設定邊框的顏色
              width: 2.0, // 設定邊框的粗細
            ),
          ),
          // when user choose the TextField
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red, // 設定邊框的顏色
                width: 2, // 設定邊框的粗細
              )),
          hintText: txt,
          // 提示 文字
        ),
      ),
    );
  }

  Widget buildDBPField(txt) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: TextField(
        controller: DBPController, // 為了獲得TextField中的value
        decoration: InputDecoration(
          fillColor: Colors.white,
          // 背景顏色，必須結合filled: true,才有效
          filled: true,
          // 重點，必須設定為true，fillColor才有效
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)), // 設定邊框圓角弧度
            borderSide: BorderSide(
              color: Colors.black87, // 設定邊框的顏色
              width: 2.0, // 設定邊框的粗細
            ),
          ),
          // when user choose the TextField
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red, // 設定邊框的顏色
                width: 2, // 設定邊框的粗細
              )),
          hintText: txt,
          // 提示 文字
        ),
      ),
    );
  }
}

//每周血壓折線圖
class bloodpressureDataWeek {
  final int time;
  final int num;
  bloodpressureDataWeek(this.time, this.num);
}

var sbpDayWeek = [
  new bloodpressureDataWeek(0, 0),
];
var dbpDayWeek = [
  new bloodpressureDataWeek(0, 0),
];
var sbpNightWeek = [
  new bloodpressureDataWeek(0, 0),
];
var dbpNightWeek = [
  new bloodpressureDataWeek(0, 0),
];
_getBloodpressureWeekData() {
  List<charts.Series<bloodpressureDataWeek, int>> series = [
    charts.Series(
        id: "Sales",
        data: sbpDayWeek,
        domainFn: (bloodpressureDataWeek series, _) => series.time,
        measureFn: (bloodpressureDataWeek series, _) => series.num,
        colorFn: (bloodpressureDataWeek series, _) =>
        charts.MaterialPalette.red.shadeDefault),
    charts.Series(
        id: "Sales",
        data: dbpDayWeek,
        domainFn: (bloodpressureDataWeek series, _) => series.time,
        measureFn: (bloodpressureDataWeek series, _) => series.num,
        colorFn: (bloodpressureDataWeek series, _) =>
        charts.MaterialPalette.blue.shadeDefault),
    charts.Series(
        id: "Sales",
        data: sbpNightWeek,
        domainFn: (bloodpressureDataWeek series, _) => series.time,
        measureFn: (bloodpressureDataWeek series, _) => series.num,
        colorFn: (bloodpressureDataWeek series, _) =>
        charts.MaterialPalette.green.shadeDefault),
    charts.Series(
        id: "Sales",
        data: dbpNightWeek,
        domainFn: (bloodpressureDataWeek series, _) => series.time,
        measureFn: (bloodpressureDataWeek series, _) => series.num,
        colorFn: (bloodpressureDataWeek series, _) =>
        charts.MaterialPalette.purple.shadeDefault)
  ];
  return series;
}

//每月血壓折線圖
class bloodpressureDataMonth {
  final int time;
  final int num;
  bloodpressureDataMonth(this.time, this.num);
}

var sbpDayMonth = [
  new bloodpressureDataMonth(0, 0),
];
var dbpDayMonth = [
  new bloodpressureDataMonth(0, 0),
];
var sbpNightMonth = [
  new bloodpressureDataMonth(0, 0),
];
var dbpNightMonth = [
  new bloodpressureDataMonth(0, 0),
];
_getBloodpressureMonthData() {
  List<charts.Series<bloodpressureDataMonth, int>> series = [
    charts.Series(
        id: "Sales",
        data: sbpDayMonth,
        domainFn: (bloodpressureDataMonth series, _) => series.time,
        measureFn: (bloodpressureDataMonth series, _) => series.num,
        colorFn: (bloodpressureDataMonth series, _) =>
        charts.MaterialPalette.red.shadeDefault),
    charts.Series(
        id: "Sales",
        data: dbpDayMonth,
        domainFn: (bloodpressureDataMonth series, _) => series.time,
        measureFn: (bloodpressureDataMonth series, _) => series.num,
        colorFn: (bloodpressureDataMonth series, _) =>
        charts.MaterialPalette.blue.shadeDefault),
    charts.Series(
        id: "Sales",
        data: sbpNightMonth,
        domainFn: (bloodpressureDataMonth series, _) => series.time,
        measureFn: (bloodpressureDataMonth series, _) => series.num,
        colorFn: (bloodpressureDataMonth series, _) =>
        charts.MaterialPalette.green.shadeDefault),
    charts.Series(
        id: "Sales",
        data: dbpNightMonth,
        domainFn: (bloodpressureDataMonth series, _) => series.time,
        measureFn: (bloodpressureDataMonth series, _) => series.num,
        colorFn: (bloodpressureDataMonth series, _) =>
        charts.MaterialPalette.purple.shadeDefault)
  ];
  return series;
}

class RecordPressureChartInPage extends StatelessWidget {
  TextEditingController _eventController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('血壓折線圖'),
          backgroundColor: Color(0xFF18b6b2),
        ),
        drawer: MyDrawer(),
        body: Column(children: [
          const Flexible(
              child: Center(
                child: Text(
// content of text
                  "每周血壓",
// Setup size and color of Text
                  style: TextStyle(fontSize: 30, color: Colors.blue),
                ),
              ),
              flex: 1),
          Flexible(
              child: new charts.LineChart(
                _getBloodpressureWeekData(),
                animate: true,
              ),
              flex: 5),
          const Flexible(
              child: Center(
                child: Text(
// content of text
                  "每月血壓",
// Setup size and color of Text
                  style: TextStyle(fontSize: 30, color: Colors.blue),
                ),
              ),
              flex: 1),
          Flexible(
              child: new charts.LineChart(
                _getBloodpressureMonthData(),
                animate: true,
              ),
              flex: 5),
        ]));
  }
}

//早餐血糖
class GlucoseInPage1 extends StatelessWidget {
  get floatingActionButton => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('血糖測量'),
          backgroundColor: Color(0xFF18b6b2),
        ),
        drawer: MyDrawer(),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(children: [
            Expanded(
                child: Column(children: [
                  Container(
                    height: 250,
                    child: Center(
                      child: Text(
// content of text
                        "早上血糖",
// Setup size and color of Text
                        style: TextStyle(fontSize: 30, color: Colors.blue),
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Text(
                      "飯前血糖:" + before1,
                      style: TextStyle(fontSize: 30, color: Colors.blue),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Text(
                      "飯後血糖:" + after1,
                      style: TextStyle(fontSize: 30, color: Colors.blue),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: Row(children: [
                        RaisedButton(

                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            color:Colors.pinkAccent,
                            onPressed: (){
                              Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => bloodpressureAlarmPage()),
                              );
                            },
                            child: Text('新增提醒鬧鐘',
                              style:
                              TextStyle(fontSize: 20,color: Colors.white),)),
                        Text("     "),
                        RaisedButton(
                            child: Text("填寫或修改"),
                            onPressed: () async {
                              glucoseTime = 1;
                              Navigator.popAndPushNamed(context, '/glucosetest');})],) )
                ])),
            Container(
              height: 50,
              child: Container(
                height: 50,
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MaterialButton(
                        color: Colors.white54,
                        child: Text("中午血糖"),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/glucose2'),
                        minWidth: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: MaterialButton(
                        color: Colors.lightGreen,
                        child: Text("晚上血糖"),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/glucose3'),
                        minWidth: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ]),
        ));
  }
}

//午餐血糖
class GlucoseInPage2 extends StatelessWidget {
  get floatingActionButton => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('血糖測量'),
          backgroundColor: Color(0xFF18b6b2),
        ),
        drawer: MyDrawer(),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(children: [
            Expanded(
                child: Column(children: [
                  Container(
                    height: 250,
                    child: Center(
                      child: Text(
// content of text
                        "中午血糖",
// Setup size and color of Text
                        style: TextStyle(fontSize: 30, color: Colors.blue),
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Text(
                      "餐前血糖:" + before2,
                      style: TextStyle(fontSize: 30, color: Colors.blue),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Text(
                      "餐後血糖:" + after2,
                      style: TextStyle(fontSize: 30, color: Colors.blue),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: Row(children: [
                        RaisedButton(

                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            color:Colors.pinkAccent,
                            onPressed: (){
                              Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => bloodpressureAlarmPage()),
                              );
                            },
                            child: Text('新增提醒鬧鐘',
                              style:
                              TextStyle(fontSize: 20,color: Colors.white),)),
                        Text("     "),
                        RaisedButton(
                            child: Text("填寫或修改"),
                            onPressed: () async {
                              glucoseTime = 2;
                              Navigator.popAndPushNamed(context, '/glucosetest');
                            })],) )
                ])),
            Container(
              height: 50,
              child: Container(
                height: 50,
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MaterialButton(
                        color: Colors.white54,
                        child: Text("早上血糖"),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/glucose1'),
                        minWidth: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: MaterialButton(
                        color: Colors.lightGreen,
                        child: Text("晚上血糖"),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/glucose3'),
                        minWidth: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
            )
]),
        ));
  }
}

//晚餐血糖
class GlucoseInPage3 extends StatelessWidget {
  get floatingActionButton => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('血糖測量'),
          backgroundColor: Color(0xFF18b6b2),
        ),
        drawer: MyDrawer(),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(children: [
            Expanded(
                child: Column(children: [
                  Container(
                    height: 250,
                    child: Center(
                      child: Text(
// content of text
                        "晚上血糖",
// Setup size and color of Text
                        style: TextStyle(fontSize: 30, color: Colors.blue),
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Text(
                      "餐前血糖:" + before3,
                      style: TextStyle(fontSize: 30, color: Colors.blue),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Text(
                      "餐後血糖:" + after3,
                      style: TextStyle(fontSize: 30, color: Colors.blue),
                    ),
                  ),
                  Container(
                      height: 50,
                      child:Row(children: [
                        RaisedButton(

                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            color:Colors.pinkAccent,
                            onPressed: (){
                              Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (context) => bloodpressureAlarmPage()),
                              );
                            },
                            child: Text('新增提醒鬧鐘',
                              style:
                              TextStyle(fontSize: 20,color: Colors.white),)),
                        Text("     "),
                        RaisedButton(
                          child: Text("填寫或修改"),
                          onPressed: () async {
                            glucoseTime = 3;
                            Navigator.popAndPushNamed(context, '/glucosetest');
                          })],) ),

                ])),
            Container(
              height: 50,
              child: Container(
                height: 50,
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MaterialButton(
                        color: Colors.white54,
                        child: Text("早上血糖"),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/glucose1'),
                        minWidth: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: MaterialButton(
                        color: Colors.lightGreen,
                        child: Text("中午血糖"),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/glucose2'),
                        minWidth: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ]),
        ));
  }
}

//血糖測量
class RecordGlucoseInPage extends StatelessWidget {
  TextEditingController beforeController = TextEditingController();
  TextEditingController afterController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('血糖測量'),
          backgroundColor: Color(0xFF18b6b2),
        ),
        drawer: MyDrawer(),
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              height: 150,
              child: Center(
                child: Text(
// content of text
                  "測量血糖",
// Setup size and color of Text
                  style: TextStyle(fontSize: 30, color: Colors.blue),
                ),
              ),
            ),
            Container(
              height: 100,
              child: buildBeforeMealField("飯前血糖值"),
            ),
            Container(
              height: 100,
              child: buildAfterMealField("飯後血糖值"),
            ),
            Container(
              child: RaisedButton(
                color: Colors.white54,
                child: Text("填寫完成"),
                onPressed: () async {
                  DateTime now = DateTime.now();

                  //write (if do not write->num-0)
                  var beforeNum = 0;
                  var afterNum = 0;
                  if (beforeController.text != "")
                    beforeNum = int.parse(beforeController.text);
                  if (afterController.text != "")
                    afterNum = int.parse(afterController.text);

                  var meal = new GlucoseDBProvider();
                  await meal.open();
                  //write into database
                  var before = new GlucoseDB();
                  before.num = beforeNum.toString();
                  before.time = now.toString();
                  before.weekday = now.weekday.toString();

                  var after = new GlucoseDB();
                  after.num = afterNum.toString();
                  after.time = now.toString();
                  after.weekday = now.weekday.toString();
                  //早上
                  if (glucoseTime == 1) {
                    before.meal = 'b1';
                    after.meal = 'a1';
                    if (checkBefore1 > 0) await meal.delete(checkBefore1);
                    await meal.insert(before);
                    if (checkAfter1 > 0) await meal.delete(checkAfter1);
                    await meal.insert(after);

                    //中午
                  } else if (glucoseTime == 2) {
                    before.meal = 'b2';
                    after.meal = 'a2';
                    if (checkBefore2 > 0) await meal.delete(checkBefore2);
                    await meal.insert(before);
                    if (checkAfter2 > 0) await meal.delete(checkAfter2);
                    await meal.insert(after);
                    //晚上
                  } else if (glucoseTime == 3) {
                    before.meal = 'b3';
                    after.meal = 'a3';
                    if (checkBefore3 > 0) await meal.delete(checkBefore3);
                    await meal.insert(before);
                    if (checkAfter3 > 0) await meal.delete(checkAfter3);
                    await meal.insert(after);
                  }
                  //返回頁面
                  if (glucoseTime == 1) {
                    before1 = before.num;
                    after1 = after.num;
                    Navigator.pushNamed(context, '/glucose1');
                  }
                  if (glucoseTime == 2) {
                    before2 = before.num;
                    after2 = after.num;
                    Navigator.pushNamed(context, '/glucose2');
                  }
                  if (glucoseTime == 3) {
                    before3 = before.num;
                    after3 = after.num;
                    Navigator.pushNamed(context, '/glucose3');
                  }
                },
              ),
            ),
            RaisedButton(

                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                color:Colors.pinkAccent,
                onPressed: (){
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => glucoseAlarmPage()),
                  );
                },
                child: Text('新增提醒鬧鐘',
                  style:
                  TextStyle(fontSize: 20,color: Colors.white),)),
          ]),
        ));
  }

  Widget buildBeforeMealField(txt) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: TextField(
        controller: beforeController, // 為了獲得TextField中的value
        decoration: InputDecoration(
          fillColor: Colors.white,
          // 背景顏色，必須結合filled: true,才有效
          filled: true,
          // 重點，必須設定為true，fillColor才有效
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)), // 設定邊框圓角弧度
            borderSide: BorderSide(
              color: Colors.black87, // 設定邊框的顏色
              width: 2.0, // 設定邊框的粗細
            ),
          ),
          // when user choose the TextField
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red, // 設定邊框的顏色
                width: 2, // 設定邊框的粗細
              )),
          hintText: txt,
          // 提示 文字
        ),
      ),
    );
  }

  Widget buildAfterMealField(txt) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: TextField(
        controller: afterController, // 為了獲得TextField中的value
        decoration: InputDecoration(
          fillColor: Colors.white,
          // 背景顏色，必須結合filled: true,才有效
          filled: true,
          // 重點，必須設定為true，fillColor才有效
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)), // 設定邊框圓角弧度
            borderSide: BorderSide(
              color: Colors.black87, // 設定邊框的顏色
              width: 2.0, // 設定邊框的粗細
            ),
          ),
          // when user choose the TextField
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red, // 設定邊框的顏色
                width: 2, // 設定邊框的粗細
              )),
          hintText: txt,
          // 提示 文字
        ),
      ),
    );
  }
}

//血糖折線圖
class glucoseDataWeek {
  final int time;
  final int num;
  glucoseDataWeek(this.time, this.num);
}

var a1Week = [
  new glucoseDataWeek(0, 0),
];
var a2Week = [
  new glucoseDataWeek(0, 0),
];
var a3Week = [
  new glucoseDataWeek(0, 0),
];
var b1Week = [
  new glucoseDataWeek(0, 0),
];
var b2Week = [
  new glucoseDataWeek(0, 0),
];
var b3Week = [
  new glucoseDataWeek(0, 0),
];

_getGlucoseWeekData() {
  List<charts.Series<glucoseDataWeek, int>> series = [
    charts.Series(
        id: "Sales",
        data: a1Week,
        domainFn: (glucoseDataWeek series, _) => series.time,
        measureFn: (glucoseDataWeek series, _) => series.num,
        colorFn: (glucoseDataWeek series, _) =>
        charts.MaterialPalette.red.shadeDefault),
    charts.Series(
        id: "Sales",
        data: b1Week,
        domainFn: (glucoseDataWeek series, _) => series.time,
        measureFn: (glucoseDataWeek series, _) => series.num,
        colorFn: (glucoseDataWeek series, _) =>
        charts.MaterialPalette.blue.shadeDefault),
    charts.Series(
        id: "Sales",
        data: a2Week,
        domainFn: (glucoseDataWeek series, _) => series.time,
        measureFn: (glucoseDataWeek series, _) => series.num,
        colorFn: (glucoseDataWeek series, _) =>
        charts.MaterialPalette.green.shadeDefault),
    charts.Series(
        id: "Sales",
        data: b2Week,
        domainFn: (glucoseDataWeek series, _) => series.time,
        measureFn: (glucoseDataWeek series, _) => series.num,
        colorFn: (glucoseDataWeek series, _) =>
        charts.MaterialPalette.yellow.shadeDefault),
    charts.Series(
        id: "Sales",
        data: a3Week,
        domainFn: (glucoseDataWeek series, _) => series.time,
        measureFn: (glucoseDataWeek series, _) => series.num,
        colorFn: (glucoseDataWeek series, _) =>
        charts.MaterialPalette.purple.shadeDefault),
    charts.Series(
        id: "Sales",
        data: b3Week,
        domainFn: (glucoseDataWeek series, _) => series.time,
        measureFn: (glucoseDataWeek series, _) => series.num,
        colorFn: (glucoseDataWeek series, _) =>
        charts.MaterialPalette.deepOrange.shadeDefault),
  ];
  return series;
}

//------------------------------------
class glucoseDataMonth {
  final int time;
  final int num;
  glucoseDataMonth(this.time, this.num);
}

var a1Month = [
  new glucoseDataMonth(0, 0),
];
var a2Month = [
  new glucoseDataMonth(0, 0),
];
var a3Month = [
  new glucoseDataMonth(0, 0),
];
var b1Month = [
  new glucoseDataMonth(0, 0),
];
var b2Month = [
  new glucoseDataMonth(0, 0),
];
var b3Month = [
  new glucoseDataMonth(0, 0),
];

_getGlucoseMonthData() {
  List<charts.Series<glucoseDataMonth, int>> series = [
    charts.Series(
        id: "Sales",
        data: a1Month,
        domainFn: (glucoseDataMonth series, _) => series.time,
        measureFn: (glucoseDataMonth series, _) => series.num,
        colorFn: (glucoseDataMonth series, _) =>
        charts.MaterialPalette.red.shadeDefault),
    charts.Series(
        id: "Sales",
        data: b1Month,
        domainFn: (glucoseDataMonth series, _) => series.time,
        measureFn: (glucoseDataMonth series, _) => series.num,
        colorFn: (glucoseDataMonth series, _) =>
        charts.MaterialPalette.blue.shadeDefault),
    charts.Series(
        id: "Sales",
        data: a2Month,
        domainFn: (glucoseDataMonth series, _) => series.time,
        measureFn: (glucoseDataMonth series, _) => series.num,
        colorFn: (glucoseDataMonth series, _) =>
        charts.MaterialPalette.green.shadeDefault),
    charts.Series(
        id: "Sales",
        data: b2Month,
        domainFn: (glucoseDataMonth series, _) => series.time,
        measureFn: (glucoseDataMonth series, _) => series.num,
        colorFn: (glucoseDataMonth series, _) =>
        charts.MaterialPalette.yellow.shadeDefault),
    charts.Series(
        id: "Sales",
        data: a3Month,
        domainFn: (glucoseDataMonth series, _) => series.time,
        measureFn: (glucoseDataMonth series, _) => series.num,
        colorFn: (glucoseDataMonth series, _) =>
        charts.MaterialPalette.purple.shadeDefault),
    charts.Series(
        id: "Sales",
        data: b3Month,
        domainFn: (glucoseDataMonth series, _) => series.time,
        measureFn: (glucoseDataMonth series, _) => series.num,
        colorFn: (glucoseDataMonth series, _) =>
        charts.MaterialPalette.pink.shadeDefault),
  ];
  return series;
}
//--------------------------------------------------

class RecordGlucoseChartInPage extends StatelessWidget {
  TextEditingController _eventController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('血糖折線圖'),
          backgroundColor: Color(0xFF18b6b2),
        ),
        drawer: MyDrawer(),
        body: Column(children: [
          const Flexible(
              child: Center(
                child: Text(
// content of text
                  "每周血糖",
// Setup size and color of Text
                  style: TextStyle(fontSize: 30, color: Colors.blue),
                ),
              ),
              flex: 1),
          Flexible(
              child: new charts.LineChart(
                _getGlucoseWeekData(),
                animate: true,
              ),
              flex: 5),
          const Flexible(
              child: Center(
                child: Text(
// content of text
                  "每月血糖",
// Setup size and color of Text
                  style: TextStyle(fontSize: 30, color: Colors.blue),
                ),
              ),
              flex: 1),
          Flexible(
              child: new charts.LineChart(
                _getGlucoseMonthData(),
                animate: true,
              ),
              flex: 5)
        ]));
  }
}

//藥品搜尋

class MedicineSearchInPage extends StatelessWidget {
  // Declare TextEditingController to get the value in TextField
  TextEditingController taiwanessController = TextEditingController();
  TextEditingController _eventController = TextEditingController();

  Future<void> loadAsset(String input) async {
    String s1 = await rootBundle.loadString('assets/name.txt');
    String s2 = await rootBundle.loadString('assets/indication.txt');
    String s3 = await rootBundle.loadString('assets/ingredient.txt');
    String s4 = await rootBundle.loadString('assets/nameEng.txt');
    nameCh = [];
    nameEng = [];
    ingredient = [];
    indication = [];
    listName = [];
    listNameEng = [];
    listIndication = [];
    listIngredient = [];
    int initial1 = 0;
    int initial2 = 0;
    int initial3 = 0;
    int initial4 = 0;
    for (int j = 0; j < s1.length; j++) {
      if (s1[j] == '\n') {
        listName.add(s1.substring(initial1 + 9, j - 3));
        initial1 = j;
      }
      if (s4[j] == '\n') {
        listNameEng.add(s4.substring(initial4 + 9, j - 3));
        initial4 = j;
      }
      if (s2[j] == '\n') {
        listIndication.add(s2.substring(initial2 + 8, j - 3));
        initial2 = j;
      }
      if (s3[j] == '\n') {
        listIngredient.add(s3.substring(initial3 + 9, j - 3));
        initial3 = j + 1;
      }
    }
    print(listNameEng.length);
    print(input);
    int check = 0;
    for (int i = 0; i < listNameEng.length; i++) {
      if (listNameEng[i].contains(input) || listName[i].contains(input)) {
        check = 1;
        nameCh.add("中文品名:" + listName[i]);
        //nameCh.add("英文品名:" + listNameEng[i]);
        nameEng.add("英文品名:" + listNameEng[i]);
        //nameCh.add("成分:" + listIngredient[i]);
        //nameCh.add("適應症:" + listIndication[i]);
        indication.add("適應症:" + listIndication[i] + '\n');
        //nameCh.add("\n\n");
        // nameEng.add(listNameEng[i]);
        // ingredient.add(listIngredient[i]);
        // indication.add(listIndication[i]);
      }
    }
    if (check == 0) {
      nameCh.add("查無訊息");
      nameEng.add("查無訊息");
      ingredient.add("查無訊息");
      indication.add("查無訊息");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('藥品搜尋'),
          backgroundColor: Color(0xFF18b6b2),
        ),
        drawer: MyDrawer(),
        body: Column(children: [
          const Flexible(
            child: Center(
              child: Text(
// content of text
                "藥品名",
// Setup size and color of Text
                style: TextStyle(fontSize: 30, color: Colors.blue),
              ),
            ),
          ),
          Flexible(
            child: buildTaiwaneseField("藥名"),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          // When the user presses the button, show an alert dialog containing
          // the text that the user has entered into the text field.
          onPressed: () async {
            await loadAsset(taiwanessController.text);
            Navigator.popAndPushNamed(context, '/showmedicine');
          },
          child: const Icon(Icons.text_fields),
        ));
  }

  Widget buildTaiwaneseField(txt) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: TextField(
        controller: taiwanessController, // 為了獲得TextField中的value
        decoration: InputDecoration(
          fillColor: Colors.white,
          // 背景顏色，必須結合filled: true,才有效
          filled: true,
          // 重點，必須設定為true，fillColor才有效
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)), // 設定邊框圓角弧度
            borderSide: BorderSide(
              color: Colors.black87, // 設定邊框的顏色
              width: 2.0, // 設定邊框的粗細
            ),
          ),
          // when user choose the TextField
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red, // 設定邊框的顏色
                width: 2, // 設定邊框的粗細
              )),
          hintText: txt,
          // 提示文字
        ),
      ),
    );
  }
}

class ShowMedicineInPage extends StatefulWidget {
  const ShowMedicineInPage({Key? key}) : super(key: key);

  @override
  State<ShowMedicineInPage> createState() => _ShowMedicineInPage();
}

class _ShowMedicineInPage extends State<ShowMedicineInPage> {
  final player = SoundPlayer();

  @override
  void initState() {
    super.initState();
    player.init();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future play(String pathToReadAudio) async {
    await player.play(pathToReadAudio);
    setState(() {
      player.init();
      player.isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('查詢結果'),
        backgroundColor: Color(0xFF18b6b2),
      ),
      drawer: MyDrawer(),
      body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: nameCh.length,
          itemBuilder: (BuildContext context, int index) {
            return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: Text(nameCh[index],
                                style: TextStyle(fontSize: 30, color: Colors.blue)),
                          ),
                          Flexible(
                              flex: 1,
                              child: IconButton(
                                  icon: Icon(Icons.volume_up),
                                  iconSize: 20,
                                  onPressed: () async {
                                    String strings = indication[index];
                                    if (strings.isEmpty) return;

                                    if (Language == '中文') {
                                      if (sex == 'female') {
                                        Text2SpeechFlutter().flutterTts.setVoice(
                                            {"ssmlGender": "cmn-TW-Standard-A"});
                                        print(await Text2SpeechFlutter()
                                            .flutterTts
                                            .getVoices);

                                        await Text2SpeechFlutter().speak(strings);
                                      } else {
                                        Text2SpeechFlutter().flutterTts.setVoice(
                                            {"name": "ta-in-x-taf-network"});
                                        await Text2SpeechFlutter().speak(strings);
                                      }
                                    } else {
                                      await Text2Speech()
                                          .connect(play, strings, sex);
                                      // player.init();
                                      setState(() {
                                        // player.isPlaying;
                                      });
                                    }
                                  })),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        nameEng[index],
                        style: TextStyle(fontSize: 30, color: Colors.blue),
                      ),
                    ),
                    // Flexible(
                    //   flex: 1,
                    //   child: Text(ingredient[index]),
                    // ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        indication[index],
                        style: TextStyle(fontSize: 30, color: Colors.blue),
                      ),
                    ),
                  ],
                ));
          }),
    );
  }
}

//衛教知識
class KnowledgeInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('衛教知識'),
        backgroundColor: Color(0xFF18b6b2),
      ),
      drawer: MyDrawer(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(children: [
          Container(
            height: 100,
            child: Center(
              child: TextButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/BPKnowledge');
                  },
                  child: Text(
                    "居家血壓自我監測與管理",
                    style: TextStyle(fontSize: 30, color: Colors.blue),
                  )),
            ),
          ),
          Container(
            height: 100,
            child: Center(
              child: TextButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/GKnowledge');
                  },
                  child: Text(
                    "居家血糖自我監測與管理",
                    style: TextStyle(fontSize: 30, color: Colors.blue),
                  )),
            ),
          ),
          Container(
            height: 100,
            child: Center(
              child: TextButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/QAKnowledge');
                  },
                  child: Text(
                    "腎臟病 Q&A",
                    style: TextStyle(fontSize: 30, color: Colors.blue),
                  )),
            ),
          ),
          Container(
            height: 100,
            child: Center(
              child: TextButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/foodKnowledge');
                  },
                  child: Text(
                    "飲食注意事項",
                    style: TextStyle(fontSize: 30, color: Colors.blue),
                  )),
            ),
          )
        ]),
      ),
    );
  }
}

class BPKnowledgeInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('居家血壓自我監測與管理'),
        backgroundColor: Color(0xFF18b6b2),
      ),
      drawer: MyDrawer(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(children: [
          Container(
            child: Text(
              "量血壓前的準備動作",
              style: TextStyle(fontSize: 30, color: Colors.blue),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "■測量前要先將手臂上的衣物脫下，休息 5 分鐘。\n■ 血壓計、手臂與心臟齊高，手掌向上。\n■ 第一次測量需左、右皆測、以較高值為準。\n■ 在淋浴、飲酒、飯後半小時內不要測量。\n",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          Container(
            child: Center(
              child: Text(
                "電子血壓計操作方法",
                style: TextStyle(fontSize: 30, color: Colors.blue),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "■ 打開電子血壓計開關。\n■ 固定壓脈帶於肘關節（腕關節 ) 上兩指高度的地方，並留下1-2根手指能進出的空隙。\n■ 按下加壓開關，儀器開始測量血壓。\n■ 測量結束後記錄血壓值。\n",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ]),
      ),
    );
  }
}

class GKnowledgeInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('居家血糖自我監測與管理'),
        backgroundColor: Color(0xFF18b6b2),
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            child: Text(
              '''血糖機為病患日常控制血糖於居家使用之醫療器材，但臨床上發現不少人因為血糖機未確實校正、血糖試紙受潮、過期，或使用方式不正確等因素，導致無法準確測得血糖值，影響病患健康及安危。因此，為確保儀器之準確性及有效性，血糖機平時之維護、定期校正也十分的重要。
血糖機組合主要包含四部分元件－血糖機、採血針、試紙、品管液，使用時，請詳記下列正確使用血糖機之五步驟【潔、採、校、保、維】：
一、【潔】---避免感染：血糖量測過程中涉及血液採集，應注意衛生習慣避免感染風險。
二、【採】---適當採血：採血前應對採血部位進行消毒並且保持乾燥，遵循使用說明指示進行採血，於適當的位置，採取足以判讀之血量。
三、【校】---自主校正：第一次使用儀器、每當開啟一盒新試紙及更換電池時，需搭配校正用之品管液或校正試片，以進行自主校正工作。
四、【保】---保存試片：確認檢測試片是否於有效期限內，保存於涼爽乾燥、避免陽光直射之適當環境。
五、【維】---適時維護：與定期至醫療院所量測之血糖數值比較，若出現嚴重異常或有任何疑義，則須將血糖機送回原廠商或經銷商進行維修校驗。''',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ]),
      ),
    );
  }
}

List<String> QList = [
  "問：慢性腎臟病患者的飲食？",
  "問：腎不好可以吃保健食品或維他命嗎？",
  "問：中草藥可以補腎？",
  "問：腎臟病的危險因子有那些呢?",
  "問：腎臟病患者在用藥上有甚麼須注意的地方呢?",
  "問：吃類固醇會不會影響腎臟？",
  "問：我一定要接受腎臟切片嗎？",
  "問：出現腰痛就是腎臟病的警訊嗎？",
  "問：腎臟患者鉀離子過高，有那些危險？",
  "問：尿毒症是無法治療的疾病嗎？",
  "問：解小便是泡泡尿，一定就是腎臟不好嗎 ?",
  "問：血壓控制正常了，是不是不要再吃降血壓藥了，以免傷了腎 ?",
  "問：我有腎臟病是不是代表我會腎虧？",
  "問：患有腎臟病的人未來一定要接受洗腎嗎？",
  "問：有其他方法 ( 例如另類療法 ) 對慢性腎臟病有幫助嗎？",
  "問：坊間常見的慢性腎臟病飲食及活動建議，對改善疾病的效果如何？"
];
List<String> AList = [
  "答：依照患者處於腎臟病的不同階段，以及腎功能的狀態，醫師和營養師會規劃對應的飲食指南，但一般會要求病人減少攝取蛋白質，尤其在腎臟病的第三與四階段更需注意，並且要避免吃含鈉的食物，也要少攝取磷，因為會增加腎的負擔。\n",
  "答：在保健食品方面比較擔心的是，有些成份可能沒確實標示在上面，標示不明的部份，是否會對腎臟造成傷害，這部份我們比較不清楚，所以沒辦法保證對腎臟不會造成傷害；維他命方面：慢性腎病第三期以後，醫師會幫病人補充維他命B、維他命C、葉酸等慢性腎病病人較容易流失的水溶性維他命。\n",
  "答：之前研究確定會導致腎病變的中藥為馬兜鈴酸，衛生署已經下令禁止使用，此外，很多中草藥成份不明，也不知是否會對腎臟造成傷害；西藥的好處是使用普遍、成份確實，我們能夠很清楚的知道它是否對腎臟造成傷害，如果腎功能不佳，西藥可以去做調整，中藥就無法做到，所以在慢性腎病病人上，不建議服用中草藥。\n",
  "答：高血壓、高血糖、高血脂、老化、肥胖、抽菸、有腎臟病家族史、長期服藥等。按照醫囑服用三高治療的藥物，將血糖、血壓、血脂控制好才能延緩腎功能惡化。\n",
  "答：腎臟病患者應盡量避免使用腎毒性藥物，如:\n1. 止痛藥中的非類固醇類消炎藥（NSAIDs): 盡量以乙醯胺酚(Acetaminophen)或嗎啡類止痛藥取代，若必須使用NSAIDs應盡量縮短使用天數，若因疾病需長期使用NSAIDs應定期監測腎功能。\n2. 影像檢查所使用的顯影劑: 盡量避免使用顯影劑的檢查，如果是必要的檢查，顯影劑應使用最低劑量並避免短期間內重複檢查。\n3. 某些抗生素(如：Co-trimoxazole、Aminoglycosides等)\n4. 來路不明的中草藥，若成分含馬兜鈴酸恐造成腎臟傷害。\n",
  "答：使用醫師處方的類固醇是可以治療疾病，尤其是免疫系統的腎臟病是需要類固醇藥物來改善及控制病情惡化並不是類固醇引起，而是腎臟本身病變造成。\n",
  "答：抽出0.5公分如筆心大小的腎臟組織，以顯微鏡檢查，可確定病因並預測腎臟病變的進展，以利對症下藥及日後治療。\n",
  "答：姿勢的不當或脊椎病變也會導致雙測腰部肌肉酸痛，故建議至腎臟專科作進一步檢查。\n",
  "答：鉀離子過高的徵狀包括全身無力、血壓降低、心電圖呈現變化、脈搏不規律、嚴重時會造成心室心博過速會進而心跳停止。\n",
  "答：尿毒症是慢性腎臟病未期症狀，此時腎功能只剩下15%以下，無法有效清除體內代謝物及維持體液酸鹼平衡。因為，慢性腎臟病是屬於”不可回復性”一旦進入尿毒症，不久的將來就需接受透析治療\n",
  "答：不一定，尿中有高濃度的蛋白質 ( 俗稱蛋白尿 ) 會產生泡泡尿，但是泡泡尿不一定是尿中有蛋白質。所以泡泡尿可以是腎臟疾病的初步徵象，但也有可能是其他原因引起的，仍需進一步詳細追蹤檢查。\n",
  "答：理想的血壓應維持在 130/80 mmHg 範圍內，高低起伏的血 壓會加速破壞腎臟的血管，所以不建議擅自或隨意停掉降血壓 藥，一定要由醫師決定是否可以停藥或減藥。\n",
  "答：有些民眾因為受到「腎虧」一詞的誤導，把性功能跟腎功能混為一談。引起男性的性功能障礙原因很多，譬如藥物、內分泌問題、血管病變、心理性因素，或者因為疾病如糖尿病長期血糖過高引發交感神經病變，造成性功能失調等。腎功能正常情況下，並不會造成性功能失調；但若進入腎臟衰竭或是尿毒症階段，部份患者有可能會因性荷爾蒙分泌異常、使用高血壓藥物、壓力或憂鬱等種種因素，致使性功能障礙。所以慢性腎臟病絕不等同腎虧。「腎臟病」指腎臟組織或功能受損，與中醫師講的「腎虧」是指性功能障礙，兩者並沒有關聯。\n",
  "答：不一定，不是每位腎病患者都會進入透析（洗腎 ) 治療，因為 引起腎病的原因與類型不同，或是有接受正規的醫療照護（不 聽信偏方草藥），以及目前的病程是否已經進入慢性腎臟病第 三到四階段等，都是決定未來是否會進入透析（洗腎）治療的 因素。\n",
  "答：以現代醫學標準來看，通常認為另類治療不確定有效也未必安全，但是很多人仍然用這些方法在尋求標準治療所不能提供的，例如心靈上的平靜，重新燃起對治療的另一種希望；其實任何一種另類療法如果能夠經過研究而證實有效，就能成為公認的正式醫療。大部份的另類藥物都有類似疑慮之處，例如來源、汙染、品質穩定程度、主成分活性等。不管是為了保健目的或是患病時當成輔助，首要確定無害，而且不能希望太高而蒙蔽了理智思考。\n",
  "答：一、素食\n在糖尿病（尚未腎衰竭）的研究顯示，黃豆蛋白可以減少尿蛋白和腎功能惡化。黃豆蛋白是優質蛋白又含有異黃（Isoflavones），對慢性腎臟病患來說，黃豆蛋白與動物性蛋白質（雞、鴨、魚、肉、蛋）一樣，只要適量攝取亦能提供足夠的營養。也有研究顯示，同等蛋白質量的黃豆蛋白與動物性蛋白質相比，產生的含氮廢物較低。\n二、冬蟲夏草因為是動物植物合體，所謂集天地陰陽精華，過去被用在眾多病症。根據研究有益腎臟成分是脂溶性，所以單用水煮是否能對腎臟病有任何益處，目前並不明確。\n三、天然或人工植物產品\n常見蕈類產品包括靈芝、樟芝、紅麴、納豆…等。神農本草經說靈芝：「…，多服久服不傷人，…，不老延年。」；紅麴應就是紅糟，據稱可降血糖、降血脂、降血壓；納豆是將煮熟的黃豆用稻草包裹，稻草上的枯草桿菌（納豆菌）使黃豆發酵後形成，含維生素 K 和幾種納豆酵素，對抑制血栓有益；另外如蜂膠﹖花粉﹖以上這些物質的生成，不管是天然或是人工，怎麼知道來源複不複雜﹖製備和生成過程有沒有汙染？因此，建議 CKD患者飲食以新鮮食品為主才不用擔心。\n四、尿療法\n尿療法的理論係指尿液是血漿經由腎臟濾過而來，所以無害且含有大量對人體有益物質，推論對健康有益。但是須注意尿液中含有大量的酸性代謝廢物，又含多量鹽類及其他電解質，感染的尿液就含有細菌。\n五、針灸，氣功\n氣功是一種用呼吸、身體活動和意識的調整以強身健體、防病治病、健身延年、開發潛能的身心鍛煉方法；針灸是在中醫學裏採用針刺或火灸人體穴位來治療疾病的方法，多用針法來治療急病，灸法來治療慢性病，針灸學及技術是所有另類療法中在歐美國家最具研究經驗的一門學問。但無論針灸或是氣功都並未對腎臟有特殊效益。也許修練氣功的人除了練功外，也改變了個人生活中事項，例如飲食、作息、情緒等，未必是氣功本身功效。\n六、諾麗（Noni, Morinda Citrifolia) 果汁\n據稱可以抗發炎、抗微生物、抗癌、抗黴菌、免疫調節等作用，有少數基礎研究發表在國際期刊，但未提及對腎臟病有功效。不過諾麗果汁的鉀含量高，可能導致血鉀過高，也要注意曾有飲用後急性肝炎的病例。\n"
];

class QAKnowledgeInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('腎臟病 Q&A'),
        backgroundColor: Color(0xFF18b6b2),
      ),
      drawer: MyDrawer(),
      body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: QList.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        QList[index],
                        style: TextStyle(fontSize: 20, color: Colors.blue),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AList[index],
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ));
          }),
    );
  }
}

List<String> foodTitle = [
  "1.不要吃太鹹，血壓要正常",
  "2.少吃會增加尿毒素的低生物價蛋白質",
  "3.選擇高品質的蛋白質，而且量要吃的剛剛好",
  "4.米飯麵食類等主食的量也要控制",
  "5.提供能量的食物與營養品要吃夠，營養才會好",
  "6.哪些食物可以提供能量又不會產生尿毒素？",
  "7.不要喝奶類不要吃奶製品",
  "8.少吃易導致高血磷的食物，晚期血磷高時用餐要配磷結合劑",
  "9.血鉀過高時 飲食該如何調整？"
];
List<String> food = [
  "烹調時減少鹽與醬油的使用量，不要用胡椒鹽、番茄醬、辣椒醬、豆瓣醬、沙茶醬增加調味，少喝湯，盡量不要在外面用餐，都能減少吃進的鹽量。榨菜、酸菜、泡菜、味噌、醬瓜、鹹蛋、肉燥、泡麵、鹽酥雞、泰式料理、洋芋片、海苔等，這一類食物的調味都是屬於過鹹的口味，像這樣鹹度的食物一定要避免，大約這類食物的一半鹹度才是適合有慢性腎臟病者的食物鹹度。不要吃太鹹能降低血壓也可以改善水腫，血壓控制好腎功能才不會快速惡化。\n",
  "是麵筋、麵腸、麵輪、烤麩等麵筋製成的食品，雖然也是高蛋白質食物，不過所含的蛋白質品質並不好，屬於低生物價的蛋白質，會產生較多的尿毒素，慢性腎臟病患者最好不要食用。此外，腰果、松子、杏仁、夏威夷果、花生、瓜子等堅果類與芝麻、綠豆、紅豆、蓮子、薏仁、皇帝豆、蠶豆、碗豆等也含有多量的低生物價蛋白質且磷的含量高，都會增加腎臟負擔，也要少吃。\n",
  "慢性腎臟病初期的患者（第三期以前），原則上不需要減少蛋白質的攝取量，與一般健康飲食的蛋白質建議量相同，每公斤體重 0.8 至 1.0 克，但是因為現在大多數人平日飲食的蛋白質都過量（國民營養調查的結果是每公斤體重 1.2 克），所以初期的慢性腎臟病患者，除了盡量不要吃低生物價蛋白質食物外，對於蛋與豬、雞 、鴨、魚、牛等肉類及豆腐、豆乾、豆包等高品質蛋白質食物的食用量，最好也能減少 1/3 至 1/4。\n",
  "米飯、麵條、燕麥、玉米、饅頭包子水餃及各種穀類，這些常作為日常提供飽足感與熱量的主食類，以及麵包、餅乾、蛋糕等麵粉製品與蓮藕、芋頭、馬鈴薯、南瓜等澱粉含量高的食物，也都含有大量的低生物價蛋白質，所以慢性腎臟病患者也要限量食用。這類食物中，米飯產生的尿毒素比麵條、包子饅頭、麵包等麵粉製成的食品低，所以慢性腎臟病患最好以米飯為主食少吃 麵，可以降低較多的尿毒素。有糖尿病的患者，這類食物的攝 取需依照營養師計算的量吃；沒有糖尿病的慢性腎臟病患者， 在第四期後每餐的飯量依照體重不同，大約要控制在半碗至 7 分滿，70 公斤以上的人每餐可以吃 1 碗飯。\n",
  "熱量攝取足夠時，吃進身體的蛋白質才能做最好的利用，產生最少的尿毒素。熱量不夠，人就會沒有體力、精神不好、體重減輕、身體消耗自身的肌肉來產生能量，使尿毒素上升、增加腎臟負擔。同時，熱量不足導致的營養不良也會降低免疫功能，減少身體新陳代謝需要的酵素與荷爾蒙合成，也會使腎功能惡化的速度變快。臨床上常見到慢性腎臟病後期，因為尿毒素上升累積的影響，大多數病患對於肉類的攝取量都會自然降低，所以保護慢性腎臟病患者腎功能的飲食調整中，最重要的是要攝取足夠的熱量。\n",
  "地瓜 、米粉、冬粉、粄條、太白粉、番薯粉、藕粉、 澄粉、粉圓、西谷米等富含熱量但是蛋白質含量很少的食物通常被稱為 低蛋白食物，能提供熱量但是不會產生尿毒素或產生的尿毒 素很低，每天至少要吃 1-2 碗，才會讓你有能量、有體力、精 神會比較好且體重不會減輕，是能減少尿毒素產生且讓營養 變好的食物。\n",
  "奶類與奶製品的磷含量很高，大約是肉類的 2 倍且吸收率佳， 其吸收率大於 90% 以上，而且使用鈣片類的磷結合劑並不能 有效降低奶類磷的吸收，所以慢性腎臟病患者要避免奶類與 奶製品的攝取，才能將血磷維持在理想的範圍內。因此，無論 是牛奶、羊奶、奶粉、鮮奶，以及奶類製成的優酪乳、優格、發 酵乳、起司、乳酪都要少吃。\n",
  "高蛋白質的食物都是高磷食物，所以飲食如果有減少蛋白質量，血磷通常能維持在比較理想的範圍內。下表所列出的食物都是導致高血磷的常見食物，慢性腎臟病患者要避免食用。第五期末的慢性腎臟病患，即使降低高磷食物的攝取也無法維持血磷正常，因此在用餐中要吃鈣片（磷結合劑）以降低磷的吸收才能降低血磷。\n",
  "生的食物所含的鉀離子較多，經過烹煮後，食物所含的鉀離子大部份會被煮出來流到湯汁裡，所以要少吃不必烹煮的食物，煮過的湯汁都含有很高的鉀離子，因此喝湯或用菜汁、菜湯、肉汁拌飯都是導致高血鉀的重要原因。因為歐美國家習慣吃生菜，所以教科書都說慢性腎臟病患吃的蔬菜要燙過，其實台灣人很少吃生菜，所以蔬菜只要炒過不吃菜汁即可，不需要特別燙過，愛「喝湯」才是導致腎臟病患高血鉀的最常見原因。所以不要喝燉補品、雞湯、肉湯，這些都含有很高的鉀離子，很多中藥材燉出的藥湯同樣含高量鉀離子，要特別注意。\n"
];

class foodKnowledgeInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('飲食注意事項'),
        backgroundColor: Color(0xFF18b6b2),
      ),
      drawer: MyDrawer(),
      body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: QList.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        foodTitle[index],
                        style: TextStyle(fontSize: 30, color: Colors.blue),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        food[index],
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ));
          }),
    );
  }
}

//product grid
Widget _buildGrid() => GridView.extent(
    maxCrossAxisExtent: 150,
    padding: const EdgeInsets.all(4),
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
    children: _buildGridTileList(30));
List<Container> _buildGridTileList(int count) => List.generate(
    count, (i) => Container(child: Image.network('https://picsum.photos/200')));

//Homepage List
class Friends extends StatelessWidget {
  final String name;
  const Friends(this.name);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0xFFFF355d5c),
        border:
            Border(bottom: BorderSide(width: 1.0, color: Color(0xFFFFe5fbef))),
      ),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        width: 414,
        height: 100,
        child: Text(
          name,
          style: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
