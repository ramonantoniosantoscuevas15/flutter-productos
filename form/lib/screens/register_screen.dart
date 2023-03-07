import 'package:flutter/material.dart';
import 'package:form/iu/input_decoration.dart';
import 'package:form/providers/login_form_provider.dart';
import 'package:form/services/services.dart';
import 'package:provider/provider.dart';

import '../widgets/widgets.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AuthBackground(
            child: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 250,
          ),
          CardContainer(
              child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(
                'Crear Cuenta',
                style: Theme.of(context).textTheme.headline4,
              ),
              const SizedBox(
                height: 30,
              ),
              ChangeNotifierProvider(
                create: (_) => LoginFormProvider(),
                child: const _LoginForm(),
              ),
            ],
          )),
          const SizedBox(
            height: 50,
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, 'login'),
            style: ButtonStyle(
                overlayColor:
                    MaterialStateProperty.all(Colors.indigo.withOpacity(0.1)),
                shape: MaterialStateProperty.all(const StadiumBorder())),
            child: const Text(
              '¿Ya Tienes Cuenta?',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    )));
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    return Form(
        key: loginForm.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                  hintText: 'Email',
                  labelText: 'Correo Electronico',
                  icon: Icons.alternate_email),
              onChanged: (value) => loginForm.email = value,
              validator: (value) {
                String pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp = RegExp(pattern);
                return regExp.hasMatch(value ?? '')
                    ? null
                    : 'El correo no es correcto';
              },
            ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                  hintText: 'Password',
                  labelText: 'Contraseña',
                  icon: Icons.lock),
              onChanged: (value) => loginForm.password = value,
              validator: (value) {
                return (value != null && value.length >= 6)
                    ? null
                    : 'La Contraseña debe ser de 6 Caracteres';
              },
            ),
            const SizedBox(
              height: 30,
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.deepPurple,
              onPressed: loginForm.isLoading
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      final authServices =
                          Provider.of<AuthServices>(context, listen: false);
                      if (!loginForm.isValidForm()) return;
                      loginForm.isLoading = true;
                      //validar si el login es correcto
                      final String? errorMessage = await authServices
                          .createUser(loginForm.email, loginForm.password);
                      if (errorMessage == null) {
                        Navigator.pushReplacementNamed(context, 'home');
                      } else {
                        //mostrar error en pantalla
                        // ignore: avoid_print
                        print(errorMessage);
                        loginForm.isLoading = false;
                      }

                      
                    },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  child: Text(
                    loginForm.isLoading ? 'Espere...' : 'Ingresar',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  )),
            )
          ],
        ));
  }
}
