// Models/Pedido.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AromaCafe.Api.Models;

[Table("Pedido")]
public class Pedido
{
    [Key]
    [Column("id_pedido")]
    public int IdPedido { get; set; }

    [Column("id_cliente")]
    public int? IdCliente { get; set; }

    [Column("id_usuario")]
    public int IdUsuario { get; set; }

    [Column("id_mesa")]
    public int? IdMesa { get; set; }

    [Column("fecha_hora")]
    public DateTime FechaHora { get; set; } = DateTime.Now;

    [Required, MaxLength(20)]
    [Column("tipo")]
    public string Tipo { get; set; } = "Local";

    [Required, MaxLength(20)]
    [Column("estado")]
    public string Estado { get; set; } = "Pendiente";

    [Column("total", TypeName = "decimal(10,2)")]
    public decimal Total { get; set; }

    [ForeignKey(nameof(IdCliente))]
    public Cliente? Cliente { get; set; }

    [ForeignKey(nameof(IdUsuario))]
    public Usuario? Usuario { get; set; }

    [ForeignKey(nameof(IdMesa))]
    public Mesa? Mesa { get; set; }

    public ICollection<DetallePedido> Detalles { get; set; } = new List<DetallePedido>();
    public Pago? Pago { get; set; }
}