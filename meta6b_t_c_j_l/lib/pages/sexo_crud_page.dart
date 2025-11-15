import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SexoCrudPage extends StatefulWidget {
  const SexoCrudPage({super.key});

  @override
  State<SexoCrudPage> createState() => _SexoCrudPageState();
}

class _SexoCrudPageState extends State<SexoCrudPage> {
  List<dynamic> sexoList = [];
  bool loading = true;

  TextEditingController nombreController = TextEditingController();
  String? editingId;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // --- OBTENER DATOS ---
  Future<void> fetchData() async {
    try {
      setState(() => loading = true);
      final response = await http.get(Uri.parse(
          "https://educaysoft.org/apple6b/app/controllers/SexoController.php?action=api"));
      if (response.statusCode == 200) {
        sexoList = json.decode(response.body);
      } else {
        print("Error al obtener datos: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al obtener datos: $e");
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  // --- GUARDAR / ACTUALIZAR SEXO ---
  Future<void> guardarSexo() async {
    if (nombreController.text.isEmpty) return;

    final url = editingId == null
        ? "https://educaysoft.org/apple6b/app/controllers/SexoController.php?action=insertar"
        : "https://educaysoft.org/apple6b/app/controllers/SexoController.php?action=actualizar&id=$editingId";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {"nombre": nombreController.text},
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editingId == null
                ? "Sexo guardado correctamente"
                : "Sexo actualizado correctamente"),
            backgroundColor: Colors.green,
          ),
        );

        nombreController.clear();
        editingId = null;
        await fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error al guardar sexo: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al conectar con el servidor"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- ELIMINAR SEXO ---
  Future<void> eliminarSexo(String id) async {
    try {
      final response = await http.get(Uri.parse(
          "https://educaysoft.org/apple6b/app/controllers/SexoController.php?action=eliminar&id=$id"));

      print("Status code eliminar: ${response.statusCode}");
      print("Response eliminar: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sexo eliminado correctamente"),
            backgroundColor: Colors.green,
          ),
        );
        await fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al eliminar: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error al eliminar sexo: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al conectar con el servidor"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- CARGAR DATOS PARA EDITAR ---
  void cargarDatosParaEditar(item) {
    editingId = item["idsexo"].toString();
    nombreController.text = item["nombre"];
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
          editingId == null ? "Crear Sexo" : "Editar Sexo",
          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: nombreController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Nombre Sexo",
                      hintText: "Ej: Masculino",
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: const TextStyle(color: Colors.redAccent),
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.person, color: Colors.redAccent),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      onPressed: guardarSexo,
                      child: Text(
                        editingId == null ? "Guardar" : "Actualizar",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: sexoList.length,
                    itemBuilder: (context, index) {
                      final item = sexoList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.grey[850]!, Colors.redAccent.withOpacity(0.2)],
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
                            title: Text(
                              item["nombre"],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "ID: ${item['idsexo']}",
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
                                  onPressed: () => eliminarSexo(item["idsexo"].toString()),
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
    );
  }
}
