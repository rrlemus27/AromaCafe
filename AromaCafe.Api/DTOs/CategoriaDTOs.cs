// DTOs/CategoriaDTOs.cs
using System.ComponentModel.DataAnnotations;

namespace AromaCafe.Api.DTOs;

public class CategoriaCreateDTO
{
    [Required, MaxLength(50)]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(150)]
    public string? Descripcion { get; set; }
}