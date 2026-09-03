package com.aromacafe.aromacafe_web.service;

import com.aromacafe.aromacafe_web.model.Cliente;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.Arrays;
import java.util.List;

@Service
public class ClienteService {

    private final RestTemplate restTemplate;

    @Value("${api.base.url}")
    private String apiBaseUrl;

    public ClienteService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    private String url() {
        return apiBaseUrl + "/Clientes";
    }

    public List<Cliente> listar() {
        Cliente[] c = restTemplate.getForObject(url(), Cliente[].class);
        return c != null ? Arrays.asList(c) : List.of();
    }

    public Cliente obtener(int id) {
        return restTemplate.getForObject(url() + "/" + id, Cliente.class);
    }

    public void crear(Cliente cliente) {
        restTemplate.postForObject(url(), cliente, Cliente.class);
    }

    public void actualizar(int id, Cliente cliente) {
        restTemplate.put(url() + "/" + id, cliente);
    }

    public void eliminar(int id) {
        restTemplate.delete(url() + "/" + id);
    }
}