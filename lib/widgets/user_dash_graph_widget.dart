import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee_management/models/task_data_model.dart';
import 'package:employee_management/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

import '../services/database_services.dart';

class UserDashGraphsWidget extends StatefulWidget {
  final String uid;
  final UserModel? user;

  const UserDashGraphsWidget({super.key, required this.uid, this.user});

  @override
  State<UserDashGraphsWidget> createState() => _UserDashGraphsWidgetState();
}

class _UserDashGraphsWidgetState extends State<UserDashGraphsWidget> {
  final _db = DatabaseServices();

  getData() {}
  var todayDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.user != null
          ? AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              title: Text("User Details"),
            )
          : null,
      body: Column(
        children: [
          widget.user != null
              ? Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  20, 0, 20, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 0, 0),
                                    child: Text(
                                      'Details for:-',
                                      style: GoogleFonts.urbanist(
                                        color: const Color(0xFF14181B),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  20, 0, 20, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 4, 0, 0),
                                    child: Text(
                                      widget.user!.name,
                                      style: GoogleFonts.urbanist(
                                        color: const Color(0xFF14181B),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      widget.user!.profileImage == "default"
                          ? const CircleAvatar(
                              radius: 30.0,
                              child: Text(
                                "No Image found",
                                style: TextStyle(fontSize: 10.0),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : CircleAvatar(
                              radius: 30.0,
                              backgroundImage: CachedNetworkImageProvider(
                                  widget.user!.profileImage),
                            ),
                      const SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                )
              : SizedBox(),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            height: 1.0,
            color: Colors.black,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.getTasks(widget.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        color: Color(0xFF4B39EF),
                      ),
                    ),
                  );
                }
                List<TaskDataModel> tasks = [
                  TaskDataModel(date: "", worked: 0, breaks: 0, meetings: 0),
                  TaskDataModel(date: "", worked: 0, breaks: 0, meetings: 0),
                  TaskDataModel(date: "", worked: 0, breaks: 0, meetings: 0),
                  TaskDataModel(date: "", worked: 0, breaks: 0, meetings: 0),
                  TaskDataModel(date: "", worked: 0, breaks: 0, meetings: 0),
                  TaskDataModel(date: "", worked: 0, breaks: 0, meetings: 0),
                  TaskDataModel(date: "", worked: 0, breaks: 0, meetings: 0),
                ];
                int i = 0;
                var dTH = todayDate.subtract(const Duration(days: 7));
                print(dTH);
                for (DocumentSnapshot document in snapshot.data!.docs) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  DateTime d1 = DateFormat("yyyy-MM-dd")
                      .parse((data["startDateTime"] as String).split(" ")[0]);
                  DateTime d2 = DateFormat("yyyy-MM-dd")
                      .parse("${dTH.year}-${dTH.month}-${dTH.day}");
                  if (d1.isAfter(d2) &&( (todayDate.add(const Duration(days: 1))).isAfter(d1))) {
                    for (i = 0; i < tasks.length; i++) {
                      if (tasks[i].date ==
                          (data["startDateTime"] as String).split(" ")[0]) {
                        break;
                      }
                      if (tasks[i].date == "") {
                        break;
                      }
                    }
                    print("i $i");
                    tasks[i].date =
                        (data["startDateTime"] as String).split(" ")[0];
                    if (data["taskType"] == "Break") {
                      tasks[i].breaks++;
                    } else if (data["taskType"] == "Meeting") {
                      // todayMeeting++;
                      tasks[i].meetings++;
                    } else {
                      // todayWorked++;
                      tasks[i].worked++;
                    }
                    i++;
                  }
                }
                for (int i = 0; i < tasks.length; i++) {
                  if (tasks[i].date.isEmpty) {
                    tasks.remove(tasks[i]);
                    i--;
                  }
                }
                // print(tasks.length);
                // for (TaskDataModel t in tasks) {
                //   print("${t.date}");
                // }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 22.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Schedules",
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                Text("$todayDate".split(" ")[0]),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () async {
                              final dt = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000, 1, 1),
                                  lastDate: DateTime.now());
                              if (dt != null) {
                                setState(() {
                                  todayDate = dt;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ],
                      ),
                      //TODO:show charts
                      PieChartWidget(
                        tasks: tasks,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final List<TaskDataModel> tasks;

  final colorList = <Color>[
    const Color(0xfffdcb6e),
    const Color(0xff0984e3),
    const Color(0xfffd79a8),
    const Color(0xffe17055),
    const Color(0xff6c5ce7),
  ];

  PieChartWidget({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {};
    Map<String, double> dataMap2 = {};
    if (tasks.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Text("No Data Found for last 7 days"),
      );
    }

    dataMap["Breaks"] = tasks[0].breaks + 0.0;
    dataMap["Meetings"] = tasks[0].meetings + 0.0;
    dataMap["Worked"] = tasks[0].worked + 0.0;
    if (tasks.length >= 2) {
      dataMap2["Breaks"] = tasks[1].breaks + 0.0;
      dataMap2["Meetings"] = tasks[1].meetings + 0.0;
      dataMap2["Worked"] = tasks[1].worked + 0.0;
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PieChart(
            dataMap: dataMap,
            chartType: ChartType.disc,
            baseChartColor: Colors.grey[50]!.withOpacity(0.15),
            colorList: colorList,
            chartValuesOptions: const ChartValuesOptions(
              showChartValuesInPercentage: true,
            ),
          ),
        ),
        tasks.length >= 2
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PieChart(
                  dataMap: dataMap2,
                  chartType: ChartType.disc,
                  baseChartColor: Colors.grey[50]!.withOpacity(0.15),
                  colorList: colorList,
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValuesInPercentage: true,
                  ),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
