package com.aromacafe.aromacafe_web.model;

import java.util.List;

public class PedidoCreate {
    private Integer idCliente;
    private int idUsuario;
    private Integer idMesa;
    private String tipo;
    private List<DetalleCreate> detalles;

    public Integer getIdCliente() { return idCliente; }
    public void setIdCliente(Integer idCliente) { this.idCliente = idCliente; }
    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }
    public Integer getIdMesa() { return idMesa; }
    public void setIdMesa(Integer idMesa) { this.idMesa = idMesa; }
    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }
    public List<DetalleCreate> getDetalles() { return detalles; }
    public void setDetalles(List<DetalleCreate> detalles) { this.detalles = detalles; }
}