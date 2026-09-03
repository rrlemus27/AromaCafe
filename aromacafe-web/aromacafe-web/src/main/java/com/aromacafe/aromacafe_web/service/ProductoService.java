// service/ProductoService.java
package com.aromacafe.aromacafe_web.service;

import com.aromacafe.aromacafe_web.model.Producto;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Arrays;
import java.util.List;

@Service
public class ProductoService {

    private final RestTemplate restTemplate;

    @Value("${api.base.url}")
    private String apiBaseUrl;

    public ProductoService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    private String url() {
        return apiBaseUrl + "/Productos";
    }

    // Listar todos
    public List<Producto> listar() {
        Producto[] productos = restTemplate.getForObject(url(), Producto[].class);
        return productos != null ? Arrays.asList(productos) : List.of();
    }

    // Obtener uno por id
    public Producto obtener(int id) {
        return restTemplate.getForObject(url() + "/" + id, Producto.class);
    }

    // Crear
    public void crear(Producto producto) {
        restTemplate.postForObject(url(), producto, Producto.class);
    }

    // Actualizar
    public void actualizar(int id, Producto producto) {
        restTemplate.put(url() + "/" + id, producto);
    }

    // Eliminar
    public void eliminar(int id) {
        restTemplate.delete(url() + "/" + id);
    }
}