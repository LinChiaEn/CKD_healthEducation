
//import 'dart:ui';
import 'dart:math';
import 'package:Finalproject/calendar_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ExtramedicinedataModel.dart';
import 'package:Finalproject/Extramedicinedatacard.dart';
import 'package:Finalproject/Extramedicinedb.dart';
import 'package:Finalproject/Healthfooddatacard.dart';
import 'package:Finalproject/HealthfooddataModel.dart';
import 'package:Finalproject/Healthfooddb.dart';
import 'sound_player.dart';
import 'sound_recorder.dart';
import 'socket_stt.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';

class ExtramedicineInPage extends StatefulWidget {
  @override
  _ExtramedicineInPageState createState() => _ExtramedicineInPageState();
}

class _ExtramedicineInPageState extends State<ExtramedicineInPage> {
  TextEditingController ExtramedicinenameController = TextEditingController();
  TextEditingController ExtraBuyplaceController = TextEditingController();
  TextEditingController ExtraEattimeController = TextEditingController();
  TextEditingController ExtraMedremarkController = TextEditingController();
  TextEditingController HealthfoodnameController = TextEditingController();
  TextEditingController HealthfoodBuyplaceController = TextEditingController();
  TextEditingController HealthfoodEattimeController = TextEditingController();
  TextEditingController HealthfoodremarkController = TextEditingController();

  TextEditingController recognitionController = TextEditingController();

  List<ExtraDataModel> extrameddatas =[] ;
  List<HealthfoodDataModel> healthfooddatas =[] ;
  bool extrafetching = true;
  int extracurrentIndex = 0;
  bool healthfetching = true;
  int healthcurrentIndex = 0;
  late ExtraDB extrameddb;
  late HealthfoodDB healthfooddb;
  final recorder = SoundRecorder();

  // get soundPlayer
  final player = SoundPlayer();

  @override
  void initState()  {
    super.initState();
    extrameddb = ExtraDB();
    healthfooddb = HealthfoodDB();
    getData2();
    recorder.init();
    player.init();
  }

  void getData2() async {
   extrameddatas = await extrameddb.getData();
   healthfooddatas = await healthfooddb.getData();
    setState(() {
      extrafetching = false;
      healthfetching = false;

    });
  }

