import 'package:flutter/material.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/animated_logo_image.dart';

enum LoginStatus { none, success, error }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  LoginStatus _status = LoginStatus.none;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _isAdmin =>
      _userCtrl.text.trim() == 'admin' && _passCtrl.text == 'admin123';

  bool get _isUser =>
      _userCtrl.text.trim() == 'usuario' && _passCtrl.text == 'senha123';

  Future<void> _attemptLogin() async {
    final ok = _isAdmin || _isUser;
    setState(() => _status = ok ? LoginStatus.success : LoginStatus.error);

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    if (ok) {
      final route = _isAdmin ? '/admin' : '/home';
      Navigator.of(context).pushReplacementNamed(route);
    } else {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _status = LoginStatus.none);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AnimatedLogoImage(height: 55),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _userCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Usuário",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Senha",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onFieldSubmitted: (_) => _attemptLogin(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _attemptLogin,
                      child: const Text(
                        "ENTRAR",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInBack,
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: _status == LoginStatus.none
                  ? const SizedBox(key: ValueKey('none'))
                  : Container(
                      key: ValueKey(_status),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _status == LoginStatus.success
                            ? Colors.green.withOpacity(0.9)
                            : Colors.red.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _status == LoginStatus.success ? Icons.check : Icons.close,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
