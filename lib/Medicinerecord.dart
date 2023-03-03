//import 'dart:ui';
import 'dart:math';
import 'package:Finalproject/calendar_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'MedrecorddataModel.dart';
import 'package:Finalproject/Medrecorddatacard.dart';
import 'package:Finalproject/Medrecorddb.dart';
import 'sound_player.dart';
import 'sound_recorder.dart';
import 'socket_stt.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'medicinealarmpage.dart';

class MedicineRecordInPage extends StatefulWidget {
  @override
  _MedicineRecordInPageState createState() => _MedicineRecordInPageState();
}

class _MedicineRecordInPageState extends State<MedicineRecordInPage> {
  TextEditingController MedicinenameController = TextEditingController();
  TextEditingController EattimeController = TextEditingController();
  TextEditingController MedremarkController = TextEditingController();
  TextEditingController recognitionController = TextEditingController();

  List<DataModel> datas = [];

  bool fetching = true;
  int currentIndex = 0;
  final recorder = SoundRecorder();

  // get soundPlayer
  final player = SoundPlayer();

  late DB db;

  @override
  void initState() {
    super.initState();
    db = DB();
    getData2();
    recorder.init();
    player.init();
  }

  void getData2() async {
    datas = await db.getData();
    setState(() {
      fetching = false;
    });
  }

  @override
  void dispose() {
    recorder.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("藥品紀錄"),
        backgroundColor: Color(0xFF18b6b2),
      ),
      drawer: MyDrawer(),

      floatingActionButton: Row(children: [
        Text("                "),
        RaisedButton(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            color:Colors.pinkAccent,
            onPressed: (){
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => medicineAlarmPage()),
              );
            },
            child: Text('新增提醒鬧鐘',
              style:
              TextStyle(fontSize: 20,color: Colors.white),)),
        Text("     "),
        FloatingActionButton(
        onPressed: () {
          showMyDilogue();
        },
        child: Icon(Icons.add),
      ),],),
      body: fetching
          ? Center(
        child: CircularProgressIndicator(),
      ) : ListView.builder(
        itemCount: datas.length,
        itemBuilder: (context, index) =>
            DataCard(
              data: datas[index],
              edit: edit,
              index: index,
              delete: delete,
            ),
      ),


    );
  }

  void showMyDilogue() async {
     showDialog(
        context: context,
        builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(14),
              content: Container(
                height: 200,
                child: Column(
                  children: [
                    Flexible(
                        child: Row(children: [
                          Flexible(child: buildOutputFieldmedname()),
                          buildRecordmedname()
                        ],)
                    ),
                    Flexible(
                        child: Row(children: [
                          Flexible(child: buildOutputFieldmedeattime()),
                          buildRecordmedeattime()
                        ],)
                    ),

                    Flexible(
                        child: Row(children: [
                          Flexible(child: buildOutputFieldmedremark()),
                          buildRecordmedremark()
                        ],)
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {

                    DataModel dataLocal = DataModel(
                        Medicinename: MedicinenameController.text,
                        Eattime: EattimeController.text,
                        Medremark: MedremarkController.text);
                    db.insertData(dataLocal);
                    if (datas.isEmpty) {
                      dataLocal.id = 1;
                    }
                    else
                      dataLocal.id = datas[datas.length - 1].id! + 1;
                    print(datas.length);
                    print(dataLocal.id);
                    setState(() {
                      datas.add(dataLocal);
                    });
                    MedicinenameController.clear();
                    EattimeController.clear();
                    MedremarkController.clear();
                    Navigator.pop(context);
                  },
                  child: Text("儲存"),
                ),
              ],
            );
          });
  }

  void showMyDilogueUpdate() async {
    // get SoundRecorder
    final recorder = SoundRecorder();
    // get soundPlayer
    final player = SoundPlayer();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(20),
            content: Container(
              height: 200,
              child: Column(
                children: [
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldmedname()), buildRecordmedname()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldmedeattime()), buildRecordmedeattime()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldmedremark()), buildRecordmedremark()],)
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  DataModel newData = datas[currentIndex];
                  newData.Medremark = MedremarkController.text;
                  newData.Eattime = EattimeController.text;
                  newData.Medicinename = MedicinenameController.text;
                  db.update(newData, newData.id!);
                  setState(() {});
                  print(newData.id);
                  MedicinenameController.clear();
                  EattimeController.clear();
                  MedremarkController.clear();
                  Navigator.pop(context);
                },
                child: Text("更新"),
              ),
            ],
          );
        });
  }

  void edit(index) {
    currentIndex = index;
    MedicinenameController.text = datas[index].Medicinename;
    EattimeController.text = datas[index].Eattime;
    MedremarkController.text = datas[index].Medremark;
    showMyDilogueUpdate();
  }

  void delete(int index) {
    db.delete(datas[index].id!);
    print(index);
    print(datas.length);
    setState(() {
      datas.removeAt(index);
    });
    print(datas.length);
  }

  // build the button of recorder
  Widget buildRecordmedname() {
    // whether is recording
    final isRecording = recorder.isRecording;
    // if recording => icon is Icons.stop
    // else => icon is Icons.mic
    final icon = isRecording ? Icons.stop : Icons.mic;
    // if recording => color of button is red
    // else => color of button is white
    final primary = isRecording ? Colors.red : Colors.white;
    // if recording => text in button is STOP
    // else => text in button is START
    final text = isRecording ? '停止' : '錄音';
    // if recording => text in button is white
    // else => color of button is black
    final onPrimary = isRecording ? Colors.white : Colors.black;

    return CircleAvatar(
        backgroundColor: onPrimary,
        child:IconButton(
      icon: Icon(icon),
      // 當 Iicon 被點擊時執行的動作
      onPressed: () async {
        // getTemporaryDirectory(): 取得暫存資料夾，這個資料夾隨時可能被系統或使用者操作清除
        Directory tempDir = await path_provider.getTemporaryDirectory();
        // define file directory
        String path = '${tempDir.path}/SpeechRecognition2.wav';
        // 控制開始錄音或停止錄音
        await recorder.toggleRecording(path);
        // When stop recording, pass wave file to socket
        if (!recorder.isRecording) {
          //if (recognitionLanguage == "Taiwanese") {
          // if recognitionLanguage == "Taiwanese" => use Minnan model
          // setTxt is call back function
          // parameter: wav file path, call back function, model
          await Speech2Text().connect(path, setTxt, "Minnan");
          // glSocket.listen(dataHandler, cancelOnError: false);
          //} else {
          // if recognitionLanguage == "Chinese" => use MTK_ch model
          //  await Speech2Text().connect(path, setTxt, "MTK_ch");
          // }
        }
        // set state is recording or stop
        setState(() {
          recorder.isRecording;
        });
      },
    ));
  }

