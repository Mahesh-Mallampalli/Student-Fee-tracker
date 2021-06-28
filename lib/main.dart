import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Professional Cricket Academy",
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  HomePage createState() => HomePage();
}

class HomePage extends State<MyStatefulWidget> {
  String selected = DateFormat('yyyy').format(DateTime.now()) + " " + DateFormat('MMMM').format(DateTime.now());
  String selectMonth = DateFormat('MMMM').format(DateTime.now());
  String selectYear = DateFormat('yyyy').format(DateTime.now());
  List<String> year = [
    "2021",
    "2022",
    "2023",
    "2024",
    "2025",
    "2026"
  ];
  List<String> month = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  List<String> allFeesP = [];
  bool isDue = true;
  bool isupdate = false;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(
          "Professional Cricket Academy",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: PageView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FeeReceipt()));
                },
                child: Image(
                  image: AssetImage('assets/FeeReceipt.jpg'),
                ),
              ),
              Divider(),
              FlatButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
                },
                child: Image(
                  image: AssetImage('assets/Search.jpg'),
                ),
              ),
              Divider(),
              FlatButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Players()));
                },
                child: Image(
                  image: AssetImage('assets/Profile.jpg'),
                ),
              ),
            ],
          ),
          Container(
              child: Column(
            children: <Widget>[
              Container(
                color: Colors.blue[900],
                child: ListTile(
                  onTap: null,
                  leading: IconButton(
                    icon: Icon(
                      Icons.today,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        //callDatePicker();
                      });
                    },
                  ),
                  title: Row(
                    children: <Widget>[
                      DropdownButton<String>(
                        underline: SizedBox(),
                        value: selectYear,
                        onChanged: (String string) {
                          setState(() {
                            selectYear = string;
                            selected = selectYear + " " + selectMonth;
                          });
                        },
                        selectedItemBuilder: (BuildContext context) {
                          return year.map<Widget>((String item) {
                            return Center(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        items: year.map((String item) {
                          return DropdownMenuItem<String>(
                            child: Text(
                              '$item',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            value: item,
                          );
                        }).toList(),
                      ),
                      SizedBox(width: 20),
                      DropdownButton<String>(
                        underline: SizedBox(),
                        value: selectMonth,
                        onChanged: (String string) {
                          setState(() {
                            selectMonth = string;
                            selected = selectYear + " " + selectMonth;
                          });
                        },
                        selectedItemBuilder: (BuildContext context) {
                          return month.map<Widget>((String item) {
                            return Center(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        items: month.map((String item) {
                          return DropdownMenuItem<String>(
                            child: Text(
                              '$item',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            value: item,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.blue[900],
                child: ListTile(
                  title: Row(
                    children: <Widget>[
                      isDue == true
                          ? Text(
                              "Due List ",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : Text(
                              "Paid List ",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                      Switch(
                        inactiveTrackColor: Colors.green,
                        activeColor: Colors.red,
                        value: isDue,
                        onChanged: (value) {
                          setState(() {
                            isDue = value;
                          });
                        },
                      ),
                    ],
                  ),
                  trailing: IconButton(
                      icon: Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _generatePDF(context);
                      }),
                ),
              ),
              Container(
                child: Expanded(
                  child: isDue == true
                      ? StreamBuilder(
                          stream: Firestore.instance.collection('players').where('allFees', arrayContains: selected).where('isActive', isEqualTo: true).snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                //builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                    itemCount: snapshot.data.documents.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Card(
                                        color: Colors.white,
                                        elevation: 2.0,
                                        child: ListTile(
                                          leading: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                (index + 1).toString(),
                                                style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
                                              ),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  minWidth: 100,
                                                  minHeight: 100,
                                                  maxWidth: 100,
                                                  maxHeight: 100,
                                                ),
                                                child: snapshot.data.documents.elementAt(index)['photoName'] != ''
                                                    ? CachedNetworkImage(
                                                        //placeholder: (context, url) => CircularProgressIndicator(),
                                                        imageUrl: snapshot.data.documents.elementAt(index)['photoName'],
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Image(
                                                        image: AssetImage('assets/photo.png'),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          title: Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  snapshot.data.documents.elementAt(index)['lastName'],
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontFamily: 'Roboto',
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  snapshot.data.documents.elementAt(index)['lastPaid'],
                                                  style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "ID: " + snapshot.data.documents.elementAt(index)['category'],
                                                  style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Switch(
                                            activeColor: Colors.green,
                                            value: snapshot.data.documents.elementAt(index)['isActive'],
                                            onChanged: (value) {
                                              setState(() {
                                                showAlertDialog(context, value, Player.fromMapObject(snapshot.data.documents.elementAt(index).data));
                                              });
                                            },
                                          ),
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFees(Player.fromMapObject(snapshot.data.documents.elementAt(index).data))));
                                          },
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  debugPrint('Loading...');
                                  return Center(
                                    child: Text('Loading...'),
                                  );
                                }
                              },
                            );
                          },
                        )
                      : StreamBuilder(
                          stream: Firestore.instance.collection('players').where('fees', arrayContains: selected).snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                //builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                    itemCount: snapshot.data.documents.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Card(
                                        color: Colors.white,
                                        elevation: 2.0,
                                        child: ListTile(
                                          leading: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                (index + 1).toString(),
                                                style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
                                              ),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  minWidth: 100,
                                                  minHeight: 100,
                                                  maxWidth: 100,
                                                  maxHeight: 100,
                                                ),
                                                child: snapshot.data.documents.elementAt(index)['photoName'] != ''
                                                    ? CachedNetworkImage(
                                                        //placeholder: (context, url) => CircularProgressIndicator(),
                                                        imageUrl: snapshot.data.documents.elementAt(index)['photoName'],
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Image(
                                                        image: AssetImage('assets/photo.png'),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          title: Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  snapshot.data.documents.elementAt(index)['lastName'],
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontFamily: 'Roboto',
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  snapshot.data.documents.elementAt(index)['lastPaid'],
                                                  style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "ID: " + snapshot.data.documents.elementAt(index)['category'],
                                                  style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFees(Player.fromMapObject(snapshot.data.documents.elementAt(index).data))));
                                          },
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  debugPrint('Loading...');
                                  return Center(
                                    child: Text('Loading...'),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  void updatetoFirestore(bool value, Player player) async {
    allFeesP = player.allFees;
    allFeesP.removeWhere((item) => item == selected);
    player.allFees = allFeesP;

    allFeesP = player.fees;
    allFeesP.add(selected + ": Absent");
    player.fees = allFeesP;
    player.uptodate = isupdate;

    if (player.uptodate == true) {
      player.isActive = value;
    }

    await Firestore.instance.collection('players').document(player.id).updateData(player.toMap());

    setState(() {
      isupdate = false;
    });
  }

  showAlertDialog(BuildContext context, bool value, Player playerD) {
    Widget cancelButton = FlatButton(
      child: Text(
        "cancel",
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue[900],
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "ok",
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue[900],
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () {
        updatetoFirestore(value, playerD);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "Absent",
        style: TextStyle(
          fontSize: 18,
          color: Colors.blue[900],
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
      ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("1.Are you sure " + playerD.firstName + " " + playerD.lastName + " is absent for " + selected + "?"),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Text("2.Did he clear Due Fees?"),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: <Widget>[
                        Switch(
                          inactiveTrackColor: Colors.red,
                          activeColor: Colors.green,
                          value: isupdate,
                          onChanged: (value) {
                            setState(() {
                              isupdate = value;
                            });
                          },
                        ),
                        isupdate == true ? Text("Yes", style: TextStyle(color: Colors.green)) : Text("No", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _generatePDF(context) async {
    var doc;
    if (isDue)
      doc = await Firestore.instance.collection('players').where("allFees", arrayContains: selected).where("isActive", isEqualTo: true).getDocuments();
    else
      doc = await Firestore.instance.collection('players').where("fees", arrayContains: selected).getDocuments();

    int count = doc.documents.length;
    List<Player> data = new List();
    for (int i = 0; i < count; i++) {
      data.add(Player.fromMapObject(doc.documents.elementAt(i).data));
    }

    final pdfLib.Document pdf = pdfLib.Document(deflate: zlib.encode);

    pdf.addPage(
      pdfLib.MultiPage(
          //pageFormat: pdfLib.PdfPageFormat.a4,
          crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
          footer: (pdfLib.Context context) {
            return pdfLib.Container(
                alignment: pdfLib.Alignment.centerRight,
                //margin: const EdgeInsets.only(top: 10.0),
                child: pdfLib.Text('Page ${context.pageNumber} of ${context.pagesCount}'));
          },
          build: (context) => [
                pdfLib.Header(
                  level: 0,
                  child: pdfLib.Container(
                    child: pdfLib.Column(
                      children: <pdfLib.Widget>[
                        pdfLib.Text('Professional Cricket Academy', textScaleFactor: 2),
                        isDue == true ? pdfLib.Text(selected + " Due List") : pdfLib.Text(selected + " Paid List"),
                      ],
                    ),
                  ),
                ),
                pdfLib.Table.fromTextArray(context: context, data: <List<String>>[
                  <String>[
                    'SL No',
                    'Name',
                    'Age',
                    'Contact Number'
                  ],
                  ...data.map((item) => [
                        (data.indexOf(item) + 1).toString(),
                        item.firstName + " " + item.lastName,
                        (((DateTime.now().difference(item.dob).inDays) / 365).floor()).toString(),
                        item.type
                      ])
                ]),
              ]),
    );

    final String dir = (await getExternalStorageDirectory()).path;
    String path;
    if (isDue == true)
      path = '$dir/' + selected + "Due List" + ".pdf";
    else
      path = '$dir/' + selected + "Paid List" + ".pdf";
    final File file = File(path);
    pdf.save().then((value) async {
      await file.writeAsBytes(value);
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(path, selected),
      ),
    );
  }
}

class Players extends StatefulWidget {
  Players();
  @override
  State<StatefulWidget> createState() {
    return PlayerState();
  }
}

class PlayerState extends State<Players> {
  Player player;
  List<String> fees = [];
  List<String> allFees = [
    "2021 January",
    "2021 February",
    "2021 March",
    "2021 April",
    "2021 May",
    "2021 June",
    "2021 July",
    "2021 August",
    "2021 September",
    "2021 October",
    "2021 November",
    "2021 December",
    "2022 January",
    "2022 February",
    "2022 March",
    "2022 April",
    "2022 May",
    "2022 June",
    "2022 July",
    "2022 August",
    "2022 September",
    "2022 October",
    "2022 November",
    "2022 December",
    "2023 January",
    "2023 February",
    "2023 March",
    "2023 April",
    "2023 May",
    "2023 June",
    "2023 July",
    "2023 August",
    "2023 September",
    "2023 October",
    "2023 November",
    "2023 December",
    "2024 January",
    "2024 February",
    "2024 March",
    "2024 April",
    "2024 May",
    "2024 June",
    "2024 July",
    "2024 August",
    "2024 September",
    "2024 October",
    "2024 November",
    "2024 December",
    "2025 January",
    "2025 February",
    "2025 March",
    "2025 April",
    "2025 May",
    "2025 June",
    "2025 July",
    "2025 August",
    "2025 September",
    "2025 October",
    "2025 November",
    "2025 December",
    "2026 January",
    "2026 February",
    "2026 March",
    "2026 April",
    "2026 May",
    "2026 June",
    "2026 July",
    "2026 August",
    "2026 September",
    "2026 October",
    "2026 November",
    "2026 December"
  ];
  PlayerState();
  TextEditingController searchControll = TextEditingController();
  bool isSearching = false;
  String searchKey = " ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: isSearching == false
            ? Text(
                "Player Profiles",
                style: TextStyle(fontSize: 17),
              )
            : TextField(
                style: TextStyle(color: Colors.white),
                controller: searchControll,
                onChanged: (value) {
                  setState(() {
                    searchKey = value;
                  });
                },
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: 'Search Here',
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
        actions: <Widget>[
          isSearching == false
              ? IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                    });
                  },
                ),
        ],
      ),
      body: isSearching == false
          ? StreamBuilder(
              stream: Firestore.instance.collection('players').orderBy('firstName').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    //builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: ListTile(
                              leading: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 100,
                                  minHeight: 100,
                                  maxWidth: 100,
                                  maxHeight: 100,
                                ),
                                child: snapshot.data.documents.elementAt(index)['photoName'] != ''
                                    ? CachedNetworkImage(
                                        //placeholder: (context, url) => CircularProgressIndicator(),
                                        imageUrl: snapshot.data.documents.elementAt(index)['photoName'],
                                        fit: BoxFit.contain,
                                      )
                                    : Image(
                                        image: AssetImage('assets/photo.png'),
                                      ),
                              ),
                              title: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      snapshot.data.documents.elementAt(index)['firstName'] + " " + snapshot.data.documents.elementAt(index)['lastName'],
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Column(
                                      children: <Widget>[
                                        //Align(
                                        //  alignment: Alignment.centerLeft,
                                        //  child: Text(
                                        //    "Role: " + snapshot.data.documents.elementAt(index)['category'],
                                        //    style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                        //  ),
                                        //),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Age: " + (((DateTime.now().difference(snapshot.data.documents.elementAt(index)['dob'].toDate()).inDays) / 365).floor()).toString() + " years",
                                            style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "ID: " + snapshot.data.documents.elementAt(index)['category'],
                                            style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: GestureDetector(
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.grey,
                                  ),
                                  onTap: () {
                                    showAlertDialog(context, Player.fromMapObject(snapshot.data.documents.elementAt(index).data));
                                  }),
                              onTap: () {
                                updateNote(snapshot.data.documents.elementAt(index)['id']);
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      debugPrint('Loading...');
                      return Center(
                        child: Text('Loading...'),
                      );
                    }
                  },
                );
              },
            )
          : StreamBuilder(
              stream: Firestore.instance.collection('players').where('lastName', isGreaterThanOrEqualTo: searchKey).where('lastName', isLessThan: searchKey + 'z').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    //builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: ListTile(
                              leading: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 100,
                                  minHeight: 100,
                                  maxWidth: 100,
                                  maxHeight: 100,
                                ),
                                child: snapshot.data.documents.elementAt(index)['photoName'] != ''
                                    ? CachedNetworkImage(
                                        //placeholder: (context, url) => CircularProgressIndicator(),
                                        imageUrl: snapshot.data.documents.elementAt(index)['photoName'],
                                        fit: BoxFit.contain,
                                      )
                                    : Image(
                                        image: AssetImage('assets/photo.png'),
                                      ),
                              ),
                              title: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      snapshot.data.documents.elementAt(index)['firstName'] + " " + snapshot.data.documents.elementAt(index)['lastName'],
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Column(
                                      children: <Widget>[
                                        // Align(
                                        //  alignment: Alignment.centerLeft,
                                        //  child: Text(
                                        //    "Role: " + snapshot.data.documents.elementAt(index)['category'],
                                        //    style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                        //  ),
                                        // ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Age: " + (((DateTime.now().difference(snapshot.data.documents.elementAt(index)['dob'].toDate()).inDays) / 365).floor()).toString() + " years",
                                            style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "ID: " + snapshot.data.documents.elementAt(index)['category'],
                                            style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: GestureDetector(
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.grey,
                                  ),
                                  onTap: () {
                                    showAlertDialog(context, Player.fromMapObject(snapshot.data.documents.elementAt(index).data));
                                  }),
                              onTap: () {
                                updateNote(snapshot.data.documents.elementAt(index)['id']);
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      debugPrint('Loading...');
                      return Center(
                        child: Text('Loading...'),
                      );
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fees.clear();
          fees.add('Joined on ' + DateFormat('dd MMMM yyyy').format(DateTime.now()));
          int i = 0;
          while (allFees[i] != DateFormat('yyyy').format(DateTime.now()) + " " + DateFormat('MMMM').format(DateTime.now())) {
            allFees.removeAt(i);
          }
          navigateToNoteDetail(Player('', '', '', DateTime.now(), DateTime.now(), '', '', fees, allFees, 'Joined on ' + DateFormat('dd MMMM yyyy').format(DateTime.now()), false, true, ''), " Add ");
        },
        tooltip: 'Add',
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue[900],
      ),
    );
  }

  void navigateToNoteDetail(Player player, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PlayerProfile(player, title);
    }));
  }

  void _delete(String id) async {
    await Firestore.instance.collection('players').document(id).delete();
  }

  void updateNote(String id) async {
    var doc = await Firestore.instance.collection('players').document(id).get();
    setState(() {
      player = Player.fromMapObject(doc.data);
    });
    navigateToNoteDetail(player, 'Update Profile');
  }

  showAlertDialog(BuildContext context, Player playerD) {
    Widget cancelButton = FlatButton(
      child: Text(
        "No",
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue[900],
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Yes",
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue[900],
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () {
        _delete(playerD.id);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Delete",
        style: TextStyle(
          fontSize: 18,
          color: Colors.blue[900],
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text("Are you sure to delete " + playerD.firstName + " " + playerD.lastName + "'s profile?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class PlayerProfile extends StatefulWidget {
  Player player;
  String title;
  PlayerProfile(this.player, this.title);

  @override
  State<StatefulWidget> createState() {
    return PlayerProfileState(player, title);
  }
}

class PlayerProfileState extends State<PlayerProfile> {
  String appBarTitle;
  Player player;
  File imageFile;
  Image example;
  String imageString;
  String url = "hi";
  DateTime dob;
  final _formKey = GlobalKey<FormState>();

  final databaseReference = Firestore.instance;

  TextEditingController titleController = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController idController = TextEditingController();

  PlayerProfileState(this.player, this.appBarTitle);

  void callDatePicker() async {
    var order = await getDate();
    if (order != null) {
      setState(() {
        var finaldate = order;
        dob = order; //DateFormat('yyyy-MM-dd').format(finaldate);
        updateDob();
      });
    }
  }

  Future<DateTime> getDate() {
    return showDatePicker(
      context: context,
      initialDate: dob,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: new ThemeData(
            primaryColor: Colors.blueGrey[200],
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey[200],
              //onPrimary: Colors.white,
              surface: Colors.blueGrey[200],
              onSurface: Colors.blueGrey[900],
            ),
            //dialogBackgroundColor:Colors.blue[900],
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = player.firstName;
    lastName.text = player.lastName;
    contactController.text = player.type;
    idController.text = player.category;
    //priceController.text = note.price.toString();
    //quantityController.text = note.quantity.toString();
    //selectedItem = player.category;
    dob = player.dob;

    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[200],
          title: Text(appBarTitle),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                moveToLastScreen();
              }),
        ),
        body: Form(
          key: _formKey,
          child: Stack(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: Colors.blueGrey[200],
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 300,
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: Text("Choose option",
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.blueGrey[700],
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
                                          )),
                                    ),
                                  ),
                                  Divider(),
                                  Align(
                                    alignment: Alignment.center,
                                    child: FlatButton(
                                      child: Text("Camera",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.blueGrey[700],
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                          )),
                                      onPressed: () {
                                        _openCamera(context);
                                      },
                                    ),
                                  ),
                                  Divider(),
                                  Align(
                                    alignment: Alignment.center,
                                    child: FlatButton(
                                      child: Text('Gallery',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.blueGrey[700],
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                          )),
                                      onPressed: () {
                                        _openGallery(context);
                                      },
                                    ),
                                  ),
                                  Divider(),
                                  Align(
                                    alignment: Alignment.center,
                                    child: FlatButton(
                                      child: Text('Remove Image',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.blueGrey[700],
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                          )),
                                      onPressed: () {
                                        setState(() {
                                          Navigator.of(context).pop();
                                          deleteImage(player.photoName);
                                          player.photoName = '';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 20.0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _decideImageView(),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 15),
                            child: TextFormField(
                              controller: titleController,
                              cursorColor: Colors.blueGrey[700],
                              onChanged: (value) {
                                updateTitle();
                              },
                              decoration: InputDecoration(
                                  labelText: 'First Name',
                                  labelStyle: TextStyle(
                                    color: Colors.blueGrey[800],
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(5.0),
                                    borderSide: BorderSide(color: Colors.blueGrey[800]),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  )),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 15, 15),
                            child: TextFormField(
                              controller: lastName,
                              cursorColor: Colors.blueGrey[700],
                              onChanged: (value) {
                                updateLastName();
                              },
                              decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  labelStyle: TextStyle(
                                    color: Colors.blueGrey[800],
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(5.0),
                                    borderSide: BorderSide(color: Colors.blueGrey[800]),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  )),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 30),
                            child: TextFormField(
                              controller: contactController,
                              cursorColor: Colors.blueGrey[700],
                              onChanged: (value) {
                                updateType();
                              },
                              decoration: InputDecoration(
                                  labelText: 'Contact number',
                                  labelStyle: TextStyle(
                                    color: Colors.blueGrey[800],
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(5.0),
                                    borderSide: BorderSide(color: Colors.blueGrey[800]),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  )),
                              // validator: (value) {
                              //    if (value.isEmpty) {
                              //        return 'Please enter some text';
                              //    }
                              //    return null;
                              // },
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 15, 30),
                            child: TextFormField(
                              controller: idController,
                              cursorColor: Colors.blueGrey[700],
                              onChanged: (value) {
                                updateId();
                              },
                              decoration: InputDecoration(
                                  labelText: 'ID Number',
                                  labelStyle: TextStyle(
                                    color: Colors.blueGrey[800],
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(5.0),
                                    borderSide: BorderSide(color: Colors.blueGrey[800]),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  )),
                              // validator: (value) {
                              //    if (value.isEmpty) {
                              //        return 'Please enter some text';
                              //    }
                              //    return null;
                              // },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: Text(
                              'Date of Birth',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey[800],
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          DateFormat('yyyy-MM-dd').format(player.dob),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueGrey[800],
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            Icons.today,
                            color: Colors.blueGrey[200],
                          ),
                          onPressed: () {
                            callDatePicker();
                          },
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        child: FlatButton(
                          color: Colors.blueGrey[700],
                          textColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.blueGrey[700],
                              ),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            appBarTitle,
                            style: TextStyle(fontSize: 18.0),
                          ),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                debugPrint("Save button clicked");
                                _save();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  Widget _decideImageView() {
    if (imageFile != null) {
      return Container(
        height: 200,
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(imageFile, fit: BoxFit.contain),
        ),
      );
    } else if (player.photoName == '') {
      return Container(
        height: 200,
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image(
            image: AssetImage('assets/photo.png'),
            fit: BoxFit.contain,
          ),
        ),
      );
    } else {
      return Container(
        height: 200,
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(
            //placeholder: (context, url) => CircularProgressIndicator(),
            imageUrl: player.photoName,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
  }
  Future deleteImage(String fileUrl) async{
    String filePath = fileUrl.replaceAll("/o/", '*');
    filePath = filePath.replaceAll("?","*");
    filePath = filePath.split("*")[1];
                                                    
    StorageReference storageReferance = FirebaseStorage.instance.ref();
    storageReferance.child(filePath).delete();
    
  }
  Future _openGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      imageFile = picture;
    });

    String fileName = imageFile.path.split('/').last;
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile);

    if (uploadTask.isSuccessful || uploadTask.isComplete) {
      url = await firebaseStorageRef.getDownloadURL();
      updatePhoto();
    } else if (uploadTask.isInProgress) {
      onLoading();
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      url = await taskSnapshot.ref.getDownloadURL();
      updatePhoto();
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    }
  }

  Future _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      imageFile = picture;
    });

    String fileName = imageFile.path.split('/').last;
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile);

    if (uploadTask.isSuccessful || uploadTask.isComplete) {
      url = await firebaseStorageRef.getDownloadURL();
      updatePhoto();
    } else if (uploadTask.isInProgress) {
      onLoading();
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      url = await taskSnapshot.ref.getDownloadURL();
      updatePhoto();
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    }
  }

  void onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Center(
            child: Column(
              children: <Widget>[
                CircularProgressIndicator(),
                Text(" "),
                Text("Uploading..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void updateTitle() {
    player.firstName = titleController.text;
  }

  void updateLastName() {
    player.lastName = lastName.text;
  }

  void updateDob() {
    player.dob = dob;
  }

  void updatePhoto() {
    player.photoName = url;
    imageFile = null;
  }

  void updateType() {
    player.type = contactController.text;
  }

  void updateId() {
    player.category = idController.text;
  }

  void _save() async {
    try {
      moveToLastScreen();
      int result;

      if (player.id == '') {
        DocumentReference ref = Firestore.instance.collection('players').document();
        String di = ref.documentID;
        player.id = di;
        await Firestore.instance.collection('players').document(di).setData(player.toMap());
        //_showAlertDialog('Status','Success');
      } else {
        String iD = player.id;
        await Firestore.instance.collection('players').document(iD).updateData(player.toMap());
        //_showAlertDialog('Status','Success');
      }
    } catch (e) {
      _showAlertDialog('Status', e);
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}

class FeeReceipt extends StatefulWidget {
  FeeReceipt();

  @override
  State<StatefulWidget> createState() {
    return FeeReceiptState();
  }
}

class FeeReceiptState extends State<FeeReceipt> {
  FeeReceiptState();
  String selectMonth = DateFormat('MMMM').format(DateTime.now());
  String selectYear = DateFormat('yyyy').format(DateTime.now());
  List<String> year = [
    "2021",
    "2022",
    "2023",
    "2024",
    "2025",
    "2026"
  ];
  List<String> month = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  List<String> feesP = [];
  List<String> allFeesP = [];

  TextEditingController searchControll = TextEditingController();
  bool isSearching = false;
  bool isActive;
  String searchKey = " ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: isSearching == false
            ? Text(
                "Fee Receipt",
                style: TextStyle(fontSize: 17),
              )
            : TextField(
                style: TextStyle(color: Colors.white),
                controller: searchControll,
                onChanged: (value) {
                  setState(() {
                    searchKey = value;
                  });
                },
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: 'Search Here',
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
        actions: <Widget>[
          isSearching == false
              ? IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                    });
                  },
                ),
        ],
      ),
      body: isSearching == false
          ? StreamBuilder(
              stream: Firestore.instance.collection('players').orderBy('firstName').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    //builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: ListTile(
                              leading: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 100,
                                  minHeight: 100,
                                  maxWidth: 100,
                                  maxHeight: 100,
                                ),
                                child: snapshot.data.documents.elementAt(index)['photoName'] != ''
                                    ? CachedNetworkImage(
                                        //placeholder: (context, url) => CircularProgressIndicator(),
                                        imageUrl: snapshot.data.documents.elementAt(index)['photoName'],
                                        fit: BoxFit.contain,
                                      )
                                    : Image(
                                        image: AssetImage('assets/photo.png'),
                                      ),
                              ),

                              title: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      snapshot.data.documents.elementAt(index)['firstName'] + " " + snapshot.data.documents.elementAt(index)['lastName'],
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Age: " + (((DateTime.now().difference(snapshot.data.documents.elementAt(index)['dob'].toDate()).inDays) / 365).floor()).toString() + " years",
                                      style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),

                              //trailing: GestureDetector(
                              // child:Icon(Icons.delete, color: snapshot.data.documents.elementAt(index)['type'] == 'Heading'?Colors.blueGrey[200]: Colors.grey,),
                              // onTap: (){

                              //  }
                              //),
                              onTap: () {
                                _showAlertDialog(Player.fromMapObject(snapshot.data.documents.elementAt(index).data));
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      debugPrint('Loading...');
                      return Center(
                        child: Text('Loading...'),
                      );
                    }
                  },
                );
              },
            )
          : StreamBuilder(
              stream: Firestore.instance.collection('players').where('lastName', isGreaterThanOrEqualTo: searchKey).where('lastName', isLessThan: searchKey + 'z').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    //builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: ListTile(
                              leading: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 100,
                                  minHeight: 100,
                                  maxWidth: 100,
                                  maxHeight: 100,
                                ),
                                child: snapshot.data.documents.elementAt(index)['photoName'] != ''
                                    ? CachedNetworkImage(
                                        //placeholder: (context, url) => CircularProgressIndicator(),
                                        imageUrl: snapshot.data.documents.elementAt(index)['photoName'],
                                        fit: BoxFit.contain,
                                      )
                                    : Image(
                                        image: AssetImage('assets/photo.png'),
                                      ),
                              ),

                              title: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      snapshot.data.documents.elementAt(index)['firstName'] + " " + snapshot.data.documents.elementAt(index)['lastName'],
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Age: " + (((DateTime.now().difference(snapshot.data.documents.elementAt(index)['dob'].toDate()).inDays) / 365).floor()).toString() + " years",
                                      style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),

                              //trailing: GestureDetector(
                              //child:Icon(Icons.delete, color: snapshot.data.documents.elementAt(index)['type'] == 'Heading'?Colors.blueGrey[200]: Colors.grey,),
                              // onTap: (){

                              // }
                              //),
                              onTap: () {
                                _showAlertDialog(Player.fromMapObject(snapshot.data.documents.elementAt(index).data));
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      debugPrint('Loading...');
                      return Center(
                        child: Text('Loading...'),
                      );
                    }
                  },
                );
              },
            ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context);
  }

  void saveToFirebase(Player player) async {
    String id;
    setState(() {
      player.lastPaid = selectYear + " " + selectMonth;
      feesP = player.fees;
      feesP.add(player.lastPaid);
      player.fees = feesP;
      allFeesP = player.allFees;
      allFeesP.removeWhere((item) => item == player.lastPaid);
      player.allFees = allFeesP;

      id = player.id;
    });
    await Firestore.instance.collection('players').document(id).updateData(player.toMap());

    moveToLastScreen();
  }

  void _showAlertDialog(Player player) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 100,
                      color: Colors.blue[900],
                      child: Center(
                        child: Text(
                          'Fee Receipt',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Text(
                              player.firstName + " " + player.lastName,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Age: " + (((DateTime.now().difference(player.dob).inDays) / 365).floor()).toString() + " years",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Last Paid: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  player.lastPaid,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: DropdownButton<String>(
                              underline: SizedBox(),
                              value: selectYear,
                              onChanged: (String string) {
                                setState(() {
                                  selectYear = string;
                                });
                              },
                              selectedItemBuilder: (BuildContext context) {
                                return year.map<Widget>((String item) {
                                  return Center(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              items: year.map((String item) {
                                return DropdownMenuItem<String>(
                                  child: Text(
                                    '$item',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  value: item,
                                );
                              }).toList(),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(' '),
                          ),
                          Expanded(
                            flex: 3,
                            child: DropdownButton<String>(
                              underline: SizedBox(),
                              value: selectMonth,
                              onChanged: (String string) {
                                setState(() {
                                  selectMonth = string;
                                });
                              },
                              selectedItemBuilder: (BuildContext context) {
                                return month.map<Widget>((String item) {
                                  return Center(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              items: month.map((String item) {
                                return DropdownMenuItem<String>(
                                  child: Text(
                                    '$item',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  value: item,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue[900],
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () {
                              setState(() {});
                              moveToLastScreen();
                            },
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            child: Text(
                              'Pay',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue[900],
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                saveToFirebase(player);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class Search extends StatefulWidget {
  Search();
  @override
  State<StatefulWidget> createState() {
    return SearchState();
  }
}

class SearchState extends State<Search> {
  SearchState();
  TextEditingController searchControll = TextEditingController();
  List<String> allFees = [
    "2021 January",
    "2021 February",
    "2021 March",
    "2021 April",
    "2021 May",
    "2021 June",
    "2021 July",
    "2021 August",
    "2021 September",
    "2021 October",
    "2021 November",
    "2021 December",
    "2022 January",
    "2022 February",
    "2022 March",
    "2022 April",
    "2022 May",
    "2022 June",
    "2022 July",
    "2022 August",
    "2022 September",
    "2022 October",
    "2022 November",
    "2022 December",
    "2023 January",
    "2023 February",
    "2023 March",
    "2023 April",
    "2023 May",
    "2023 June",
    "2023 July",
    "2023 August",
    "2023 September",
    "2023 October",
    "2023 November",
    "2023 December",
    "2024 January",
    "2024 February",
    "2024 March",
    "2024 April",
    "2024 May",
    "2024 June",
    "2024 July",
    "2024 August",
    "2024 September",
    "2024 October",
    "2024 November",
    "2024 December",
    "2025 January",
    "2025 February",
    "2025 March",
    "2025 April",
    "2025 May",
    "2025 June",
    "2025 July",
    "2025 August",
    "2025 September",
    "2025 October",
    "2025 November",
    "2025 December",
    "2026 January",
    "2026 February",
    "2026 March",
    "2026 April",
    "2026 May",
    "2026 June",
    "2026 July",
    "2026 August",
    "2026 September",
    "2026 October",
    "2026 November",
    "2026 December"
  ];

  String selectMonth = DateFormat('MMMM').format(DateTime.now());
  String selectYear = DateFormat('yyyy').format(DateTime.now());
  List<String> year = [
    "2021",
    "2022",
    "2023",
    "2024",
    "2025",
    "2026"
  ];
  List<String> month = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  bool isSearching = false;
  String searchKey = " ";
  String selected = DateFormat('yyyy').format(DateTime.now()) + " " + DateFormat('MMMM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: isSearching == false
            ? Text(
                "Search",
                style: TextStyle(fontSize: 17),
              )
            : TextField(
                style: TextStyle(color: Colors.white),
                controller: searchControll,
                onChanged: (value) {
                  setState(() {
                    searchKey = value;
                  });
                },
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: 'Search Here',
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
        actions: <Widget>[
          isSearching == false
              ? IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                    });
                  },
                ),
        ],
      ),
      body: isSearching == false
          ? StreamBuilder(
              stream: Firestore.instance.collection('players').orderBy('isActive', descending: true).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    //builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: ListTile(
                              leading: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 100,
                                  minHeight: 100,
                                  maxWidth: 100,
                                  maxHeight: 100,
                                ),
                                child: snapshot.data.documents.elementAt(index)['photoName'] != ''
                                    ? CachedNetworkImage(
                                        //placeholder: (context, url) => CircularProgressIndicator(),
                                        imageUrl: snapshot.data.documents.elementAt(index)['photoName'],
                                        fit: BoxFit.contain,
                                      )
                                    : Image(
                                        image: AssetImage('assets/photo.png'),
                                      ),
                              ),
                              title: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      snapshot.data.documents.elementAt(index)['lastName'],
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Age: " + (((DateTime.now().difference(snapshot.data.documents.elementAt(index)['dob'].toDate()).inDays) / 365).floor()).toString() + " years",
                                      style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "ID: " + snapshot.data.documents.elementAt(index)['category'],
                                      style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Switch(
                                inactiveTrackColor: Colors.red,
                                activeColor: Colors.green,
                                value: snapshot.data.documents.elementAt(index)['isActive'],
                                onChanged: (value) {
                                  setState(() {
                                    showAlertDialog(context, value, Player.fromMapObject(snapshot.data.documents.elementAt(index).data));
                                  });
                                },
                              ),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFees(Player.fromMapObject(snapshot.data.documents.elementAt(index).data))));
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      debugPrint('Loading...');
                      return Center(
                        child: Text('Loading...'),
                      );
                    }
                  },
                );
              },
            )
          : StreamBuilder(
              stream: Firestore.instance.collection('players').where('lastName', isGreaterThanOrEqualTo: searchKey).where('lastName', isLessThan: searchKey + 'z').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    //builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: ListTile(
                              leading: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 100,
                                  minHeight: 100,
                                  maxWidth: 100,
                                  maxHeight: 100,
                                ),
                                child: snapshot.data.documents.elementAt(index)['photoName'] != ''
                                    ? CachedNetworkImage(
                                        //placeholder: (context, url) => CircularProgressIndicator(),
                                        imageUrl: snapshot.data.documents.elementAt(index)['photoName'],
                                        fit: BoxFit.contain,
                                      )
                                    : Image(
                                        image: AssetImage('assets/photo.png'),
                                      ),
                              ),
                              title: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      snapshot.data.documents.elementAt(index)['lastName'],
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Age: " + (((DateTime.now().difference(snapshot.data.documents.elementAt(index)['dob'].toDate()).inDays) / 365).floor()).toString() + " years",
                                      style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "ID: " + snapshot.data.documents.elementAt(index)['category'],
                                      style: TextStyle(fontSize: 12.0, fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Switch(
                                inactiveTrackColor: Colors.red,
                                activeColor: Colors.green,
                                value: snapshot.data.documents.elementAt(index)['isActive'],
                                onChanged: (value) {
                                  setState(() {
                                    showAlertDialog(context, value, Player.fromMapObject(snapshot.data.documents.elementAt(index).data));
                                  });
                                },
                              ),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFees(Player.fromMapObject(snapshot.data.documents.elementAt(index).data))));
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      debugPrint('Loading...');
                      return Center(
                        child: Text('Loading...'),
                      );
                    }
                  },
                );
              },
            ),
    );
  }

  void updatetoFirestore(bool value, Player player) async {
    if (value == true) {
      String lastActive;
      for (int i = player.fees.length - 1; i >= 0; i--) {
        if (player.fees[i].contains('Absent')) {
          lastActive = player.fees[i];
          lastActive = lastActive.substring(0, lastActive.indexOf(':'));
          break;
        }
      }
      for (int i = 0; i < allFees.length; i++) {
        if (allFees[i] == lastActive) {
          lastActive = allFees[i + 1];
          break;
        }
      }
      int from;
      for (int i = 0; i < player.allFees.length; i++) {
        if (player.allFees[i] == lastActive) {
          from = i;
          break;
        }
      }

      while (player.allFees[from] != selected) {
        player.fees.add(player.allFees[from] + ": Absent");
        player.allFees.removeAt(from);
      }

      player.fees.add(selected + ": Present");
      player.fees.removeWhere((item) => item == selected + ": Absent");
      player.allFees.add(selected);
    } else {
      player.fees.add(selected + ": Absent");
      player.allFees.removeWhere((item) => item == selected);
    }
    player.isActive = value;
    await Firestore.instance.collection('players').document(player.id).updateData(player.toMap());
  }

  showAlertDialog(BuildContext context, bool value, Player playerD) {
    Widget cancelButton = FlatButton(
      child: Text(
        "No",
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue[900],
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Yes",
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue[900],
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () {
        updatetoFirestore(value, playerD);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: value == true
          ? Text(
              "Present",
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue[900],
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            )
          : Text(
              "Absent",
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue[900],
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              value == true ? Text("Are you sure " + playerD.firstName + " " + playerD.lastName + " is Present from " + selected + "?") : Text("Are you sure " + playerD.firstName + " " + playerD.lastName + " is Absent for " + selected + "?"),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: DropdownButton<String>(
                        underline: SizedBox(),
                        value: selectYear,
                        onChanged: (String string) {
                          setState(() {
                            selectYear = string;
                            selected = selectYear + " " + selectMonth;
                          });
                        },
                        selectedItemBuilder: (BuildContext context) {
                          return year.map<Widget>((String item) {
                            return Center(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        items: year.map((String item) {
                          return DropdownMenuItem<String>(
                            child: Text(
                              '$item',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            value: item,
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(' '),
                    ),
                    Expanded(
                      flex: 3,
                      child: DropdownButton<String>(
                        underline: SizedBox(),
                        value: selectMonth,
                        onChanged: (String string) {
                          setState(() {
                            selectMonth = string;
                            selected = selectYear + " " + selectMonth;
                          });
                        },
                        selectedItemBuilder: (BuildContext context) {
                          return month.map<Widget>((String item) {
                            return Center(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        items: month.map((String item) {
                          return DropdownMenuItem<String>(
                            child: Text(
                              '$item',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            value: item,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class ShowFees extends StatefulWidget {
  //List<String> fees;
  Player player;
  ShowFees(this.player);

  @override
  State<StatefulWidget> createState() {
    return ShowFeeState(player);
  }
}

class ShowFeeState extends State<ShowFees> {
  Player player;
  List<String> fee;
  List<String> allFee;
  ShowFeeState(this.player);

  @override
  Widget build(BuildContext context) {
    setState(() {
      fee = player.fees.toSet().toList();
      allFee = player.allFees;
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(player.firstName + " " + player.lastName,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            )),
      ),
      body: Container(
        child: ReorderableListView(
          children: <Widget>[
            for (final fees in fee)
              Card(
                color: Colors.white,
                key: ValueKey(fees),
                elevation: 2,
                child: ListTile(
                  title: fees.contains('Absent') ? Text(fees, style: TextStyle(fontSize: 18, color: Colors.red, fontFamily: 'Roboto', fontWeight: FontWeight.w400)) : Text(fees, style: TextStyle(fontSize: 18, fontFamily: 'Roboto', fontWeight: FontWeight.w400)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        showAlertDialog(context, fees);
                      });
                    },
                  ),
                ),
              ),
          ],
          onReorder: reorderData,
        ),
      ),
    );
  }

  void reorderData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final fees = fee.removeAt(oldindex);
      fee.insert(newindex, fees);
    });
    updateList();
  }

  void updateList() async {
    player.fees = fee;
    await Firestore.instance.collection('players').document(player.id).updateData(player.toMap());
  }

  showAlertDialog(BuildContext context, String index) {
    Widget cancelButton = FlatButton(
      child: Text(
        "No",
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue[900],
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Yes",
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue[900],
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () {
        setState(() {
          fee.removeWhere((item) => item == index);
          if (index.contains('Absent')) {
            index = index.substring(0, index.indexOf(':'));
            allFee.add(index);
          } else if (index.contains('Present') || index.contains('Joined')) {
          } else {
            if (player.lastPaid == index) {
              setState(() {
                player.lastPaid = 'Missing';
              });
            }
            allFee.add(index);
          }
          updateList();
        });
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Remove",
        style: TextStyle(
          fontSize: 18,
          color: Colors.blue[900],
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text("Are you sure to remove " + index + "?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class PdfViewerPage extends StatelessWidget {
  final String text = '';
  final String subject = '';
  final String path;
  final String titlebar;
  const PdfViewerPage(this.path, this.titlebar);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(titlebar),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _onShare(context);
            },
          )
        ],
      ),
      path: path,
    );
  }

  _onShare(BuildContext context) async {
    final RenderBox box = context.findRenderObject();

    await Share.shareFiles([
      '$path'
    ], text: text, subject: subject, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}

class Player {
  String _id;
  String _firstName;
  String _lastName;
  String _type;
  String _category;
  DateTime _dob;
  DateTime _lastP;
  String _photoName;
  List<String> _fees;
  List<String> _allFees;
  String _lastPaid;
  bool _uptodate;
  bool _isActive;

  Player(this._id, this._firstName, this._lastName, this._dob, this._lastP, this._type, this._photoName, this._fees, this._allFees, this._lastPaid, this._uptodate, this._isActive, this._category);

  String get id => _id;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get type => _type;
  String get category => _category;
  DateTime get dob => _dob;
  DateTime get lastP => _lastP;
  String get photoName => _photoName;
  List<String> get fees => _fees;
  List<String> get allFees => _allFees;
  String get lastPaid => _lastPaid;
  bool get uptodate => _uptodate;
  bool get isActive => _isActive;

  set id(String newId) {
    this._id = newId;
  }

  set firstName(String newFirst) {
    this._firstName = newFirst;
  }

  set lastName(String newLast) {
    this._lastName = newLast;
  }

  set dob(DateTime newDate) {
    this._dob = newDate;
  }

  set lastP(DateTime newlastP) {
    this._lastP = newlastP;
  }

  set category(String newCategory) {
    this._category = newCategory;
  }

  set type(String newType) {
    this._type = newType;
  }

  set photoName(String photoName) {
    this._photoName = photoName;
  }

  set fees(List<String> newFees) {
    this._fees = newFees;
  }

  set allFees(List<String> newallFees) {
    this._allFees = newallFees;
  }

  set lastPaid(String newPaid) {
    this._lastPaid = newPaid;
  }

  set uptodate(bool newUp) {
    this._uptodate = newUp;
  }

  set isActive(bool newActive) {
    this._isActive = newActive;
  }

  Map<String, dynamic> toMap() {
    var wageMap = Map<String, dynamic>();
    wageMap['id'] = _id;
    wageMap['firstName'] = _firstName;
    wageMap['lastName'] = _lastName;
    wageMap['dob'] = _dob;
    wageMap['lastP'] = _lastP;
    wageMap['category'] = _category;
    wageMap['type'] = _type;
    wageMap['photoName'] = _photoName;
    wageMap['fees'] = _fees;
    wageMap['allFees'] = _allFees;
    wageMap['lastPaid'] = _lastPaid;
    wageMap['uptodate'] = _uptodate;
    wageMap['isActive'] = _isActive;

    return wageMap;
  }

  Player.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._firstName = map['firstName'];
    this._lastName = map['lastName'];
    this._dob = map['dob'].toDate();
    this._lastP = map['lastP'].toDate();
    this._category = map['category'];
    this._type = map['type'];
    this._photoName = map['photoName'];
    this._fees = List.from(map['fees']);
    this._allFees = List.from(map['allFees']);
    this._lastPaid = map['lastPaid'];
    this._uptodate = map['uptodate'];
    this._isActive = map['isActive'];
  }
}
