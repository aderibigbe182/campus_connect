import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../widgets/custom_textfield.dart';
import '../../widgets/app_logo.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/presence_service.dart';
import '../../core/services/storage_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscurePassword = true;
  bool isValidPassword(String password) {
    final hasMinLength = password.length >= 6;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    return hasMinLength && hasUppercase && hasNumber;
  }

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedSchool;
  bool isLoading = false;

  final List<String> schools = [
     "Abia State University (ABSU)",
    "Abubakar Tafawa Balewa University (ATBU)",
    "Achievers University (AU)",
    "Adamawa State University (ADSU)",
    "Adekunle Ajasin University (AAUA)",
    "Adeleke University (AU)",
    "Afe Babalola University (ABUAD)",
    "Ahmadu Bello University (ABU)",
    "Ajayi Crowther University (ACU)",
    "Akwa Ibom State University (AKSU)",
    "Al-Hikmah University (AHU)",
    "Ambrose Alli University (AAU)",
    "American University of Nigeria (AUN)",
    "Anchor University (AUL)",
    "Arthur Jarvis University (AJU)",
    "Atiba University (AU)",
    "Augustine University (AUI)",
    "Babcock University (BU)",
    "Bauchi State University (BASU)",
    "Bayero University Kano (BUK)",
    "Bells University of Technology (BUT)",
    "Benue State University (BSU)",
    "Bingham University (BU)",
    "Bowen University (BU)",
    "Caleb University (CU)",
    "Caritas University (CU)",
    "Chrisland University (CU)",
    "Christopher University (CU)",
    "Covenant University (CU)",
    "Crawford University (CU)",
    "Crescent University (CU)",
    "Cross River University of Technology (CRUTECH)",
    "Delta State University (DELSU)",
    "Ebonyi State University (EBSU)",
    "Edo State University Uzairue (EDSU)",
    "Ekiti State University (EKSU)",
    "Elizade University (EU)",
    "Enugu State University of Science and Technology (ESUT)",
    "Evangel University (EU)",
    "Federal University of Agriculture Abeokuta (FUNAAB)",
    "Federal University of Agriculture Makurdi (FUAM)",
    "Federal University Birnin Kebbi (FUBK)",
    "Federal University Dutse (FUD)",
    "Federal University Dutsin-Ma (FUDMA)",
    "Federal University Gashua (FUGASHUA)",
    "Federal University Gusau (FUGUS)",
    "Federal University Kashere (FUKASHERE)",
    "Federal University Lafia (FULAFIA)",
    "Federal University Lokoja (FULOKOJA)",
    "Federal University Otuoke (FUOTUOKE)",
    "Federal University Oye-Ekiti (FUOYE)",
    "Federal University Wukari (FUWUKARI)",
    "Godfrey Okoye University (GOU)",
    "Gregory University Uturu (GUU)",
    "Ibrahim Badamasi Babangida University (IBBU)",
    "Igbinedion University (IUO)",
    "Imo State University (IMSU)",
    "Joseph Ayo Babalola University (JABU)",
    "Kaduna State University (KASU)",
    "Kano University of Science and Technology (KUST)",
    "Kogi State University (KSU)",
    "Kwara State University (KWASU)",
    "Ladoke Akintola University of Technology (LAUTECH)",
    "Lagos State University (LASU)",
    "Landmark University (LU)",
    "Lead City University (LCU)",
    "Madonna University (MU)",
    "McPherson University (MCU)",
    "Michael Okpara University of Agriculture Umudike (MOUAU)",
    "Modibbo Adama University (MAU)",
    "Nasarawa State University (NSUK)",
    "Niger Delta University (NDU)",
    "Nile University of Nigeria (NUN)",
    "Obafemi Awolowo University (OAU)",
    "Oduduwa University (OUI)",
    "Olabisi Onabanjo University (OOU)",
    "Pan-Atlantic University (PAU)",
    "Plateau State University (PLASU)",
    "Redeemer's University (RUN)",
    "Rivers State University (RSU)",
    "Salem University (SU)",
    "Samuel Adegboyega University (SAU)",
    "Sokoto State University (SSU)",
    "Summit University (SUN)",
    "Tai Solarin University of Education (TASUED)",
    "Taraba State University (TSU)",
    "University of Abuja (UNIABUJA)",
    "University of Benin (UNIBEN)",
    "University of Calabar (UNICAL)",
    "University of Ibadan (UI)",
    "University of Ilorin (UNILORIN)",
    "University of Jos (UNIJOS)",
    "University of Lagos (UNILAG)",
    "University of Maiduguri (UNIMAID)",
    "University of Nigeria Nsukka (UNN)",
    "University of Port Harcourt (UNIPORT)",
    "University of Uyo (UNIUYO)",
    "Usmanu Danfodiyo University (UDUS)",
    "Veritas University (VU)",
    "Wellspring University (WU)",
    "Wesley University (WU)",
  ];

  bool _isValidPassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasMinLength = password.length >= 6;
    return hasUppercase && hasNumber && hasMinLength;
  }

  Future<void> register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedSchool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (!_isValidPassword(passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password must be 6+ chars, include 1 capital letter & 1 number",
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.register(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        university: selectedSchool!,
      );

      final token = result['token'];
      await StorageService.saveToken(token);

      await PresenceService.setOnline();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const AppLogo(),
                  const SizedBox(height: 15),

                  const Text(
                    "Join Campus Connect",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  CustomTextField(
                    controller: nameController,
                    hint: "Full Name",
                  ),

                  const SizedBox(height: 15),

                  CustomTextField(
                    controller: emailController,
                    hint: "Student Email",
                  ),

                  const SizedBox(height: 15),

                  CustomTextField(
                    controller: usernameController,
                    hint: "Username",
                  ),

                  const SizedBox(height: 15),

                  CustomTextField(
                    controller: phoneController,
                    hint: "Phone Number",
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),

                  const SizedBox(height: 15),

                  DropdownSearch<String>(
                    items: (f, p) => schools,
                    selectedItem: selectedSchool,
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                    ),
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: "Select School",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onSelected: (value) {
                      setState(() => selectedSchool = value);
                    },
                  ),

                  const SizedBox(height: 15),

                  // ✅ FIXED PASSWORD FIELD (NO decoration conflict)
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : register,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Sign Up"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text("Already have an account? Login"),
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