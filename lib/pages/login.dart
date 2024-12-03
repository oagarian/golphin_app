import 'package:flutter/material.dart';
import 'package:golphin_app/pages/chat.dart';
import 'package:golphin_app/pages/register.dart';
import 'package:golphin_app/services/loginDAO.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _credentialController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Image.asset('assets/images/dolphin.png', height: 150),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _credentialController,
                  label: 'E-mail ou usuário',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Esse campo não pode ser nulo.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira sua senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: 10,
                  child: TextButton(
                    onPressed: _onLogin,
                    child: const Text('Entrar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Não tem cadastro?"),
                    SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(_createRoute());
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.teal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await LoginDAO().submitData(
        credential: _credentialController.text,
        password: _passwordController.text,
      );
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatPage()), 
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha no login. Tente novamente.')),
        );
      }
    }
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const Register(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  @override
  void dispose() {
    _credentialController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
