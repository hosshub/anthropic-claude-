import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../config.dart';
import '../../services/auth_service.dart';
import '../../theme/theme.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../widgets/primary_button.dart';

enum _AuthMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  _AuthMode _mode = _AuthMode.signIn;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    if (_mode == _AuthMode.signIn) {
      await auth.signIn(email: email, password: password);
    } else {
      await auth.signUp(email: email, password: password);
    }
  }

  void _onModeChanged(Set<_AuthMode> selection) {
    setState(() => _mode = selection.first);
    context.read<AuthService>().clearMessages();
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
                    const SizedBox(height: 12),
                    // شعار مبدئي (تستبدله الأيقونة الفعلية لاحقاً).
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: TColors.primary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: TColors.cardShadow,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'الطيبات',
                      style: text.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _mode == _AuthMode.signIn
                          ? 'سجّل الدخول للمتابعة'
                          : 'أنشئ حساباً للبدء',
                      style: text.bodyLarge?.copyWith(
                        color: TColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: SegmentedButton<_AuthMode>(
                        segments: const [
                          ButtonSegment(
                            value: _AuthMode.signIn,
                            label: Text('تسجيل الدخول'),
                          ),
                          ButtonSegment(
                            value: _AuthMode.signUp,
                            label: Text('حساب جديد'),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: _onModeChanged,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                      ),
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
                      controller: _passCtrl,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور (٦ أحرف فأكثر)',
                      ),
                      validator: (v) {
                        if ((v ?? '').length < 6) {
                          return 'كلمة المرور قصيرة جداً';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: _mode == _AuthMode.signIn
                          ? 'تسجيل الدخول'
                          : 'إنشاء الحساب',
                      loading: auth.isBusy,
                      onPressed: auth.isBusy ? null : _submit,
                    ),
                    if (auth.info != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        auth.info!,
                        style: const TextStyle(
                          color: TColors.primary,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (auth.error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        auth.error!,
                        style: const TextStyle(
                          color: TColors.khabith,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'أو',
                            style: TextStyle(
                              color: TColors.textSecondary.withOpacity(0.85),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GoogleSignInButton(
                      loading: auth.isBusy,
                      onPressed: auth.isBusy
                          ? null
                          : () =>
                              context.read<AuthService>().signInWithGoogle(),
                    ),
                    if (AppConfig.appleSignInEnabled && Platform.isIOS) ...[
                      const SizedBox(height: 10),
                      SignInWithAppleButton(
                        onPressed: auth.isBusy
                            ? () {}
                            : () => context.read<AuthService>().signInWithApple(),
                        text: 'تسجيل الدخول عبر Apple',
                        height: 50,
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                      ),
                    ],
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
