import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<void> insertarUsuario(
      String nombre,
      String email,
      ) async {
    try {
      await supabase.from('Usuari'
          'os').insert({
        'Nombre': nombre,
        'Email': email,
      });

      print("INSERTADO");
    } catch (e) {
      print("ERROR: $e");
    }
  }
}