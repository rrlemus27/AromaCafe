// Models/Auditoria.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AromaCafe.Api.Models;

[Table("Auditoria")]
public class Auditoria
{
    [Key]
    [Column("id_auditoria")]
    public int IdAuditoria { get; set; }

    [Required, MaxLength(50)]
    [Column("tabla_afectada")]
    public string TablaAfectada { get; set; } = string.Empty;

    [Required, MaxLength(10)]
    [Column("operacion")]
    public string Operacion { get; set; } = string.Empty;

    [Column("id_registro")]
    public int? IdRegistro { get; set; }

    [MaxLength(255)]
    [Column("detalle")]
    public string? Detalle { get; set; }

    [Required, MaxLength(100)]
    [Column("usuario_bd")]
    public string UsuarioBd { get; set; } = string.Empty;

    [Column("fecha_hora")]
    public DateTime FechaHora { get; set; } = DateTime.Now;
}