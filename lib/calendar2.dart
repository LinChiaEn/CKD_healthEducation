import 'dart:core';

import 'package:flutter/material.dart';
import 'calendar_model.dart';
import 'calendardb.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'sound_player.dart';
import 'sound_recorder.dart';
import 'socket_stt.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';

import 'Eventalarm_page.dart';

String _name = "";
class Calendar2 extends StatefulWidget {

  @override
  _Calendar2State createState() => _Calendar2State();
}

class _Calendar2State extends State<Calendar2> {
  TextEditingController recognitionController = TextEditingController();
  DateTime _selectedDay = DateTime.now();

  CalendarController _calendarController = CalendarController();
  Map<DateTime, List<dynamic>> _events = {};
  List<CalendarItem> _data = [];

  List<dynamic> _selectedEvents = [];
  List<Widget> get _eventWidgets => _selectedEvents.map((e) => events(e)).toList();
  final recorder = SoundRecorder();

  // get soundPlayer
  final player = SoundPlayer();
  void initState() {
    super.initState();
    DB.init().then((value) => _fetchEvents());
    _calendarController = CalendarController();
    recorder.init();
    player.init();
  }

  void dispose(){
    recorder.dispose();
    player.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  Widget events(var d){
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              )),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[Text(d,
                style: const TextStyle(fontSize:40, fontWeight: FontWeight.bold),),
                IconButton(icon: FaIcon(FontAwesomeIcons.trashAlt, color: Colors.redAccent, size: 15,), onPressed: ()=> _deleteEvent(d))
              ]) ),
    );  }

  void _onDaySelected(DateTime day, List events,_) {
    setState(() {
      _selectedDay = day;
      _selectedEvents = events;
    });
  }

  void _create(BuildContext context) {

    var content = TextField(
      controller: recognitionController, // 設定 controller
      enabled: true,
      style: GoogleFonts.montserrat(
          color: Color.fromRGBO(105, 105, 108, 1), fontSize: 16),
      //autofocus: true,
      decoration: InputDecoration(
        labelStyle: GoogleFonts.montserrat(
            color: Color.fromRGBO(59, 57, 60, 1),
            fontSize: 18,
            fontWeight: FontWeight.normal),
        labelText: '事件',
      ),
     /* onChanged: (value) {
       // if(recognitionController.text==""){_name = value;}
        value=recognitionController.text;
        _name=value;
      },*/
    );
    var btn = FlatButton(
      child: Text('储存',
          style: GoogleFonts.montserrat(
              color: Color.fromRGBO(59, 57, 60, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold)),
      onPressed: () => {_addEvent(recognitionController.text),recognitionController.clear()}
    );
    var cancelButton = FlatButton(
        child: Text('取消',
            style: GoogleFonts.montserrat(
                color: Color.fromRGBO(59, 57, 60, 1),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.of(context).pop(false));
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Text("新增事件", style: GoogleFonts.montserrat(
                      color: Color.fromRGBO(59, 57, 60, 1),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
                  Container(padding: EdgeInsets.all(20), child:Row(children:[Flexible(child: content), buildRecord()]) ),
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[btn, cancelButton]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchEvents() async{
    _events = {};
    List<Map<String, dynamic>> _results = await DB.query(CalendarItem.table);
    _data = _results.map((item) => CalendarItem.fromMap(item)).toList();
    _data.forEach((element) {
      DateTime formattedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(element.date.toString())));
      if(_events.containsKey(formattedDate)){
        _events[formattedDate]!.add(element.name.toString());
      }
      else{
        _events[formattedDate] = [element.name.toString()];
      }
    }
    );
    setState(() {});
  }

  void _addEvent(String event) async{
    CalendarItem item = CalendarItem(
        date: _selectedDay.toString(),
        name: event
    );
    await DB.insert(CalendarItem.table, item);
    _selectedEvents.add(event);
    _fetchEvents();

    Navigator.pop(context);
  }

  // Delete doesnt refresh yet, thats it, then done!
  void _deleteEvent(String s){
    List<CalendarItem> d = _data.where((element) => element.name == s).toList();
    print(d);
    if(d.length == 1){
      DB.delete(CalendarItem.table, d[0]);
      _selectedEvents.removeWhere((e) => e == s);
      _fetchEvents();
    }
  }

  Widget calendar(){
    return Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        width: double.infinity,
        /*decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(colors: [Colors.red[600]!, Colors.red[400]!]),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: new Offset(0.0, 5)
              )
            ]
        ),*/
        child: TableCalendar(
          startingDayOfWeek: StartingDayOfWeek.monday,
          // initialCalendarFormat: CalendarFormat.month,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            //canEventMarkersOverflow: true,
            markersColor: Colors.red,
            weekdayStyle: TextStyle(color: Colors.black),

            todayColor: Colors.yellow,
            todayStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            selectedColor: Colors.blue,
            outsideWeekendStyle: TextStyle(color: Colors.black),
            outsideStyle: TextStyle(color: Colors.black),
            weekendStyle: TextStyle(color: Colors.black),
          ),
          onDaySelected: _onDaySelected,
          calendarController: _calendarController,
          events: _events,
          // startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            centerHeaderTitle: true,
            formatButtonDecoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20.0),
            ),
            formatButtonTextStyle: TextStyle(color: Colors.black),
            formatButtonShowsNext: false,
          ),

        )
    );
  }

  Widget eventTitle(){
    if(_selectedEvents.length == 0){
      return Container(
        padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
        child:Text("沒有事件",style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold)),
      );
    }
    return Container(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
      child:Text("事件", style: GoogleFonts.montserrat(
          color: Colors.black,
          fontSize: 25,
          fontWeight: FontWeight.bold)),
    );
  }
  // build the button of recorder
  Widget buildRecord() {
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
    final onPrimary = isRecording ? Colors.red : Colors.black;
   //return FlatButton(onPressed:  child: child)
    return CircleAvatar(
        backgroundColor: onPrimary,
        child:IconButton(
          icon: Icon(icon),
          // 當 Iicon 被點擊時執行的動作
          onPressed: () async {
            // getTemporaryDirectory(): 取得暫存資料夾，這個資料夾隨時可能被系統或使用者操作清除
            Directory tempDir = await path_provider.getTemporaryDirectory();
            // define file directory
            String path = '${tempDir.path}/SpeechRecognitio.wav';
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
       recognitionController.text =taiTxt;
      //MedicinenameController.text = taiTxt;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('行事曆'),
        backgroundColor: Color(0xFF18b6b2),
      ),
      drawer: MyDrawer(),
      body:  ListView(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          /*Container(
            padding: EdgeInsets.all(15),
            child:Text("行事曆", style: Theme.of(context).primaryTextTheme.headline1),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [

              Text("行事曆", style: Theme.of(context).primaryTextTheme.headline1),
              Consumer<ThemeNotifier>(
                  builder: (context, notifier, child) => IconButton(icon: notifier.isDarkTheme ? FaIcon(FontAwesomeIcons.moon, size: 20, color: Colors.white,) : Icon(Icons.wb_sunny), onPressed: () => {notifier.toggleTheme()}))
            ],),
          ),*/

          calendar(),
          Row(
            children: [Text("                          "
                "                                 "),
              RaisedButton(

                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                color:Colors.pinkAccent,
                onPressed: (){
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => AlarmPage()),
                  );
                },
                child: Text('新增事件鬧鐘',
                  style:
                TextStyle(fontSize: 20,color: Colors.white),)),],
          ),

          eventTitle(),
          Column(children:_eventWidgets),
          SizedBox(height:60)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _create(context),
        child: Icon(Icons.add, color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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