import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  // 👇 Valores hardcodeados — cámbialos aquí directamente
  static const String userName = "NOMBRE";
  static const String whatToKnow = "Me calmo realizando X cosa, Y cosa, Z cosa";
  static const String songTitle = "Hyouriittai";
  static const String songArtist = "YUZU";

  Future<void> _openInSpotify() async {
    final query = Uri.encodeComponent('$songTitle $songArtist');
    final uri = Uri.parse('https://open.spotify.com/search/$query');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // verde
              Color(0xFFCDDC39), // verde-amarillo
              Color(0xFFFFC107), // amarillo/naranja
              Color(0xFFE53935), // rojo
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Pantalla de SOS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  "Se solicita que quien lea esto proceda con los siguientes pasos:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 16),

                _bullet("Reduce el estímulo, lleva a [$userName] lejos de ruidos y evita las luces intensas"),
                _bullet("Dale espacio físico"),
                _bullet("Usa frases cortas y claras"),
                _bullet("Evita confrontar"),

                const SizedBox(height: 20),
                _bullet("Mi nombre: $userName", bold: true),
                _bullet("Qué tienes que saber: $whatToKnow", bold: true),

                const SizedBox(height: 24),
                const Text(
                  "Mi música favorita:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),

                _SpotifyCard(
                  title: songTitle,
                  artist: songArtist,
                  onTap: _openInSpotify,
                ),

                const SizedBox(height: 30),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text(
                      "Cerrar",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotifyCard extends StatelessWidget {
  final String title;
  final String artist;
  final VoidCallback onTap;

  const _SpotifyCard({required this.title, required this.artist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0F2A4A),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [Colors.lightBlueAccent, Colors.greenAccent],
                  ),
                ),
                child: const Icon(Icons.music_note, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(artist, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
              const SizedBox(width: 8),
              const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}