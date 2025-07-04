import 'package:flutter/material.dart';
import 'package:technopolis/admin.dart';
import 'package:technopolis/invite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connexion',
      home: Scaffold(
        appBar: AppBar(title: const Text('Jnane technopolis')),
        body: const ConnexionForm(),
      ),
      routes: {
        'admin': (context) => AdminPage(),
        'invite': (context) => InvitePage(),
      },
    );
  }
}

class ConnexionForm extends StatefulWidget {
  const ConnexionForm({super.key});

  @override
  State<ConnexionForm> createState() => _ConnexionFormState();
}

class _ConnexionFormState extends State<ConnexionForm> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onConnexionPressed() {
    String password = _passwordController.text;
    if (password == 'taiba25') {
      Navigator.pushNamed(context, 'admin');
    } else if (password == 'techno25') {
      Navigator.pushNamed(context, 'invite');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mot de passe erroné')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Entrer mot de passe', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Mot de passe',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onConnexionPressed,
            child: const Text('Connexion'),
          ),
        ],
      ),
    );
  }
}
