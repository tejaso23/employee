import 'package:employee_management/models/task_model.dart';
import 'package:employee_management/services/auth_services.dart';
import 'package:employee_management/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'input_border.dart';

class AddTaskWidget extends StatefulWidget {
  const AddTaskWidget({Key? key}) : super(key: key);

  @override
  State<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  final _taskDescription = TextEditingController();
  final _startTime = TextEditingController();
  final _timeTaken = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthServices();
  final _db = DatabaseServices();
  bool _isLoading = false;
  List<String> taskList = ["Select Task Type", "Break", "Meeting", "Work"];
  String selectedTaskType = "Select Task Type";

  @override
  void initState() {
    super.initState();
    selectedTaskType = taskList[0];
  }

  addTask() {
    if (_formKey.currentState!.validate()) {
      if (selectedTaskType.isEmpty || selectedTaskType == taskList[0]) {
        //show alert for selecting task
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Validation Error!"),
                  content: const Text("Please select Task Type."),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("OK")),
                  ],
                ));
        return;
      }
      //perform action to save data
      final taskModel = TaskModel(
          id: "",
          uid: _auth.getUid(),
          taskTitle: _taskDescription.text,
          taskType: selectedTaskType,
          startDateTime: _startTime.text,
          duration: _timeTaken.text);
      setState(() {
        _isLoading = true;
      });
      _db.saveTask(taskModel).then((value) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Task Added")));
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Text(
                "Add Task",
                style: GoogleFonts.urbanist(
                  color: const Color(0xFF14181B),
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextFormField(
                  validator: (v) {
                    return v == null
                        ? "Field Required"
                        : v.isEmpty
                            ? "Required Field"
                            : null;
                  },
                  controller: _taskDescription,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: 'Task Description',
                    labelStyle: GoogleFonts.urbanist(
                      color: const Color(0xFF95A1AC),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    hintText: 'Enter Task Description here...',
                    hintStyle: GoogleFonts.urbanist(
                      color: const Color(0xFF95A1AC),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    enabledBorder: inputBorder(const Color(0xFFE1EDF9)),
                    focusedBorder: inputBorder(const Color(0xFFE1EDF9)),
                    errorBorder: inputBorder(const Color(0x00000000)),
                    focusedErrorBorder: inputBorder(const Color(0x00000000)),
                    filled: true,
                    fillColor: const Color(0xFFFFFFFF),
                    contentPadding:
                        const EdgeInsetsDirectional.fromSTEB(16, 24, 0, 24),
                  ),
                  style: GoogleFonts.urbanist(
                    color: const Color(0xFF14181B),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  )),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE1EDF9),
                    width: 2,
                  ),
                ),
                child: DropdownButton(
                  underline: const SizedBox(),
                  isExpanded: true,
                  value: selectedTaskType,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: taskList.map((String task) {
                    return DropdownMenuItem(
                      value: task,
                      child: Text(task),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTaskType = newValue ?? "";
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () async {
                  final dt = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000, 1, 1),
                      lastDate: DateTime.now());
                  if (dt == null) {
                    return;
                  }
                  String datetime = "${dt.year}-${dt.month}-${dt.day}";
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time == null) {
                    return;
                  }
                  datetime += " ${time.hour}-${time.minute}";
                  final now = DateTime.now();
                  String dtNow =
                      "${now.year}-${now.month}-${now.day} ${now.hour}-${now.minute}";
                  if (dtNow.compareTo(datetime) < 0) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Select Valid Date"),
                              content: Text(
                                  "Please select time less than current time $dtNow."),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("OK")),
                              ],
                            ));
                    return;
                  }
                  _startTime.text = datetime;
                },
                child: TextFormField(
                    validator: (v) {
                      return v == null
                          ? "Field Required"
                          : v.isEmpty
                              ? "Required Field"
                              : null;
                    },
                    controller: _startTime,
                    obscureText: false,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Task Start Time',
                      labelStyle: GoogleFonts.urbanist(
                        color: const Color(0xFF95A1AC),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      hintText: 'Enter Start Time here...',
                      hintStyle: GoogleFonts.urbanist(
                        color: const Color(0xFF95A1AC),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE1EDF9),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE1EDF9),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFE1EDF9),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFFFFF),
                      contentPadding:
                          const EdgeInsetsDirectional.fromSTEB(16, 24, 0, 24),
                    ),
                    style: GoogleFonts.urbanist(
                      color: const Color(0xFF14181B),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    )),
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextFormField(
                  validator: (v) {
                    return v == null
                        ? "Field Required"
                        : v.isEmpty
                            ? "Required Field"
                            : null;
                  },
                  controller: _timeTaken,
                  keyboardType: TextInputType.number,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: 'Task Time Taken',
                    labelStyle: GoogleFonts.urbanist(
                      color: const Color(0xFF95A1AC),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    hintText: 'Enter Time Taken here(in min(s))',
                    hintStyle: GoogleFonts.urbanist(
                      color: const Color(0xFF95A1AC),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFFE1EDF9),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFFE1EDF9),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0x00000000),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0x00000000),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFFFFFF),
                    contentPadding:
                        const EdgeInsetsDirectional.fromSTEB(16, 24, 0, 24),
                  ),
                  style: GoogleFonts.urbanist(
                    color: const Color(0xFF14181B),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  )),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
                    child: _isLoading
                        ? const Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(25, 12, 25, 12),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              addTask();
                            },
                            style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                                backgroundColor: const Color(0xFF4B39EF)),
                            child: const Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  25, 12, 25, 12),
                              child: FittedBox(
                                child: Text(
                                  'Add Task',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
