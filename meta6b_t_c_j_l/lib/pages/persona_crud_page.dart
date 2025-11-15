import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PersonaCrudPage extends StatefulWidget {
  const PersonaCrudPage({super.key});

  @override
  State<PersonaCrudPage> createState() => _PersonaCrudPageState();
}

class _PersonaCrudPageState extends State<PersonaCrudPage> {
  List<Map<String, dynamic>> personas = [];
  bool isLoading = true;

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();

  String? editingId;

  @override
  void initState() {
    super.initState();
    cargarPersonas();
  }

  Future<void> cargarPersonas() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
            'https://educaysoft.org/apple6b/app/controllers/PersonaController.php?action=api'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        personas = data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error cargando personas"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error cargando personas: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al conectar con el servidor"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> guardarPersona() async {
    if (nombreController.text.isEmpty ||
        apellidoController.text.isEmpty ||
        fechaController.text.isEmpty) return;

    final url = editingId == null
        ? Uri.parse(
            "https://educaysoft.org/apple6b/app/controllers/PersonaController.php?action=insert")
        : Uri.parse(
            "https://educaysoft.org/apple6b/app/controllers/PersonaController.php?action=update");

    try {
      final response = await http.post(url, body: {
        "id": editingId ?? "",
        "nombres": nombreController.text,
        "apellidos": apellidoController.text,
        "fechanacimiento": fechaController.text,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editingId == null
                ? "Persona agregada correctamente"
                : "Persona actualizada correctamente"),
            backgroundColor: Colors.green,
          ),
        );

        nombreController.clear();
        apellidoController.clear();
        fechaController.clear();
        editingId = null;
        cargarPersonas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error al guardar persona: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al conectar con el servidor"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> eliminarPersona(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Desea eliminar esta persona?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text("Eliminar", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await http.post(
          Uri.parse(
              "https://educaysoft.org/apple6b/app/controllers/PersonaController.php?action=delete"),
          body: {"id": id});
      cargarPersonas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Persona eliminada correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error eliminando persona: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al eliminar persona"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void mostrarDialogo({Map<String, dynamic>? persona}) {
    final bool editando = persona != null;

    if (editando) {
      editingId = persona["id"].toString();
      nombreController.text = persona["nombres"];
      apellidoController.text = persona["apellidos"];
      fechaController.text = persona["fechanacimiento"];
    } else {
      editingId = null;
      nombreController.clear();
      apellidoController.clear();
      fechaController.clear();
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(editando ? "Editar Persona" : "Agregar Persona",
              style: const TextStyle(color: Colors.redAccent)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Nombres",
                    labelStyle: const TextStyle(color: Colors.redAccent),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: apellidoController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Apellidos",
                    labelStyle: const TextStyle(color: Colors.redAccent),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: fechaController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Fecha nacimiento",
                    labelStyle: const TextStyle(color: Colors.redAccent),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                guardarPersona();
                Navigator.pop(context);
              },
              child: Text(editando ? "Actualizar" : "Guardar"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "CRUD Personas",
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => mostrarDialogo(),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent))
          : personas.isEmpty
              ? const Center(
                  child: Text(
                  "No hay personas registradas",
                  style: TextStyle(color: Colors.grey),
                ))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: personas.length,
                    itemBuilder: (context, index) {
                      final p = personas[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey[850]!,
                                Colors.redAccent.withOpacity(0.2)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 6,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading:
                                const Icon(Icons.person, color: Colors.redAccent, size: 30),
                            title: Text(
                              "${p['nombres']} ${p['apellidos']}",
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Nacimiento: ${p['fechanacimiento']}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.amber),
                                  onPressed: () => mostrarDialogo(persona: p),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => eliminarPersona(p["id"].toString()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
