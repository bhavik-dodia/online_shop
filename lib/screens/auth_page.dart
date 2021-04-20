import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/curved_painter_helper.dart';
import '../providers/carts_data.dart';
import '../widgets/auth/login.dart';
import '../widgets/auth/login_option.dart';
import '../widgets/auth/signup.dart';
import '../widgets/auth/signup_option.dart';

/// Displays page to switch between login and sign up.
class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool login = true;
  final duration = const Duration(milliseconds: 300);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        Provider.of<CartsData>(context, listen: false).loadCartItems();
      } catch (e) {
        print(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
        child: isPortrait
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => setState(() => login = true),
                    child: AnimatedContainer(
                      duration: duration,
                      curve: Curves.ease,
                      height: login
                          ? mediaQuery.size.height * 0.6
                          : mediaQuery.size.height * 0.4,
                      child: CustomPaint(
                        painter: CurvePainter(login, isPortrait),
                        child: Container(
                          padding: EdgeInsets.only(bottom: login ? 0 : 50),
                          child: Center(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                child: login
                                    ? Login()
                                    : LoginOption(
                                        onPressed: () =>
                                            setState(() => login = true),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => login = false),
                    child: AnimatedContainer(
                      duration: duration,
                      curve: Curves.ease,
                      height: login
                          ? mediaQuery.size.height * 0.4
                          : mediaQuery.size.height * 0.6,
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(top: login ? 50 : 0),
                        child: Center(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              child: !login
                                  ? SignUp(
                                      goToLogin: () =>
                                          setState(() => login = true),
                                    )
                                  : SignUpOption(
                                      onPressed: () =>
                                          setState(() => login = false),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => setState(() => login = true),
                    child: AnimatedContainer(
                      duration: duration,
                      curve: Curves.ease,
                      width: login
                          ? mediaQuery.size.width * 0.6
                          : mediaQuery.size.width * 0.4,
                      child: CustomPaint(
                        painter: CurvePainter(login, isPortrait),
                        child: Container(
                          padding: EdgeInsets.only(right: login ? 0 : 40),
                          child: Center(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                child: login
                                    ? Login()
                                    : LoginOption(
                                        onPressed: () =>
                                            setState(() => login = true),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => login = false),
                    child: AnimatedContainer(
                      duration: duration,
                      curve: Curves.ease,
                      width: login
                          ? mediaQuery.size.width * 0.4
                          : mediaQuery.size.width * 0.6,
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(left: login ? 40 : 0),
                        child: Center(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              child: !login
                                  ? SignUp(
                                      goToLogin: () =>
                                          setState(() => login = true),
                                    )
                                  : SignUpOption(
                                      onPressed: () =>
                                          setState(() => login = false),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
