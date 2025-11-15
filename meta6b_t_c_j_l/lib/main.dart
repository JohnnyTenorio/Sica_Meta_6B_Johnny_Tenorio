import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pages/sexo_crud_page.dart';
import 'pages/telefono_crud_page.dart';
import 'pages/persona_crud_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SICA App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.redAccent,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.redAccent[400],
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 8,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          labelStyle: const TextStyle(color: Colors.redAccent),
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIconColor: Colors.redAccent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    SexoPage(),
    TelefonoPage(),
    PersonaPage(),
    AcercaDePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("SICA - Registro - Johnny Tenorio"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: AnimatedBackground()),
          SafeArea(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Sexo'),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Telefono'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Persona'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Acerca de'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// --- Fondo animado ---
class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Colors.grey[900]!,
                Colors.redAccent.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, _controller.value, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// --- MODELOS ---
class Sexo {
  final String idsexo;
  final String nombre;
  Sexo({required this.idsexo, required this.nombre});
  factory Sexo.fromJson(Map<String, dynamic> json) {
    return Sexo(idsexo: json['idsexo'].toString(), nombre: json['nombre']);
  }
}

class Telefono {
  final String idtelefono;
  final String numero;
  Telefono({required this.idtelefono, required this.numero});
  factory Telefono.fromJson(Map<String, dynamic> json) {
    return Telefono(
      idtelefono: json['idtelefono'].toString(),
      numero: json['numero'],
    );
  }
}

class Persona {
  final String idpersona;
  final String nombres;
  final String apellidos;
  final String elsexo;
  final String elestadocivil;
  final String fechanacimiento;
  Persona({
    required this.idpersona,
    required this.nombres,
    required this.apellidos,
    required this.elsexo,
    required this.elestadocivil,
    required this.fechanacimiento,
  });
  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      idpersona: json['idpersona'].toString(),
      nombres: json['nombres'] ?? 'N/A',
      apellidos: json['apellidos'] ?? 'N/A',
      elsexo: json['elsexo'] ?? 'N/A',
      elestadocivil: json['elestadocivil'] ?? 'N/A',
      fechanacimiento: json['fechanacimiento'] ?? 'N/A',
    );
  }
}

// --- Página SEXO ---
class SexoPage extends StatefulWidget {
  const SexoPage({super.key});
  @override
  _SexoPageState createState() => _SexoPageState();
}

class _SexoPageState extends State<SexoPage> {
  List<Sexo> _sexoList = [];
  List<Sexo> _filteredSexoList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSexoData();
  }

  Future<void> _fetchSexoData() async {
    try {
      final response = await http.get(
        Uri.parse('https://educaysoft.org/apple6b/app/controllers/SexoController.php?action=api'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _sexoList = data.map((e) => Sexo.fromJson(e)).toList();
          _filteredSexoList = _sexoList;
        });
      }
    } catch (e) {
      print('Error al obtener datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredSexoList = _sexoList
          .where((item) =>
              item.nombre.toLowerCase().contains(query.toLowerCase()) ||
              item.idsexo.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // ---------------------- BUSCADOR ----------------------
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            onChanged: _filterSearch,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Buscar Sexo',
              hintText: 'Ingrese nombres o ID',
              prefixIcon: Icon(Icons.search, color: Colors.redAccent),
            ),
          ),
        ),

        // ---------------------- BOTÓN NUEVO ----------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SexoCrudPage()),
              );
            },
            child: const Text("Datos de Sexo"),
          ),
        ),
        // ---------------------------------------------------------

        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent))
              : _filteredSexoList.isEmpty
                  ? const Center(
                      child: Text("No hay datos de Sexo disponibles",
                          style: TextStyle(color: Colors.white)),
                    )
                  : ListView.builder(
                      itemCount: _filteredSexoList.length,
                      itemBuilder: (context, index) {
                        final sexo = _filteredSexoList[index];
                        return FuturisticCard(
                          icon: Icons.people,
                          title: sexo.nombre,
                          subtitle: "ID: ${sexo.idsexo}",
                        );
                      },
                    ),
        ),
      ],
    );
  }
}


// --- Página TELEFONO ---
class TelefonoPage extends StatefulWidget {
  const TelefonoPage({super.key});
  @override
  _TelefonoPageState createState() => _TelefonoPageState();
}

