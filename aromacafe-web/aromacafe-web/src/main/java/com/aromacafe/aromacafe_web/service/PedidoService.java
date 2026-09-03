package com.aromacafe.aromacafe_web.service;

import com.aromacafe.aromacafe_web.model.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.*;

@Service
public class PedidoService {

    private final RestTemplate restTemplate;

    @Value("${api.base.url}")
    private String apiBaseUrl;

    public PedidoService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public List<Object> listar() {
        Object[] p = restTemplate.getForObject(apiBaseUrl + "/Pedidos", Object[].class);
        return p != null ? Arrays.asList(p) : List.of();
    }

    public void crear(PedidoCreate pedido) {
        restTemplate.postForObject(apiBaseUrl + "/Pedidos", pedido, Object.class);
    }
}