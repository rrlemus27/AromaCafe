// Models/Producto.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AromaCafe.Api.Models;

[Table("Producto")]
public class Producto
{
    [Key]
    [Column("id_producto")]
    public int IdProducto { get; set; }

    [Required, MaxLength(80)]
    [Column("nombre")]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(200)]
    [Column("descripcion")]
    public string? Descripcion { get; set; }

    [Column("precio", TypeName = "decimal(8,2)")]
    public decimal Precio { get; set; }

    [Column("id_categoria")]
    public int IdCategoria { get; set; }

    [Column("disponible")]
    public bool Disponible { get; set; } = true;

    [ForeignKey(nameof(IdCategoria))]
    public Categoria? Categoria { get; set; }

    public ICollection<DetallePedido> Detalles { get; set; } = new List<DetallePedido>();
}