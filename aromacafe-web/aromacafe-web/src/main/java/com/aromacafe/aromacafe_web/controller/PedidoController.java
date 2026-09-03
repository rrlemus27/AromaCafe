package com.aromacafe.aromacafe_web.controller;

import com.aromacafe.aromacafe_web.model.*;
import com.aromacafe.aromacafe_web.service.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@Controller
@RequestMapping("/pedidos")
public class PedidoController {

    private final PedidoService pedidoService;
    private final ProductoService productoService;
    private final ClienteService clienteService;

    public PedidoController(PedidoService pedidoService, ProductoService productoService, ClienteService clienteService) {
        this.pedidoService = pedidoService;
        this.productoService = productoService;
        this.clienteService = clienteService;
    }

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("pedidos", pedidoService.listar());
        return "pedidos/lista";
    }

    @GetMapping("/nuevo")
    public String nuevoForm(Model model) {
        model.addAttribute("productos", productoService.listar());
        model.addAttribute("clientes", clienteService.listar());
        return "pedidos/form";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(required = false) Integer idCliente,
                          @RequestParam int idUsuario,
                          @RequestParam(required = false) Integer idMesa,
                          @RequestParam String tipo,
                          @RequestParam List<Integer> idProducto,
                          @RequestParam List<Integer> cantidad) {
        PedidoCreate pedido = new PedidoCreate();
        pedido.setIdCliente(idCliente);
        pedido.setIdUsuario(idUsuario);
        pedido.setIdMesa(idMesa);
        pedido.setTipo(tipo);

        List<DetalleCreate> detalles = new ArrayList<>();
        for (int i = 0; i < idProducto.size(); i++) {
            if (cantidad.get(i) != null && cantidad.get(i) > 0) {
                DetalleCreate d = new DetalleCreate();
                d.setIdProducto(idProducto.get(i));
                d.setCantidad(cantidad.get(i));
                detalles.add(d);
            }
        }
        pedido.setDetalles(detalles);
        pedidoService.crear(pedido);
        return "redirect:/pedidos";
    }
}