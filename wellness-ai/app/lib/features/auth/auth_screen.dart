import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/theme.dart';

enum _Mode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  _Mode _mode = _Mode.signIn;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    if (_mode == _Mode.signIn) {
      await auth.signIn(email: _email.text.trim(), password: _pass.text);
    } else {
      await auth.signUp(email: _email.text.trim(), password: _pass.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: WColors.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.spa,
                            color: Colors.white, size: 44),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Wellness AI',
                        style: text.displayLarge, textAlign: TextAlign.center),
                    Text(
                      _mode == _Mode.signIn
                          ? 'سجّل الدخول للمتابعة'
                          : 'أنشئ حساباً للبدء',
                      style: text.bodyLarge
                          ?.copyWith(color: WColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: SegmentedButton<_Mode>(
                        segments: const [
                          ButtonSegment(
                              value: _Mode.signIn, label: Text('تسجيل الدخول')),
                          ButtonSegment(
                              value: _Mode.signUp, label: Text('حساب جديد')),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (s) {
                          setState(() => _mode = s.first);
                          context.read<AuthService>().clearMessages();
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration:
                          const InputDecoration(labelText: 'البريد الإلكتروني'),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (!t.contains('@') || !t.contains('.')) {
                          return 'بريد غير صالح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pass,
                      obscureText: true,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                          labelText: 'كلمة المرور (٦ أحرف فأكثر)'),
                      validator: (v) =>
                          (v ?? '').length < 6 ? 'كلمة المرور قصيرة' : null,
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: auth.isBusy ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: WColors.primary,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: auth.isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(_mode == _Mode.signIn
                              ? 'تسجيل الدخول'
                              : 'إنشاء الحساب'),
                    ),
                    if (auth.info != null) ...[
                      const SizedBox(height: 14),
                      Text(auth.info!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: WColors.primary, fontSize: 13)),
                    ],
                    if (auth.error != null) ...[
                      const SizedBox(height: 14),
                      Text(auth.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: WColors.zoneRed, fontSize: 13)),
                    ],
                    const SizedBox(height: 18),
                    Row(children: const [
                      Expanded(child: Divider()),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('أو',
                              style: TextStyle(
                                  color: WColors.textSecondary, fontSize: 12))),
                      Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: auth.isBusy
                          ? null
                          : () => context.read<AuthService>().signInWithGoogle(),
                      icon: const Icon(Icons.public, color: WColors.primary),
                      label: const Text('المتابعة عبر Google'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WColors.primary,
                        minimumSize: const Size.fromHeight(50),
                        side: const BorderSide(color: WColors.primary),
                      ),
                    ),
                    // TODO: Sign in with Apple button (see AuthService TODO +
                    //       AppConfig.appleSignInEnabled).
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
