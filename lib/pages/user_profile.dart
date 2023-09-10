import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:employee_management/models/user_model.dart';
import 'package:employee_management/services/auth_services.dart';
import 'package:employee_management/services/database_services.dart';
import 'package:employee_management/services/storage_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class UserProfile extends StatefulWidget {
  final UserModel user;

  const UserProfile({super.key, required this.user});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _nameController = TextEditingController();
  final _contactNoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final _db = DatabaseServices();
  final _auth = AuthServices();
  final _storage = StorageServices();
  bool _passwordVisibility = false;
  File? image;
  bool _isLoading = false;
  String progress = "";

  updateProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      if (_passwordController.text.isNotEmpty) {
        //update password
        _auth.changePassword(_passwordController.text).then((value) {
          checkAndUpdateImageData();
        }).catchError((e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Error :- $e")));
        });
      } else {
        //proceed with only profile update
        checkAndUpdateImageData();
      }
    }
  }

  checkAndUpdateImageData() {
    if (image == null) {
      updateUserData("");
    } else {
      //upload image and update image data
      _storage.updateProfileImage(image!, widget.user.uid, (p0) {
        setState(() {
          progress = "Uploading :- $p0%";
        });
      }, updateUserData);
    }
  }

  updateUserData(String imagePath) {
    widget.user.name = _nameController.text;
    widget.user.contactNo = _contactNoController.text;
    if (imagePath.isNotEmpty) {
      widget.user.profileImage = imagePath;
    }
    _db.updateUserData(widget.user).then((value) {
      //user updated
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User Updated")));
      progress = "";
      setState(() {
        _isLoading = false;
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error:- $e")));
      progress = "";
      setState(() {
        _isLoading = false;
      });
    });
  }

  pickImage(ImageSource source) async {
    _picker.pickImage(source: source, maxHeight: 480, maxWidth: 480).then((i) {
      final imageTemp = File(i!.path);
      setState(() {
        image = imageTemp;
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Unable to get image")));
    });
  }

  showPickImageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Browse image"),
        content: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.camera),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text("Camera"),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.photo_album_outlined),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text("Gallery"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _contactNoController.text = widget.user.contactNo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        foregroundColor: Colors.black,
        title: Row(
          children: const [
            Hero(
              tag: "user_profile_button",
              child: Icon(Icons.person_outline),
            ),
            SizedBox(
              width: 10.0,
            ),
            Text("Profile")
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: "user_profile_photo",
                  child: Container(
                    width: 120,
                    height: 120,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: image == null
                        ? widget.user.profileImage == "default"
                            ? Container(
                                width: 120,
                                height: 120.0,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0x170000FF),
                                ),
                                child: const Text(
                                  "No image selected",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 22.0),
                                ),
                              )
                            : SizedBox(
                                width: 120,
                                height: 120.0,
                                child: CachedNetworkImage(
                                    progressIndicatorBuilder:
                                        (context, url, progress) => Center(
                                              child: CircularProgressIndicator(
                                                value: progress.progress,
                                              ),
                                            ),
                                    imageUrl: widget.user.profileImage),
                              )
                        : kIsWeb
                            ? Image.network(
                                image!.path,
                                width: 120,
                                height: 120.0,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                image!,
                                width: 120,
                                height: 120.0,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showPickImageDialog();
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                      Colors.black,
                    ),
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xFFF7F7F7),
                    ),
                  ),
                  child: const Text("Update Photo"),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          validator: (v) {
                            return v == null
                                ? "Field Required"
                                : v.isEmpty
                                    ? "Required Field"
                                    : null;
                          },
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Name',
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
                                color: Colors.redAccent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF),
                            contentPadding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    16, 24, 0, 24),
                            prefixIcon: const Icon(Icons.people),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          controller: _contactNoController,
                          validator: (value) {
                            return value != null
                                ? RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]')
                                        .hasMatch(value)
                                    ? null
                                    : "Enter valid Contact-Number"
                                : "Contact-number required";
                          },
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Contact-Number',
                            labelStyle: GoogleFonts.urbanist(
                              color: const Color(0xFF95A1AC),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            hintText: 'Enter employee number...',
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
                                color: Colors.redAccent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF),
                            contentPadding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    16, 24, 0, 24),
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          style: GoogleFonts.urbanist(
                            color: const Color(0xFF14181B),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passwordController,
                          validator: (value) {
                            return value != null
                                ? value.isNotEmpty
                                    ? value.length < 6
                                        ? "Minimum Password Length is 6"
                                        : null
                                    : null
                                : null;
                          },
                          obscureText: !_passwordVisibility,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.urbanist(
                              color: const Color(0xFF95A1AC),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            hintText: 'Enter your password here...',
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
                                color: Colors.redAccent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF),
                            contentPadding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    16, 24, 24, 24),
                            suffixIcon: InkWell(
                              onTap: () => setState(
                                () =>
                                    _passwordVisibility = !_passwordVisibility,
                              ),
                              focusNode: FocusNode(skipTraversal: true),
                              child: Icon(
                                _passwordVisibility
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF95A1AC),
                                size: 22,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.password),
                          ),
                          style: GoogleFonts.urbanist(
                            color: const Color(0xFF14181B),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: _cPasswordController,
                          validator: (value) {
                            return value != null
                                ? value == _passwordController.text
                                    ? null
                                    : "Both Passwords not match"
                                : null;
                          },
                          obscureText: !_passwordVisibility,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: GoogleFonts.urbanist(
                              color: const Color(0xFF95A1AC),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            hintText: 'Confirm your password here...',
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
                                color: Colors.redAccent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF),
                            contentPadding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    16, 24, 24, 24),
                            suffixIcon: InkWell(
                              onTap: () => setState(
                                () =>
                                    _passwordVisibility = !_passwordVisibility,
                              ),
                              focusNode: FocusNode(skipTraversal: true),
                              child: Icon(
                                _passwordVisibility
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF95A1AC),
                                size: 22,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.password),
                          ),
                          style: GoogleFonts.urbanist(
                            color: const Color(0xFF14181B),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
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
                                updateProfile();
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  backgroundColor: const Color(0xFF4B39EF)),
                              child: const Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    25, 12, 25, 12),
                                child: FittedBox(
                                  child: Text(
                                    'Update Profile',
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
                const SizedBox(
                  height: 16.0,
                ),
                Text(
                  progress,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
