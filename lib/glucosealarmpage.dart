import 'package:Finalproject/glucosealarm_helper.dart';

import 'Eventalarm_helper.dart';
import 'theme.dart';
//import 'package:clock_app/data.dart';
import 'Eventalarm_info.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../main.dart';

class glucoseAlarmPage extends StatefulWidget {
  @override
  _glucoseAlarmPageState createState() => _glucoseAlarmPageState();

}

class _glucoseAlarmPageState extends State<glucoseAlarmPage> {

  TextEditingController event = TextEditingController();
  DateTime? _alarmTime;
  String? _alarmTimeString;
  glucoseAlarmHelper _alarmHelper = glucoseAlarmHelper();
  Future<List<AlarmInfo>>? _alarms;
  List<AlarmInfo>? _currentAlarms;
  DateTime datatime = DateTime.now();

  @override
  void initState() {
    _alarmTime = DateTime.now();
    _alarmHelper.initializeDatabase().then((value) {
      print('------database intialized');
      loadAlarms();
    });
    super.initState();
  }
  void loadAlarms() {
    _alarms = _alarmHelper.getAlarms();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("血糖鬧鐘",
        ),
        backgroundColor: Color(0xFF18b6b2),
      ),
      body:Container(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '提醒',
              style: TextStyle(
                  fontFamily: 'avenir',
                  fontWeight: FontWeight.w700,
                  color: Colors.lightBlue,
                  fontSize: 24),
            ),
            Expanded(
              child: FutureBuilder<List<AlarmInfo>>(
                future: _alarms,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _currentAlarms = snapshot.data!;
                    return ListView(
                      children: snapshot.data!.map<Widget>((alarm) {
                        var alarmdate =DateFormat('MM/d').format(alarm.alarmDateTime);
                        var alarmTime =
                        DateFormat('HH:mm aa').format(alarm.alarmDateTime);
                        var gradientColor = GradientTemplate
                            .gradientTemplate[alarm.gradientColorIndex].colors;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColor,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: gradientColor.last.withOpacity(0.4),
                                //blurRadius: 8,
                                //spreadRadius: 2,
                                offset: Offset(4, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.label,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '測血糖時間到了',
                                        style: TextStyle(
                                            fontSize: 30,
                                            color: Colors.white,
                                            fontFamily: 'avenir'),
                                      ),
                                    ],
                                  ),
                                  /*Switch(
                                  onChanged: (bool value) {},
                                  value: true,
                                  activeColor: Colors.white,
                                ),*/
                                ],
                              ),
                              /*Text(alarmdate
                                ,
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.white, fontFamily: 'avenir'),
                              ),*/
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      alarmTime,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'avenir',
                                        fontSize: 24,
                                        //fontWeight: FontWeight.w700
                                      ),
                                    ),
                                    /* Material( child:IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.white,
                                    onPressed: () {
                                      deleteAlarm(alarm.id!);
                                    }),),*/
                                    FlatButton(
                                        color:  Colors.yellow,
                                        onPressed: () {
                                          deleteAlarm(alarm.id!);
                                        },child:Text("刪除",style:
                                    TextStyle(fontSize: 20),))]),
                            ],
                          ),
                        );
                      }).followedBy([
                        if (_currentAlarms!.length < 5)
                          DottedBorder(
                            strokeWidth: 2,
                            color: CustomColors.clockOutline,
                            borderType: BorderType.RRect,
                            radius: Radius.circular(24),
                            dashPattern: [5, 4],
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: CustomColors.clockBG,
                                borderRadius:
                                BorderRadius.all(Radius.circular(24)),
                              ),
                              child:

                              FlatButton(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                onPressed: ()  async{
                                  datatime=DateTime.now();
                                  _alarmTimeString =
                                      DateFormat('HH:mm d MMM').format(DateTime.now());
                                  showModalBottomSheet(
                                    useRootNavigator: true,
                                    // isScrollControlled:true,
                                    context: context,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                    ),
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setModalState) {
                                          return Container(
                                            padding: const EdgeInsets.all(32),
                                            child: Column(
                                              // mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(child: Text('測血糖時間',style: TextStyle(fontSize: 32),)),
                                                Flexible(child: Text('   ')),
                                                //Flexible(child: Text('設定',style: TextStyle(fontSize: 20,color: Colors.blue))),
                                                Row(children: [

                                                  Flexible(child: Text('設定時間:   ',style: TextStyle(fontSize: 25,color: Colors.blue),)),
                                                  RaisedButton(
                                                    color:  Colors.green,
                                                    onPressed: () async {
                                                      var selectedTime =
                                                      await showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                        TimeOfDay.now(),
                                                        //DateTime.now();
                                                      );
                                                      if (selectedTime != null) {
                                                        final now = datatime;
                                                        var selectedDateTime =
                                                        DateTime(
                                                            now.year,
                                                            now.month,
                                                            now.day,
                                                            selectedTime.hour,
                                                            selectedTime
                                                                .minute);
                                                        _alarmTime =
                                                            selectedDateTime;
                                                        setModalState(() {
                                                          _alarmTimeString =
                                                              DateFormat('HH:mm d MMM' )
                                                                  .format(
                                                                  selectedDateTime);
                                                        });
                                                      }
                                                    },
                                                    child: Text(
                                                      _alarmTimeString!,
                                                      style:
                                                      TextStyle(fontSize: 32),
                                                    ),
                                                  ),],),
                                                Flexible(child: Text(' ')),
                                                FloatingActionButton.extended(
                                                  onPressed: onSaveAlarm,
                                                  icon: Icon(Icons.alarm),
                                                  label: Text('儲存'),
                                                ),

                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                  // scheduleAlarm();
                                },
                                child: Column(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/add_alarm.png',
                                      scale: 1.5,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '新增血糖提醒',
                                      style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontFamily: 'avenir'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                              child: Text(
                                '只能新增五個鬧鐘',
                                style:
                                TextStyle(fontSize:30,color: Colors.black),
                              )),
                      ]).toList(),
                    );
                  }
                  return Center(
                    child: Text(
                      'Loading..',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),);
  }

  void scheduleAlarm(
      DateTime scheduledNotificationDateTime,AlarmInfo alarmInfo) async {
    final sound ='a_long_cold_sting.wav';
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channels id',
      'channel NAME',
      'Channel for Alarm notification',
      icon: 'codex_logo',
      playSound: true,
      enableLights: true,
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound(sound.split('.').first),
      largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      // sound: 'a_long_cold_sting.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(0, '提醒', '量血糖時間到了',
        scheduledNotificationDateTime, await platformChannelSpecifics);
    //await flutterLocalNotificationsPlugin.periodicallyShow(0, '提醒', '量血壓時間到了',
    //    RepeatInterval.daily, platformChannelSpecifics);
  }

  void onSaveAlarm() {

    DateTime scheduleAlarmDateTime;
    //if (_alarmTime!.isAfter(DateTime.now()))
    scheduleAlarmDateTime = _alarmTime!;
    //else
    //scheduleAlarmDateTime = _alarmTime!.add(Duration(days: 1));


    var alarmInfo = AlarmInfo(
        alarmDateTime: scheduleAlarmDateTime,
        gradientColorIndex: _currentAlarms!.length,
        title: '量血糖時間到了'

    );
    _alarmHelper.insertAlarm(alarmInfo);
    scheduleAlarm(scheduleAlarmDateTime, alarmInfo);
    Navigator.pop(context);
    loadAlarms();
  }

  void deleteAlarm(int id) {
    print(id);
    _alarmHelper.delete(id);
    //unsubscribe for notification
    loadAlarms();
  }

  Future<DateTime?> pickDate() => showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1999),
      lastDate: DateTime(2050));
}