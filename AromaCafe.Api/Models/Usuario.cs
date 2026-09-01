// Models/Usuario.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AromaCafe.Api.Models;

[Table("Usuario")]
public class Usuario
{
    [Key]
    [Column("id_usuario")]
    public int IdUsuario { get; set; }

    [Required, MaxLength(80)]
    [Column("nombre")]
    public string Nombre { get; set; } = string.Empty;

    [Required, MaxLength(120)]
    [Column("correo")]
    public string Correo { get; set; } = string.Empty;

    [Required, MaxLength(255)]
    [Column("password_hash")]
    public string PasswordHash { get; set; } = string.Empty;

    [Column("id_rol")]
    public int IdRol { get; set; }

    [Column("activo")]
    public bool Activo { get; set; } = true;

    [Column("fecha_registro")]
    public DateTime FechaRegistro { get; set; } = DateTime.Now;

    [ForeignKey(nameof(IdRol))]
    public Rol? Rol { get; set; }

    public ICollection<Pedido> Pedidos { get; set; } = new List<Pedido>();
}