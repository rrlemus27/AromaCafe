// Models/Mesa.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AromaCafe.Api.Models;

[Table("Mesa")]
public class Mesa
{
    [Key]
    [Column("id_mesa")]
    public int IdMesa { get; set; }

    [Column("numero")]
    public int Numero { get; set; }

    [Column("capacidad")]
    public int Capacidad { get; set; }

    [Required, MaxLength(20)]
    [Column("estado")]
    public string Estado { get; set; } = "Libre";

    public ICollection<Pedido> Pedidos { get; set; } = new List<Pedido>();
}