class _TelefonoPageState extends State<TelefonoPage> {
  List<Telefono> _telefonoList = [];
  List<Telefono> _filteredTelefonoList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTelefonoData();
  }

  Future<void> _fetchTelefonoData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://educaysoft.org/apple6b/app/controllers/TelefonoController.php?action=api'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _telefonoList = data.map((e) => Telefono.fromJson(e)).toList();
          _filteredTelefonoList = _telefonoList;
        });
      }
    } catch (e) {
      print('Error al obtener datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredTelefonoList = _telefonoList
          .where((item) =>
              item.numero.toLowerCase().contains(query.toLowerCase()) ||
              item.idtelefono.contains(query))
          .toList();
    });
  }

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          onChanged: _filterSearch,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Buscar Telefono',
            hintText: 'Ingrese número o ID',
            prefixIcon: Icon(Icons.phone, color: Colors.redAccent),
          ),
        ),
      ),

      // ---------------------- BOTÓN CRUD TELÉFONO ----------------------
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TelefonoCrudPage(),
              ),
            );
          },
          child: const Text("Datos de Teléfono"),
        ),
      ),

      Expanded(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.redAccent))
            : _filteredTelefonoList.isEmpty
                ? const Center(
                    child: Text(
                      "No hay datos de Telefono disponibles",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredTelefonoList.length,
                    itemBuilder: (context, index) {
                      final telefono = _filteredTelefonoList[index];
                      return FuturisticCard(
                        icon: Icons.phone,
                        title: telefono.numero,
                        subtitle: "ID: ${telefono.idtelefono}",
                      );
                    },
                  ),
      ),
    ],
  );
}
}

// --- Página PERSONA ---
class PersonaPage extends StatefulWidget {
  const PersonaPage({super.key});
  @override
  _PersonaPageState createState() => _PersonaPageState();
}

class _PersonaPageState extends State<PersonaPage> {
  List<Persona> _personaList = [];
  List<Persona> _filteredPersonaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPersonaData();
  }

  Future<void> _fetchPersonaData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://educaysoft.org/apple6b/app/controllers/PersonaController.php?action=api'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _personaList = data.map((e) => Persona.fromJson(e)).toList();
          _filteredPersonaList = _personaList;
        });
      }
    } catch (e) {
      print('Error al obtener datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredPersonaList = _personaList
          .where((item) =>
              item.nombres.toLowerCase().contains(query.toLowerCase()) ||
              item.apellidos.toLowerCase().contains(query.toLowerCase()) ||
              item.fechanacimiento.contains(query))
          .toList();
    });
  }

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      // --- BUSCADOR ---
      Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          onChanged: _filterSearch,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Buscar Persona',
            hintText: 'Ingrese nombres, apellidos o fecha',
            prefixIcon: Icon(Icons.person, color: Colors.redAccent),
          ),
        ),
      ),

      // --- BOTÓN CRUD PERSONA ---
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PersonaCrudPage(),
              ),
            );
          },
          child: const Text("Datos de Persona"),
        ),
      ),

      Expanded(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.redAccent))
            : _filteredPersonaList.isEmpty
                ? const Center(
                    child: Text(
                      "No hay datos de Persona disponibles",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredPersonaList.length,
                    itemBuilder: (context, index) {
                      final persona = _filteredPersonaList[index];
                      return FuturisticCard(
                        icon: Icons.person,
                        title: "${persona.nombres} ${persona.apellidos}",
                        subtitle:
                            "Nacimiento: ${persona.fechanacimiento}\nSexo: ${persona.elsexo}\nEstado Civil: ${persona.elestadocivil}",
                      );
                    },
                  ),
      ),
    ],
  );
}
}

// --- Página ACERCA DE ---
class AcercaDePage extends StatelessWidget {
  const AcercaDePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Aplicación SICA - Desarrollado por Johnny Tenorio\nVersión 1.0",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}

// --- Tarjeta futurista ---
class FuturisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FuturisticCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[900]!, Colors.redAccent.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.redAccent, size: 35),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, height: 1.4),
          ),
          trailing:
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.redAccent),
        ),
      ),
    );
  }
}
