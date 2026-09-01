// Models/Categoria.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AromaCafe.Api.Models;

[Table("Categoria")]
public class Categoria
{
    [Key]
    [Column("id_categoria")]
    public int IdCategoria { get; set; }

    [Required, MaxLength(50)]
    [Column("nombre")]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(150)]
    [Column("descripcion")]
    public string? Descripcion { get; set; }

    public ICollection<Producto> Productos { get; set; } = new List<Producto>();
}