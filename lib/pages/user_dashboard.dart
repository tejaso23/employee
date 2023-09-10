import 'package:cached_network_image/cached_network_image.dart';
import 'package:employee_management/models/user_model.dart';
import 'package:employee_management/pages/user_profile.dart';
import 'package:employee_management/services/auth_services.dart';
import 'package:employee_management/services/database_services.dart';
import 'package:employee_management/widgets/add_task_widget.dart';
import 'package:employee_management/widgets/user_dash_graph_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  UserModel? user;
  bool _isLoading = true;
  final _db = DatabaseServices();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() {
    _db.getUserData().then((value) {
      setState(() {
        user = value;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authServices = AuthServices();
    return _isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return const AddTaskWidget();
                    });
              },
              backgroundColor: const Color(0xFF4B39EF),
              elevation: 8,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
            body: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20, 10, 16, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              2, 2, 2, 2),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserProfile(
                                            user: user!,
                                          ))).then((value) {
                                getUserData();
                              });
                            },
                            child: Hero(
                              tag: "user_profile_photo",
                              child: Container(
                                width: 60,
                                height: 60,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: CachedNetworkImage(
                                  progressIndicatorBuilder:
                                      (context, url, progress) => Center(
                                    child: CircularProgressIndicator(
                                      value: progress.progress,
                                    ),
                                  ),
                                  imageUrl: user!.profileImage,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserProfile(
                                            user: user!,
                                          ))).then((value) {
                                getUserData();
                              });
                            },
                            icon: const Hero(
                                tag: "user_profile_button",
                                child: Icon(Icons.person_outline))),
                        IconButton(
                            onPressed: () {
                              authServices.signOutUser(context, null);
                            },
                            icon: const Icon(
                              Icons.exit_to_app,
                              color: Colors.red,
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0, 16, 0, 0),
                          child: Text(
                            'Welcome,',
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
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0, 4, 0, 0),
                          child: Text(
                            user!.name,
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
                  Expanded(
                    child: UserDashGraphsWidget(
                      uid: user!.uid,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