  void dispose() {
    recorder.dispose();
    player.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("保健食品以及額外藥品"),
        backgroundColor: Color(0xFF18b6b2),
      ),
      drawer: MyDrawer(),
      body:Column(
          children:[
            new Text("保健食品",style: TextStyle(fontSize: 30 ,fontWeight: FontWeight.w700, color: Colors.blue)),
        Flexible(child: healthfetching
            ? Center(
          child: CircularProgressIndicator(),
        ): ListView.builder(
          itemCount: healthfooddatas.length,
          itemBuilder: (context, index) => HealthfoodDataCard(
            data: healthfooddatas[index],
            edit: foodedit,
            index: index,
            delete: fooddelete,
          ),
        ),),
        RaisedButton(
            child: Text("新增保健食品",style: TextStyle(fontSize: 20 )),
            onPressed: () async {
              foodshowMyDilogue();
        }),
       new Text("一般成藥與指示藥",style: TextStyle(fontSize: 30 ,fontWeight: FontWeight.w700, color: Colors.blue)),
        Flexible(child: extrafetching
            ? Center(
          child: CircularProgressIndicator(),
        ): ListView.builder(
          itemCount: extrameddatas.length,
          itemBuilder: (context, index) => ExtramedDataCard(
            data: extrameddatas[index],
            edit: extraedit,
            index: index,
            delete: extradelete,
          ),
        ),),
            RaisedButton(
                child: Text("新增額外藥品",style: TextStyle(fontSize: 20 )),
                onPressed: () async {
                  ExtrashowMyDilogue();
                }),
        ])
    );
  }
  void ExtrashowMyDilogue() async {
    // get SoundRecorder
    final recorder = SoundRecorder();
    // get soundPlayer
    final player = SoundPlayer();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(14),
            content: Container(
              height: 300,
              child: Column(
                children: [
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldextramedname()), buildRecordextramedname()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldextraeat()), buildRecordextraeat()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldextrabuy()), buildRecordextrabuy()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldextraremark()), buildRecordextraremark()],)
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: ()  {
                  ExtraDataModel dataLocal = ExtraDataModel(
                      Extramedicinename: ExtramedicinenameController.text,
                      ExtraEattime: ExtraEattimeController.text,
                      ExtraBuyplace: ExtraBuyplaceController.text ,
                      ExtraMedremark: ExtraMedremarkController.text);
                  extrameddb.insertData(dataLocal);
                  if(extrameddatas.isEmpty){dataLocal.id = 1;}
                  else dataLocal.id = extrameddatas[extrameddatas.length -1].id! + 1;
                  print(extrameddatas.length);
                  //print(extrameddatas[extrameddatas.length -1].id! + 1);
                  setState(() {
                    extrameddatas.add(dataLocal);
                  });
                  ExtramedicinenameController.clear();
                  ExtraEattimeController.clear();
                  ExtraBuyplaceController.clear();
                  ExtraMedremarkController.clear();
                  Navigator.pop(context);
                },
                child: Text("儲存"),
              ),
            ],
          );
        });
  }

  void ExtrashowMyDilogueUpdate() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(14),
            content: Container(
              height: 300,
              child: Column(
                children: [
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldextramedname()), buildRecordextramedname()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldextraeat()), buildRecordextraeat()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldextrabuy()), buildRecordextrabuy()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldextraremark()), buildRecordextraremark()],)
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed : ()  {
                  ExtraDataModel newData = extrameddatas[extracurrentIndex];
                  newData.ExtraMedremark = ExtraMedremarkController.text;
                  newData.ExtraBuyplace = ExtraBuyplaceController.text;
                  newData.ExtraEattime = ExtraEattimeController.text;
                  newData.Extramedicinename = ExtramedicinenameController.text;
                  extrameddb.update(newData, newData.id!);
                  setState(() {});
                  print(newData.id);
                  ExtramedicinenameController.clear();
                  ExtraEattimeController.clear();
                  ExtraBuyplaceController.clear();
                  ExtraMedremarkController.clear();
                  Navigator.pop(context);
                },
                child: Text("更新"),
              ),
            ],
          );
        });
  }

  void extraedit(index) {
    extracurrentIndex = index;
    ExtramedicinenameController.text = extrameddatas[index].Extramedicinename;
    ExtraEattimeController.text = extrameddatas[index].ExtraEattime;
    ExtraBuyplaceController.text=extrameddatas[index].ExtraBuyplace;
    ExtraMedremarkController.text = extrameddatas[index].ExtraMedremark;
    ExtrashowMyDilogueUpdate();
  }

  void extradelete(int index) {
    extrameddb.delete(extrameddatas[index].id!);
    print(index);
    setState(() {
      extrameddatas.removeAt(index);
    });
  }
  // build the button of recorder
  Widget buildRecordextramedname() {
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
              await Speech2Text().connect(path, setTxtextramedname, "Minnan");
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
  void setTxtextramedname(taiTxt) {
    setState(() {
      ExtramedicinenameController.text = taiTxt;
      //MedicinenameController.text = taiTxt;
    });
  }


  Widget buildOutputFieldextramedname() {
    //MedicinenameController.text= recognitionController.text;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: TextField(
        controller: ExtramedicinenameController, // 設定 controller
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
  Widget buildRecordextraeat() {
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
              await Speech2Text().connect(path, setTxtextraeat, "Minnan");
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
  void setTxtextraeat(taiTxt) {
    setState(() {
      ExtraEattimeController.text = taiTxt;
      //MedicinenameController.text = taiTxt;
    });
  }


  Widget buildOutputFieldextraeat() {
    //MedicinenameController.text= recognitionController.text;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: TextField(
        controller: ExtraEattimeController, // 設定 controller
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
  Widget buildRecordextrabuy() {
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
              await Speech2Text().connect(path, setTxtextrabuy, "Minnan");
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
  void setTxtextrabuy(taiTxt) {
    setState(() {
      ExtraBuyplaceController.text = taiTxt;
      //MedicinenameController.text = taiTxt;
    });
  }


  Widget buildOutputFieldextrabuy() {
    //MedicinenameController.text= recognitionController.text;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: TextField(
        controller: ExtraBuyplaceController, // 設定 controller
        enabled: true, // 設定不能接受輸入
        decoration:
        const InputDecoration(
          labelText: "購買地點",
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
  Widget buildRecordextraremark() {
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
              await Speech2Text().connect(path, setTxtextraremark, "Minnan");
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
  void setTxtextraremark(taiTxt) {
    setState(() {
      ExtraMedremarkController.text = taiTxt;
      //MedicinenameController.text = taiTxt;
    });
  }


  Widget buildOutputFieldextraremark() {
    //MedicinenameController.text= recognitionController.text;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: TextField(
        controller: ExtraMedremarkController, // 設定 controller
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

  void foodshowMyDilogue() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(14),
            content: Container(
              height: 300,
              child: Column(
                children: [
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldfoodname()), buildRecordfoodname()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldfoodeat()), buildRecordfoodeat()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldfoodbuy()), buildRecordfoodbuy()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldfoodremark()), buildRecordfoodremark()],)
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: ()  {
                  HealthfoodDataModel dataLocal = HealthfoodDataModel(
                      Healthfoodname: HealthfoodnameController.text,
                      HealthfoodEattime: HealthfoodEattimeController.text,
                      HealthfoodBuyplace: HealthfoodBuyplaceController.text ,
                      Healthfoodremark: HealthfoodremarkController.text);
                  healthfooddb.insertData(dataLocal);
                  dataLocal.id = healthfooddatas.length;
                  if(healthfooddatas.isEmpty){dataLocal.id = 1;}
                  else dataLocal.id = healthfooddatas[healthfooddatas.length -1].id! + 1;
                  print(healthfooddatas.length);
                 // print(healthfooddatas[healthfooddatas.length -1].id! + 1);
                  setState(() {
                    healthfooddatas.add(dataLocal);
                  });
                  HealthfoodnameController.clear();
                  HealthfoodEattimeController.clear();
                  HealthfoodBuyplaceController.clear();
                  HealthfoodremarkController.clear();
                  Navigator.pop(context);
                },
                child: Text("儲存"),
              ),
            ],
          );
        });
  }
  void foodshowMyDilogueUpdate() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(14),
            content: Container(
              height: 300,
              child: Column(
                children: [
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldfoodname()), buildRecordfoodname()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldfoodeat()), buildRecordfoodeat()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldfoodbuy()), buildRecordfoodbuy()],)
                  ),
                  Flexible(
                      child: Row(children: [Flexible(child: buildOutputFieldfoodremark()), buildRecordfoodremark()],)
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed : ()  {
                  HealthfoodDataModel newData = healthfooddatas[healthcurrentIndex];
                  newData.Healthfoodremark = HealthfoodremarkController.text;
                  newData.HealthfoodBuyplace = HealthfoodBuyplaceController.text;
                  newData.HealthfoodEattime = HealthfoodEattimeController.text;
                  newData.Healthfoodname = HealthfoodnameController.text;
                  healthfooddb.update(newData, newData.id!);
                  setState(() {});
                  print(newData.id);
                  HealthfoodnameController.clear();
                  HealthfoodEattimeController.clear();
                  HealthfoodBuyplaceController.clear();
                  HealthfoodremarkController.clear();
                  Navigator.pop(context);
                },
                child: Text("更新"),
              ),
            ],
          );
        });
  }

  // build the button of recorder
  Widget buildRecordfoodname() {
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
              await Speech2Text().connect(path, setTxtfoodname, "Minnan");
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
  void setTxtfoodname(taiTxt) {
    setState(() {
      HealthfoodnameController.text = taiTxt;
      //MedicinenameController.text = taiTxt;
    });
  }


  Widget buildOutputFieldfoodname() {
    //MedicinenameController.text= recognitionController.text;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: TextField(
        controller: HealthfoodnameController, // 設定 controller
        enabled: true, // 設定不能接受輸入
        decoration:
        const InputDecoration(
          labelText: "保健食品名稱",
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
  Widget buildRecordfoodeat() {
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
              await Speech2Text().connect(path, setTxtfoodeat, "Minnan");
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
  void setTxtfoodeat(taiTxt) {
    setState(() {
      HealthfoodEattimeController.text = taiTxt;
      //MedicinenameController.text = taiTxt;
    });
  }


  Widget buildOutputFieldfoodeat() {
    //MedicinenameController.text= recognitionController.text;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: TextField(
        controller: HealthfoodEattimeController, // 設定 controller
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
  Widget buildRecordfoodbuy() {
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
              await Speech2Text().connect(path, setTxtfoodbuy, "Minnan");
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
  void setTxtfoodbuy(taiTxt) {
    setState(() {
      HealthfoodBuyplaceController.text = taiTxt;
      //MedicinenameController.text = taiTxt;
    });
  }


  Widget buildOutputFieldfoodbuy() {
    //MedicinenameController.text= recognitionController.text;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: TextField(
        controller: HealthfoodBuyplaceController, // 設定 controller
        enabled: true, // 設定不能接受輸入
        decoration:
        const InputDecoration(
          labelText: "購買地點",
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
  Widget buildRecordfoodremark() {
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
              await Speech2Text().connect(path, setTxtfoodremark, "Minnan");
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
  void setTxtfoodremark(taiTxt) {
    setState(() {
      HealthfoodremarkController.text = taiTxt;
      //MedicinenameController.text = taiTxt;
    });
  }


  Widget buildOutputFieldfoodremark() {
    //MedicinenameController.text= recognitionController.text;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: TextField(
        controller: HealthfoodremarkController, // 設定 controller
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

  void foodedit(index) {
    healthcurrentIndex = index;
    HealthfoodnameController.text = healthfooddatas[index].Healthfoodname;
    HealthfoodEattimeController.text = healthfooddatas[index].HealthfoodEattime;
    HealthfoodBuyplaceController.text=healthfooddatas[index].HealthfoodBuyplace;
    HealthfoodremarkController.text = healthfooddatas[index].Healthfoodremark;
    foodshowMyDilogueUpdate();
  }

  void fooddelete(int index) {
    healthfooddb.delete(healthfooddatas[index].id!);
    print(index);
    setState(() {
      healthfooddatas.removeAt(index);
    });
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