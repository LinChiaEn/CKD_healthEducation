import 'package:flutter/material.dart';

import 'HealthfooddataModel.dart';

class HealthfoodDataCard extends StatelessWidget {
  const HealthfoodDataCard({
    Key? key,
    required this.data,
    required this.edit,
    required this.index,
    required this.delete,
  }) : super(key: key);
  final HealthfoodDataModel data;
  final Function edit;
  final Function delete;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: IconButton(
              onPressed: () {
                edit(index);
              },
              icon: Icon(Icons.edit)),
        ),
        title: Text(data.Healthfoodname),
        subtitle: Column(children:[
          Text(data.HealthfoodEattime),
          Text(data.HealthfoodBuyplace),
          Text(data.Healthfoodremark),
        ]),
        trailing: CircleAvatar(
            backgroundColor: Colors.red,
            child: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () {
                delete(index);
              },
            )),
      ),
    );
  }
}