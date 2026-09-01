// DTOs/ClienteDTOs.cs
using System.ComponentModel.DataAnnotations;

namespace AromaCafe.Api.DTOs;

public class ClienteCreateDTO
{
    [Required, MaxLength(80)]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(15)]
    public string? Telefono { get; set; }

    [MaxLength(120)]
    [EmailAddress(ErrorMessage = "El correo no tiene un formato valido")]
    public string? Correo { get; set; }

    [MaxLength(150)]
    public string? Direccion { get; set; }
}