// set recognitionController.text function
  void setTxt(taiTxt) {
    setState(() {
      MedicinenameController.text = taiTxt;
      //MedicinenameController.text = taiTxt;
    });
  }


  Widget buildOutputFieldmedname() {
    //MedicinenameController.text= recognitionController.text;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: TextField(
        controller: MedicinenameController, // 設定 controller
        enabled: true, // 設定不能接受輸入
        decoration:
        const InputDecoration(
          labelText: "藥品名稱",
          //fillColor: Colors.blue, // 背景顏色，必須結合filled: true,才有效
          filled: true, // 重點，必須設定為true，fillColor才有效
          //disabledBorder: OutlineInputBorder(
          // borderRadius: BorderRadius.all(Radius.circular(10)), // 設定邊框圓角弧度
          //borderSide: BorderSide(
          // color: Colors.black87, // 設定邊框的顏色
          // width: 10, // 設定邊框的粗細
          // ),
          // ),
        ),
      ),
    );
  }

  // build the button of recorder
  Widget buildRecordmedeattime() {
    // whether is recording
    final isRecording = recorder.isRecording;
    // if recording => icon is Icons.stop
    // else => icon is Icons.mic
    final icon = isRecording ? Icons.stop : Icons.mic;
    // if recording => color of button is red
    // else => color of button is white
    final primary = isRecording ? Colors.red : Colors.white;
    // if recording => text in button is STOP
    // else => text in button is START
    final text = isRecording ? '停止' : '錄音';
    // if recording => text in button is white
    // else => color of button is black
    final onPrimary = isRecording ? Colors.white : Colors.black;

    return CircleAvatar(
        backgroundColor: onPrimary,
        child:IconButton(
          icon: Icon(icon),
          // 當 Iicon 被點擊時執行的動作
          onPressed: () async {
            // getTemporaryDirectory(): 取得暫存資料夾，這個資料夾隨時可能被系統或使用者操作清除
            Directory tempDir = await path_provider.getTemporaryDirectory();
            // define file directory
            String path = '${tempDir.path}/SpeechRecognition2.wav';
            // 控制開始錄音或停止錄音
            await recorder.toggleRecording(path);
            // When stop recording, pass wave file to socket
            if (!recorder.isRecording) {
              //if (recognitionLanguage == "Taiwanese") {
              // if recognitionLanguage == "Taiwanese" => use Minnan model
              // setTxt is call back function
              // parameter: wav file path, call back function, model
              await Speech2Text().connect(path, setTxteat, "Minnan");
              // glSocket.listen(dataHandler, cancelOnError: false);
              //} else {
              // if recognitionLanguage == "Chinese" => use MTK_ch model
              //  await Speech2Text().connect(path, setTxt, "MTK_ch");
              // }
            }
            // set state is recording or stop
            setState(() {
              recorder.isRecording;
            });
          },
        ));
  }

