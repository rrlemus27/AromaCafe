// Models/Cliente.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AromaCafe.Api.Models;

[Table("Cliente")]
public class Cliente
{
    [Key]
    [Column("id_cliente")]
    public int IdCliente { get; set; }

    [Required, MaxLength(80)]
    [Column("nombre")]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(15)]
    [Column("telefono")]
    public string? Telefono { get; set; }

    [MaxLength(120)]
    [Column("correo")]
    public string? Correo { get; set; }

    [MaxLength(150)]
    [Column("direccion")]
    public string? Direccion { get; set; }

    [Column("fecha_registro")]
    public DateTime FechaRegistro { get; set; } = DateTime.Now;

    public ICollection<Pedido> Pedidos { get; set; } = new List<Pedido>();
}