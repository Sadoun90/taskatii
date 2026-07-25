import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:taskatii/core/functions/navigation.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/services/supabase_service.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/features/main_layout/main_layout.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isSignUp = false;
  bool isLoading = false;
  bool obfuscatePassword = true;
  bool rememberMe = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    bool isRemembered =
        AppLocalStorage.getCachedData(AppLocalStorage.KRememberMe) ?? false;
    if (isRemembered) {
      String? savedEmail =
          AppLocalStorage.getCachedData(AppLocalStorage.KSavedEmail);
      String? savedPass =
          AppLocalStorage.getCachedData(AppLocalStorage.KSavedPassword);
      if (savedEmail != null) emailController.text = savedEmail;
      if (savedPass != null) passwordController.text = savedPass;
      rememberMe = true;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.redcolor,
          content: const Text('Please enter both Email and Password'),
        ),
      );
      return;
    }

    if (isSignUp && nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.redcolor,
          content: const Text('Please enter your Name'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    String? error;
    try {
      if (isSignUp) {
        error = await SupabaseService.signUp(email, password);
      } else {
        error = await SupabaseService.signIn(email, password);
      }
    } catch (e) {
      error = e.toString();
    }

    setState(() => isLoading = false);

    // Save local user session regardless of remote auth state to ensure app usability
    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.redcolor,
            content: Text(error),
          ),
        );
      }
      return;
    }

    // Restore name from previous session if available, otherwise derive from email
    String? existingName = AppLocalStorage.getCachedData(AppLocalStorage.KName);
    String displayName = isSignUp && nameController.text.trim().isNotEmpty
        ? nameController.text.trim()
        : (existingName != null && existingName != 'Guest User' && existingName.isNotEmpty)
            ? existingName
            : email.split('@').first;

    AppLocalStorage.casheData(AppLocalStorage.KIsGuest, false);
    AppLocalStorage.casheData(AppLocalStorage.KEmail, email);
    AppLocalStorage.casheData(AppLocalStorage.KName, displayName);
    AppLocalStorage.casheData(AppLocalStorage.KIsUpload, true);

    if (rememberMe) {
      AppLocalStorage.casheData(AppLocalStorage.KSavedEmail, email);
      AppLocalStorage.casheData(AppLocalStorage.KSavedPassword, password);
      AppLocalStorage.casheData(AppLocalStorage.KRememberMe, true);
    } else {
      AppLocalStorage.userBox.delete(AppLocalStorage.KSavedEmail);
      AppLocalStorage.userBox.delete(AppLocalStorage.KSavedPassword);
      AppLocalStorage.casheData(AppLocalStorage.KRememberMe, false);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(isSignUp
              ? 'Account created successfully! 🎉'
              : 'Welcome back, $displayName! 👋'),
        ),
      );
      PushAndRemoveUntil(context, const MainLayout());
    }
  }

  void _continueAsGuest() {
    AppLocalStorage.casheData(AppLocalStorage.KIsGuest, true);
    AppLocalStorage.casheData(AppLocalStorage.KName, 'Guest User');
    AppLocalStorage.casheData(AppLocalStorage.KImage, null);
    AppLocalStorage.casheData(AppLocalStorage.KEmail, null);
    AppLocalStorage.casheData(AppLocalStorage.KIsUpload, true);
    PushAndRemoveUntil(context, const MainLayout());
  }

  void _showForgotPasswordDialog() {
    TextEditingController resetEmailController =
        TextEditingController(text: emailController.text);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          title: Text(
            'Reset Password',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your registered email address to receive a password reset link.',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
              ),
              const Gap(15),
              TextField(
                controller: resetEmailController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: () async {
                if (resetEmailController.text.trim().isNotEmpty) {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  final error = await SupabaseService.resetPassword(
                      resetEmailController.text.trim());
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        backgroundColor:
                            error == null ? Colors.green : AppColors.redcolor,
                        content: Text(
                          error ?? 'Password reset link sent to your email ✉️',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon & Header Title
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: AppColors.primaryColor,
                  ),
                  const Gap(12),
                  Text(
                    'Taskatii',
                    textAlign: TextAlign.center,
                    style: getTitleTextStyle(
                      context,
                      color: AppColors.primaryColor,
                      fontSize: 28,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    isSignUp
                        ? 'Create an account to organize your daily tasks'
                        : 'Sign in to access your tasks anytime',
                    textAlign: TextAlign.center,
                    style: getSmallTextStyle(color: Colors.grey),
                  ),
                  const Gap(30),

                  // Name Field (only on Sign Up)
                  if (isSignUp) ...[
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const Gap(16),
                  ],

                  // Email Field
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const Gap(16),

                  // Password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: obfuscatePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obfuscatePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obfuscatePassword = !obfuscatePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const Gap(10),

                  // Remember Me & Forgot Password Row
                  if (!isSignUp)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              rememberMe = !rememberMe;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    activeColor: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    value: rememberMe,
                                    onChanged: (val) {
                                      setState(() {
                                        rememberMe = val ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const Gap(6),
                                Text(
                                  'Remember me',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.grey.shade300
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const Gap(16),

                  // Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading ? null : _submitForm,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isSignUp ? 'Create Account' : 'Sign In',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const Gap(20),

                  // Toggle Sign In / Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isSignUp
                            ? 'Already have an account?'
                            : "Don't have an account?",
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => isSignUp = !isSignUp);
                        },
                        child: Text(
                          isSignUp ? 'Sign In' : 'Sign Up',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),

                  // Continue as Guest Option
                  TextButton(
                    onPressed: _continueAsGuest,
                    child: Text(
                      'Continue as Guest 👤',
                      style: getSmallTextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
