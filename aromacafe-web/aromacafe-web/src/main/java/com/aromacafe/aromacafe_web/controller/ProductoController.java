// controller/ProductoController.java
package com.aromacafe.aromacafe_web.controller;

import com.aromacafe.aromacafe_web.model.Producto;
import com.aromacafe.aromacafe_web.service.ProductoService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/productos")
public class ProductoController {

    private final ProductoService productoService;

    public ProductoController(ProductoService productoService) {
        this.productoService = productoService;
    }

    // Listar
    @GetMapping
    public String listar(Model model) {
        model.addAttribute("productos", productoService.listar());
        return "productos/lista";
    }

    // Mostrar formulario para crear
    @GetMapping("/nuevo")
    public String nuevoForm(Model model) {
        model.addAttribute("producto", new Producto());
        return "productos/form";
    }

    // Guardar (crear)
    @PostMapping("/guardar")
    public String guardar(@ModelAttribute Producto producto) {
        productoService.crear(producto);
        return "redirect:/productos";
    }

    // Mostrar formulario para editar
    @GetMapping("/editar/{id}")
    public String editarForm(@PathVariable int id, Model model) {
        model.addAttribute("producto", productoService.obtener(id));
        return "productos/form";
    }

    // Actualizar
    @PostMapping("/actualizar/{id}")
    public String actualizar(@PathVariable int id, @ModelAttribute Producto producto) {
        productoService.actualizar(id, producto);
        return "redirect:/productos";
    }

    // Eliminar
    @GetMapping("/eliminar/{id}")
    public String eliminar(@PathVariable int id) {
        productoService.eliminar(id);
        return "redirect:/productos";
    }
}