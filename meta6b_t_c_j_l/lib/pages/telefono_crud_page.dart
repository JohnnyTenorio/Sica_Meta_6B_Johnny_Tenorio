import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TelefonoCrudPage extends StatefulWidget {
  const TelefonoCrudPage({super.key});

  @override
  State<TelefonoCrudPage> createState() => _TelefonoCrudPageState();
}

class _TelefonoCrudPageState extends State<TelefonoCrudPage> {
  List<dynamic> telefonoList = [];
  bool loading = true;

  TextEditingController numeroController = TextEditingController();
  String? editingId;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => loading = true);
    try {
      final response = await http.get(Uri.parse(
          "https://educaysoft.org/apple6b/app/controllers/TelefonoController.php?action=api"));
      telefonoList = json.decode(response.body);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al obtener datos del servidor"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> guardarTelefono() async {
    if (numeroController.text.isEmpty) return;

    final url = editingId == null
        ? "https://educaysoft.org/apple6b/app/controllers/TelefonoController.php?action=insertar"
        : "https://educaysoft.org/apple6b/app/controllers/TelefonoController.php?action=actualizar&id=$editingId";

    try {
      final response = await http.post(Uri.parse(url), body: {
        "numero": numeroController.text,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editingId == null
                ? "Teléfono guardado correctamente"
                : "Teléfono actualizado correctamente"),
            backgroundColor: Colors.green,
          ),
        );

        numeroController.clear();
        editingId = null;
        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error al guardar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al conectar con el servidor"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> eliminarTelefono(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Desea eliminar este teléfono?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (!confirm) return;

    try {
      await http.get(Uri.parse(
          "https://educaysoft.org/apple6b/app/controllers/TelefonoController.php?action=eliminar&id=$id"));
      fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Teléfono eliminado correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error al eliminar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al eliminar el teléfono"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void cargarDatosParaEditar(item) {
    editingId = item["idtelefono"].toString();
    numeroController.text = item["numero"];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          editingId == null ? "Crear Teléfono" : "Editar Teléfono",
          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // --- Campo de número ---
                  TextField(
                    controller: numeroController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Número Teléfono",
                      hintText: "Ej: 0987654321",
                      filled: true,
                      fillColor: Colors.grey[900],
                      prefixIcon: const Icon(Icons.phone, color: Colors.redAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: const TextStyle(color: Colors.redAccent),
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Botón guardar/actualizar ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: guardarTelefono,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        editingId == null ? "Guardar" : "Actualizar",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Lista de teléfonos ---
                  Expanded(
                    child: ListView.builder(
                      itemCount: telefonoList.length,
                      itemBuilder: (context, index) {
                        final item = telefonoList[index];
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
                              leading: const Icon(Icons.phone, color: Colors.redAccent, size: 30),
                              title: Text(
                                item["numero"],
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "ID: ${item['idtelefono']}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.amber),
                                    onPressed: () => cargarDatosParaEditar(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => eliminarTelefono(
                                        item["idtelefono"].toString()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
