import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// URL base de la API.
// Emulador Android: usa 10.0.2.2 (apunta a tu PC).
// Celular fisico: reemplaza por la IP de tu PC (ej. 192.168.1.10).
const String apiBaseUrl = "http://10.0.2.2:5053/api";

void main() {
  runApp(const AromaCafeApp());
}

class AromaCafeApp extends StatelessWidget {
  const AromaCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AromaCafe',
      theme: ThemeData(
        primaryColor: const Color(0xFF5B3A29),
        scaffoldBackgroundColor: const Color(0xFFFBF7F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5B3A29),
          foregroundColor: Colors.white,
        ),
      ),
      home: const InicioScreen(),
    );
  }
}

// ---------- MODELO ----------
class Producto {
  final int idProducto;
  final String nombre;
  final String? categoria;
  final double precio;
  final bool disponible;

  Producto({
    required this.idProducto,
    required this.nombre,
    this.categoria,
    required this.precio,
    required this.disponible,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['idProducto'],
      nombre: json['nombre'],
      categoria: json['categoria'],
      precio: (json['precio'] as num).toDouble(),
      disponible: json['disponible'],
    );
  }
}

// ---------- SERVICIO (llama a la API) ----------
class ApiService {
  static Future<List<Producto>> obtenerProductos() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/Productos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Producto.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar productos (${response.statusCode})');
    }
  }

  static Future<void> crearProducto(String nombre, double precio, int idCategoria) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/Productos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'precio': precio,
        'idCategoria': idCategoria,
        'disponible': true,
      }),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear producto (${response.statusCode})');
    }
  }
}

// ---------- PANTALLA INICIO ----------
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AromaCafe')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text('Sistema de gestión de cafetería',
                style: TextStyle(fontSize: 18, color: Color(0xFF5B3A29))),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB45309),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProductosScreen()));
              },
              child: const Text('Ver productos', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- PANTALLA LISTA DE PRODUCTOS ----------
class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  late Future<List<Producto>> _productos;

  @override
  void initState() {
    super.initState();
    _productos = ApiService.obtenerProductos();
  }

  void _recargar() {
    setState(() {
      _productos = ApiService.obtenerProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB45309),
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CrearProductoScreen()));
          _recargar();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Producto>>(
        future: _productos,
        builder: (context, snapshot) {
          // Estado de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Estado de error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('No se pudo conectar con la API.\n${snapshot.error}',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: _recargar, child: const Text('Reintentar')),
                  ],
                ),
              ),
            );
          }
          // Datos cargados
          final productos = snapshot.data ?? [];
          if (productos.isEmpty) {
            return const Center(child: Text('No hay productos.'));
          }
          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, i) {
              final p = productos[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(p.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${p.categoria ?? "Sin categoría"} — \$${p.precio}'),
                  trailing: Text(p.disponible ? 'Disponible' : 'Agotado',
                      style: TextStyle(
                          color: p.disponible ? Colors.green : Colors.red)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------- PANTALLA CREAR PRODUCTO ----------
class CrearProductoScreen extends StatefulWidget {
  const CrearProductoScreen({super.key});

  @override
  State<CrearProductoScreen> createState() => _CrearProductoScreenState();
}

class _CrearProductoScreenState extends State<CrearProductoScreen> {
  final _nombre = TextEditingController();
  final _precio = TextEditingController();
  final _idCategoria = TextEditingController();
  bool _guardando = false;

  Future<void> _guardar() async {
    if (_nombre.text.isEmpty || _precio.text.isEmpty || _idCategoria.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa todos los campos')));
      return;
    }
    setState(() => _guardando = true);
    try {
      await ApiService.crearProducto(
        _nombre.text,
        double.parse(_precio.text),
        int.parse(_idCategoria.text),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto creado con éxito')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo producto')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(
                controller: _precio,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio')),
            TextField(
                controller: _idCategoria,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ID Categoría')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB45309),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}