// Models/DetallePedido.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AromaCafe.Api.Models;

[Table("DetallePedido")]
public class DetallePedido
{
    [Key]
    [Column("id_detalle")]
    public int IdDetalle { get; set; }

    [Column("id_pedido")]
    public int IdPedido { get; set; }

    [Column("id_producto")]
    public int IdProducto { get; set; }

    [Column("cantidad")]
    public int Cantidad { get; set; }

    [Column("precio_unitario", TypeName = "decimal(8,2)")]
    public decimal PrecioUnitario { get; set; }

    // Columna calculada en la BD (subtotal = cantidad * precio_unitario)
    [Column("subtotal", TypeName = "decimal(10,2)")]
    [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
    public decimal Subtotal { get; set; }

    [ForeignKey(nameof(IdPedido))]
    public Pedido? Pedido { get; set; }

    [ForeignKey(nameof(IdProducto))]
    public Producto? Producto { get; set; }
}