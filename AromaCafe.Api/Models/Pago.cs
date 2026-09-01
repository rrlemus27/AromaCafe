// Models/Pago.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AromaCafe.Api.Models;

[Table("Pago")]
public class Pago
{
    [Key]
    [Column("id_pago")]
    public int IdPago { get; set; }

    [Column("id_pedido")]
    public int IdPedido { get; set; }

    [Required, MaxLength(20)]
    [Column("metodo_pago")]
    public string MetodoPago { get; set; } = string.Empty;

    [Column("monto", TypeName = "decimal(10,2)")]
    public decimal Monto { get; set; }

    [Column("fecha_hora")]
    public DateTime FechaHora { get; set; } = DateTime.Now;

    [ForeignKey(nameof(IdPedido))]
    public Pedido? Pedido { get; set; }
}