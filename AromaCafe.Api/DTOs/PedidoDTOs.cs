// DTOs/PedidoDTOs.cs
using System.ComponentModel.DataAnnotations;

namespace AromaCafe.Api.DTOs;

// Para crear un pedido con sus lineas de una vez
public class PedidoCreateDTO
{
    public int? IdCliente { get; set; }

    [Required(ErrorMessage = "El usuario (empleado) es obligatorio")]
    public int IdUsuario { get; set; }

    public int? IdMesa { get; set; }

    [Required, MaxLength(20)]
    public string Tipo { get; set; } = "Local";

    [MinLength(1, ErrorMessage = "El pedido debe tener al menos un producto")]
    public List<DetalleCreateDTO> Detalles { get; set; } = new();
}

public class DetalleCreateDTO
{
    [Required]
    public int IdProducto { get; set; }

    [Range(1, 999, ErrorMessage = "La cantidad debe ser al menos 1")]
    public int Cantidad { get; set; }
}

public class EstadoUpdateDTO
{
    [Required, MaxLength(20)]
    public string Estado { get; set; } = string.Empty;
}

public class PagoCreateDTO
{
    [Required]
    public int IdPedido { get; set; }

    [Required, MaxLength(20)]
    public string MetodoPago { get; set; } = string.Empty;

    [Range(0, 99999)]
    public decimal Monto { get; set; }
}