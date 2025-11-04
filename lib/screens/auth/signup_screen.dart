import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymassist/routes/app_routes.dart';
import 'package:gymassist/services/auth_service.dart';
import 'package:gymassist/utils/utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _auth = AuthService();
  bool _loading = false;

  void _submit() async {
    setState(() => _loading = true);
    try {
      await _auth.signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
        displayName: nameController.text.trim(),
        askIsTrainerIfNeeded: () async {
          print("Inside isTrainer");
          // Ask only for new Google users
          final result = await showModalBottomSheet<bool>(
            context: context,
            builder: (ctx) {
              bool? selectedTrainer;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Are you a trainer or a trainee?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: const Text('Trainer'),
                      onTap: () => Navigator.pop(ctx, true),
                    ),
                    ListTile(
                      title: const Text('Trainee'),
                      onTap: () => Navigator.pop(ctx, false),
                    ),
                  ],
                ),
              );
            },
          );
          return result ?? false;
        },
      );
      // navigate to app home
      Navigator.of(context).pushReplacementNamed(AppRoutes.homeWrapper);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign up failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _googleLogin() async {
    print("Inside google login");
    setState(() => _loading = true);
    try {
      await _auth.signInWithGoogle(
        askIsTrainerIfNeeded: () async {
          print("Inside isTrainer");
          // Ask only for new Google users
          final result = await showModalBottomSheet<bool>(
            context: context,
            builder: (ctx) {
              bool? selectedTrainer;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Are you a trainer or a trainee?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: const Text('Trainer'),
                      onTap: () => Navigator.pop(ctx, true),
                    ),
                    ListTile(
                      title: const Text('Trainee'),
                      onTap: () => Navigator.pop(ctx, false),
                    ),
                  ],
                ),
              );
            },
          );
          return result ?? false;
        },
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.homeWrapper);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "images/dumbells_login.jpg",
              height: AppDimens(context).blockSizeVertical * 30,
              width: AppDimens(context).blockSize * 100,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: AppDimens(context).blockSizeVertical * 12,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens(context).blockSize * 5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: ' to Create a New\n Account',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimens(context).blockSizeVertical * 2),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimens(context).blockSizeVertical * 1.2,
                  ),
                  child: Text(
                    "Lorem Ipsum Dolor sit amet",
                    style: TextStyle(
                      fontSize: AppDimens(context).blockSizeVertical * 1.5,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: AppDimens(context).blockSizeVertical * 2),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    hintText: "Enter Email",
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.accent,
                    ),
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                SizedBox(height: AppDimens(context).blockSizeVertical * 2),
                TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    hintText: "Password",
                    prefixIcon: Icon(
                      Icons.password_outlined,
                      color: AppColors.accent,
                    ),
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                SizedBox(height: AppDimens(context).blockSizeVertical * 2),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    hintText: "Enter FullName",
                    prefixIcon: Icon(
                      Icons.drive_file_rename_outline,
                      color: AppColors.accent,
                    ),
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                SizedBox(height: AppDimens(context).blockSizeVertical * 2),
                Center(
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w200,
                      fontSize: AppDimens(context).blockSizeVertical * 1.5,
                    ),
                  ),
                ),

                SizedBox(height: AppDimens(context).blockSizeVertical * 3),
                GestureDetector(
                  onTap: _loading
                      ? null
                      : () {
                    if (emailController.text.isNotEmpty &&
                        passwordController.text.isNotEmpty) {
                      _submit();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please fill in all fields"),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: _loading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      "Sign Up",
                      style: TextStyle(
                        color: AppColors.inputField,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppDimens(context).blockSizeVertical * 3),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors.grey, // or any color you need
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Or',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ), // match your theme
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  ],
                ),
                SizedBox(height: 10),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Spacer(),
                    ElevatedButton(
                      onPressed: _loading ? null : _googleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.inputField, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Pill shape
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.google,
                            color: AppColors.accent,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Google",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ],
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4,
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 0),
              height: AppDimens(context).blockSizeVertical * 13,
              decoration: BoxDecoration(
                color: Color.fromARGB(205, 24, 24, 35),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                    children: [
                      TextSpan(
                        text: 'Log In',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed(AppRoutes.login);
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
