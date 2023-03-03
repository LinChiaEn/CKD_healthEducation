import 'package:flutter/material.dart';

import 'ExtramedicinedataModel.dart';

class ExtramedDataCard extends StatelessWidget {
  const ExtramedDataCard({
    Key? key,
    required this.data,
    required this.edit,
    required this.index,
    required this.delete,
  }) : super(key: key);
  final ExtraDataModel data;
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
        title: Text(data.Extramedicinename),
        subtitle: Column(children:[
          Text(data.ExtraEattime),
          Text(data.ExtraBuyplace),
          Text(data.ExtraMedremark),
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