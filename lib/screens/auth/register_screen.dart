import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final telefonoController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  DateTime? fechaNacimiento;

  bool loading = false;

  Future<void> registrar() async {

    if (fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seleccione una fecha de nacimiento"),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      final response = await AuthService().signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = response.user;

      if (user == null) {
        throw Exception("No se pudo crear el usuario");
      }

      await Supabase.instance.client
          .from("Usuario")
          .insert({

        "id_usuario": user.id,
        "nombre": nombreController.text.trim(),
        "apellido": apellidoController.text.trim(),
        "email": emailController.text.trim(),
        "telefono": telefonoController.text.trim(),
        "fecha_nacimiento":
        fechaNacimiento!.toIso8601String(),

      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuario registrado correctamente"),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    }

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Crear cuenta"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: apellidoController,
              decoration: const InputDecoration(
                labelText: "Apellido",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Teléfono",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Correo",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña",
              ),
            ),

            const SizedBox(height: 20),

            ListTile(

              title: Text(
                fechaNacimiento == null
                    ? "Seleccionar fecha de nacimiento"
                    : fechaNacimiento!
                    .toString()
                    .split(" ")[0],
              ),

              trailing: const Icon(Icons.calendar_month),

              onTap: () async {

                final fecha = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (fecha != null) {

                  setState(() {
                    fechaNacimiento = fecha;
                  });

                }

              },

            ),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: loading ? null : registrar,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Registrarse"),

              ),

            )

          ],
        ),
      ),
    );
  }
}