// set recognitionController.text function
  void setTxteat(taiTxt) {
    setState(() {
      EattimeController.text = taiTxt;
      //MedicinenameController.text = taiTxt;
    });
  }


  Widget buildOutputFieldmedeattime() {
    //MedicinenameController.text= recognitionController.text;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: TextField(
        controller: EattimeController, // 設定 controller
        enabled: true, // 設定不能接受輸入
        decoration:
        const InputDecoration(
          labelText: "食用時間",
          //fillColor: Colors.blue, // 背景顏色，必須結合filled: true,才有效
          filled: true, // 重點，必須設定為true，fillColor才有效
          //disabledBorder: OutlineInputBorder(
          // borderRadius: BorderRadius.all(Radius.circular(10)), // 設定邊框圓角弧度
          //borderSide: BorderSide(
          // color: Colors.black87, // 設定邊框的顏色
          // width: 10, // 設定邊框的粗細
          // ),
          // ),
        ),
      ),
    );
  }

  // build the button of recorder
  Widget buildRecordmedremark() {
    // whether is recording
    final isRecording = recorder.isRecording;
    // if recording => icon is Icons.stop
    // else => icon is Icons.mic
    final icon = isRecording ? Icons.stop : Icons.mic;
    // if recording => color of button is red
    // else => color of button is white
    final primary = isRecording ? Colors.red : Colors.white;
    // if recording => text in button is STOP
    // else => text in button is START
    final text = isRecording ? '停止' : '錄音';
    // if recording => text in button is white
    // else => color of button is black
    final onPrimary = isRecording ? Colors.white : Colors.black;

    return CircleAvatar(
        backgroundColor: onPrimary,
        child:IconButton(
          icon: Icon(icon),
          // 當 Iicon 被點擊時執行的動作
          onPressed: () async {
            // getTemporaryDirectory(): 取得暫存資料夾，這個資料夾隨時可能被系統或使用者操作清除
            Directory tempDir = await path_provider.getTemporaryDirectory();
            // define file directory
            String path = '${tempDir.path}/SpeechRecognition2.wav';
            // 控制開始錄音或停止錄音
            await recorder.toggleRecording(path);
            // When stop recording, pass wave file to socket
            if (!recorder.isRecording) {
              //if (recognitionLanguage == "Taiwanese") {
              // if recognitionLanguage == "Taiwanese" => use Minnan model
              // setTxt is call back function
              // parameter: wav file path, call back function, model
              await Speech2Text().connect(path, setTxtremark, "Minnan");
              // glSocket.listen(dataHandler, cancelOnError: false);
              //} else {
              // if recognitionLanguage == "Chinese" => use MTK_ch model
              //  await Speech2Text().connect(path, setTxt, "MTK_ch");
              // }
            }
            // set state is recording or stop
            setState(() {
              recorder.isRecording;
            });
          },
        ));
  }

// set recognitionController.text function
  void setTxtremark(taiTxt) {
    setState(() {
      MedremarkController.text = taiTxt;
      //MedicinenameController.text = taiTxt;
    });
  }


  Widget buildOutputFieldmedremark() {
    //MedicinenameController.text= recognitionController.text;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: TextField(
        controller: MedremarkController, // 設定 controller
        enabled: true, // 設定不能接受輸入
        decoration:
        const InputDecoration(
          labelText: "備註",
          //fillColor: Colors.blue, // 背景顏色，必須結合filled: true,才有效
          filled: true, // 重點，必須設定為true，fillColor才有效
          //disabledBorder: OutlineInputBorder(
          // borderRadius: BorderRadius.all(Radius.circular(10)), // 設定邊框圓角弧度
          //borderSide: BorderSide(
          // color: Colors.black87, // 設定邊框的顏色
          // width: 10, // 設定邊框的粗細
          // ),
          // ),
        ),
      ),
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
                  color: Colors.white
              ),
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
            onTap: () {
              Navigator.popAndPushNamed(context, '/profile');
            },
          ),
          ListTile(
            title: Text('血壓測量'),
            onTap: () {
              Navigator.popAndPushNamed(context, '/bloodpressuretest');
            },
          ),
          ListTile(
            title: Text('血壓折線圖'),
            onTap: () {
              Navigator.popAndPushNamed(context, '/bloodpressurechart');
            },
          ),
          ListTile(
            title: Text('血糖測量'),
            onTap: () {
              Navigator.popAndPushNamed(context, '/glucosetest');
            },
          ),
          ListTile(
            title: Text('血糖折線圖'),
            onTap: () {
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
          ) ,
          ListTile(
            title: Text('衛教知識'),
            onTap: () {
              Navigator.popAndPushNamed(context, '/knowledge');
            },
          )
        ],
      ),
    );
  }
}