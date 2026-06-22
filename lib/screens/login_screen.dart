import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final displayNameController = TextEditingController();
  bool loading = false;
  String error = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    displayNameController.dispose();
    super.dispose();
  }

  String getAuthErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
          return 'Email hoặc mật khẩu không chính xác.';
        case 'email-already-in-use':
          return 'Email này đã được sử dụng. Vui lòng đăng nhập.';
        case 'weak-password':
          return 'Mật khẩu phải có ít nhất 6 ký tự.';
        case 'invalid-email':
          return 'Email không đúng định dạng.';
        case 'user-disabled':
          return 'Tài khoản này đã bị vô hiệu hóa.';
        case 'too-many-requests':
          return 'Bạn thử đăng nhập quá nhiều lần. Vui lòng đợi một lúc.';
        case 'network-request-failed':
          return 'Không thể kết nối Firebase. Hãy kiểm tra mạng.';
        case 'popup-closed-by-user':
        case 'cancelled-popup-request':
          return 'Bạn đã đóng cửa sổ đăng nhập Google.';
        case 'popup-blocked':
          return 'Trình duyệt đang chặn cửa sổ đăng nhập Google.';
        case 'account-exists-with-different-credential':
          return 'Email này đã đăng ký bằng một phương thức khác.';
        case 'operation-not-allowed':
          return 'Đăng nhập Google chưa được bật trong Firebase Console.';
      }
    }
    return 'Không thể đăng nhập lúc này. Vui lòng thử lại.';
  }

  Future<void> handleGoogleSignIn() async {
    setState(() {
      error = '';
      loading = true;
    });

    try {
      await context.read<AuthProvider>().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        setState(() {
          error = getAuthErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> handleSubmit() async {
    setState(() {
      error = '';
      loading = true;
    });
    final authProvider = context.read<AuthProvider>();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final displayName = displayNameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        (!isLogin && displayName.isEmpty)) {
      setState(() {
        error = 'Vui lòng điền đầy đủ thông tin.';
        loading = false;
      });
      return;
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+').hasMatch(email)) {
      setState(() {
        error = 'Vui lòng nhập email hợp lệ.';
        loading = false;
      });
      return;
    }

    try {
      if (isLogin) {
        await authProvider.signInWithEmail(email, password);
      } else {
        await authProvider.signUpWithEmail(email, password, displayName);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLogin ? 'Đăng nhập thành công' : 'Đăng ký thành công',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = getAuthErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Text('🎓', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'Admissions Compass',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Công cụ tư vấn tuyển sinh',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isLogin = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 2,
                                    color: isLogin
                                        ? const Color(0xFF059669)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Đăng nhập',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isLogin
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isLogin = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 2,
                                    color: !isLogin
                                        ? const Color(0xFF059669)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Đăng ký',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: !isLogin
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (!isLogin)
                      TextField(
                        controller: displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên của bạn',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    if (!isLogin) const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (error.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: loading ? null : handleSubmit,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(isLogin ? 'Đăng nhập' : 'Đăng ký'),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'hoặc',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF111827),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: loading ? null : handleGoogleSignIn,
                      icon: const Text(
                        'G',
                        style: TextStyle(
                          color: Color(0xFF4285F4),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      label: const Text('Tiếp tục với Google'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? 'Chưa có tài khoản? ' : 'Đã có tài khoản? ',
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin ? 'Đăng ký ngay' : 'Đăng nhập',
                      style: const TextStyle(
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
