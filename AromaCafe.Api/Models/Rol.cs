// Models/Rol.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AromaCafe.Api.Models;

[Table("Rol")]
public class Rol
{
    [Key]
    [Column("id_rol")]
    public int IdRol { get; set; }

    [Required, MaxLength(30)]
    [Column("nombre")]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(100)]
    [Column("descripcion")]
    public string? Descripcion { get; set; }

    public ICollection<Usuario> Usuarios { get; set; } = new List<Usuario>();
}