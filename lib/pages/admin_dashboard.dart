import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee_management/pages/user_profile.dart';
import 'package:employee_management/services/database_services.dart';
import 'package:employee_management/widgets/user_dash_graph_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import '../models/user_model.dart';
import 'add_employee.dart';
import 'admin_profile.dart';

class admin_dashboard extends StatefulWidget {
  const admin_dashboard({Key? key}) : super(key: key);

  @override
  _admin_dashboardState createState() => _admin_dashboardState();
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const add_employee_page(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class _admin_dashboardState extends State<admin_dashboard> {
  TextEditingController? textController = TextEditingController();
  bool _isLoading = false;
  String filter = "";

  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
  }

  searchUser() {
    setState(() {
      filter = textController!.text;
    });
  }

  @override
  void dispose() {
    textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF1F4F8),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
                alignment: Alignment.bottomCenter,
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 300),
                reverseDuration: const Duration(milliseconds: 300),
                type: PageTransitionType.bottomToTop,
                child: const add_employee_page(),
                childCurrent: widget),
          );
          // Navigator.of(context).push(add_employee_page());
        },
        backgroundColor: const Color(0xFF4B39EF),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: double.infinity,
            height: 225,
            decoration: const BoxDecoration(
              color: Color(0xFF14181B),
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  color: Color(0x39000000),
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 60, 24, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Dashboard',
                        style: GoogleFonts.urbanist(
                          color: const Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  alignment: Alignment.bottomCenter,
                                  curve: Curves.easeInOut,
                                  duration: const Duration(milliseconds: 350),
                                  reverseDuration:
                                      const Duration(milliseconds: 350),
                                  type: PageTransitionType.rightToLeft,
                                  child: const ProfileScreenWidget(),
                                  childCurrent: widget));
                        },
                        icon: const Icon(Icons.person),
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4F8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: const AlignmentDirectional(0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                4, 0, 4, 0),
                            child: TextFormField(
                              controller: textController,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Employee name',
                                labelStyle: GoogleFonts.urbanist(
                                  color: const Color(0xFF95A1AC),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                hintText: 'Enter employee name here...',
                                hintStyle: GoogleFonts.urbanist(
                                  color: const Color(0xFF95A1AC),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
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
                                prefixIcon: const Icon(
                                  Icons.search_sharp,
                                  color: Color(0xFF95A1AC),
                                ),
                              ),
                              style: GoogleFonts.urbanist(
                                color: const Color(0xFF14181B),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
                          child: _isLoading
                              ? const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      25, 12, 25, 12),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    searchUser();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      shape: const StadiumBorder(),
                                      backgroundColor: const Color(0xFF4B39EF)),
                                  child: const Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        10, 12, 10, 12),
                                    child: FittedBox(
                                      child: Text(
                                        'Search',
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Generated code for this ListView Widget...
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: DatabaseServices().getUsers(),
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
                  users = [];

                  for (DocumentSnapshot snap in snapshot.data!.docs) {
                    bool isActive = false;
                    try {
                      if (snap["isActive"] != null) {
                        isActive = snap["isActive"];
                      }
                    } catch (e) {
                      isActive = true;
                    }
                    if ((snap["email"] as String)
                            .toLowerCase()
                            .contains(filter.toLowerCase()) ||
                        (snap["name"] as String)
                            .toLowerCase()
                            .contains(filter.toLowerCase()) ||
                        (snap["department"] as String)
                            .toLowerCase()
                            .contains(filter.toLowerCase()) ||
                        (snap["role"] as String)
                            .toLowerCase()
                            .contains(filter.toLowerCase())) {
                      users.add(UserModel(
                        uid: snap["uid"],
                        email: snap["email"],
                        name: snap["name"],
                        contactNo: snap["contactNo"],
                        department: snap["department"],
                        joiningDate: snap["joiningDate"],
                        profileImage: snap["profileImage"],
                        role: snap["role"],
                        isActive: isActive,
                      ));
                    }
                  }
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UserDashGraphsWidget(
                                            uid: users[index].uid,
                                            // isAdmin : true,
                                            user: users[index],
                                          )));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 10.0),
                              child: Row(
                                children: [
                                  users[index].profileImage == "default"
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
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  users[index].profileImage),
                                        ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          users[index].name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        Text(users[index].department),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.edit)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: users.length,
                  );
                }),
          )
        ],
      ),
    );
  }
}
