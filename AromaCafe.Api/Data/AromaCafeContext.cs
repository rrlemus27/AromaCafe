// Data/AromaCafeContext.cs
using AromaCafe.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace AromaCafe.Api.Data;

public class AromaCafeContext : DbContext
{
    public AromaCafeContext(DbContextOptions<AromaCafeContext> options) : base(options) { }

    public DbSet<Rol> Roles { get; set; }
    public DbSet<Usuario> Usuarios { get; set; }
    public DbSet<Cliente> Clientes { get; set; }
    public DbSet<Categoria> Categorias { get; set; }
    public DbSet<Producto> Productos { get; set; }
    public DbSet<Mesa> Mesas { get; set; }
    public DbSet<Pedido> Pedidos { get; set; }
    public DbSet<DetallePedido> DetallesPedido { get; set; }
    public DbSet<Pago> Pagos { get; set; }
    public DbSet<Auditoria> Auditorias { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Relacion 1:1 entre Pedido y Pago
        modelBuilder.Entity<Pago>()
            .HasOne(p => p.Pedido)
            .WithOne(pe => pe.Pago)
            .HasForeignKey<Pago>(p => p.IdPedido);

        // Evitar borrados en cascada que choquen con las FK de SQL Server
        foreach (var fk in modelBuilder.Model.GetEntityTypes()
                     .SelectMany(t => t.GetForeignKeys()))
        {
            fk.DeleteBehavior = DeleteBehavior.Restrict;
        }
    }
}