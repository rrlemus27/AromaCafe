// DTOs/ProductoDTOs.cs
using System.ComponentModel.DataAnnotations;

namespace AromaCafe.Api.DTOs;

public class ProductoCreateDTO
{
    [Required(ErrorMessage = "El nombre es obligatorio")]
    [MaxLength(80)]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(200)]
    public string? Descripcion { get; set; }

    [Range(0, 9999, ErrorMessage = "El precio debe ser mayor o igual a 0")]
    public decimal Precio { get; set; }

    [Required(ErrorMessage = "La categoria es obligatoria")]
    public int IdCategoria { get; set; }

    public bool Disponible { get; set; } = true;
}

public class ProductoResponseDTO
{
    public int IdProducto { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public decimal Precio { get; set; }
    public int IdCategoria { get; set; }
    public string? Categoria { get; set; }
    public bool Disponible { get; set; }
}