using AromaCafe.Api.Data;
using AromaCafe.Api.DTOs;
using AromaCafe.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AromaCafe.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PedidosController : ControllerBase
{
    private readonly AromaCafeContext _context;
    public PedidosController(AromaCafeContext context) => _context = context;

    // GET: api/pedidos  (lista con cliente, empleado y lineas)
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Pedido>>> GetPedidos()
    {
        var pedidos = await _context.Pedidos
            .Include(p => p.Cliente)
            .Include(p => p.Usuario)
            .Include(p => p.Mesa)
            .Include(p => p.Detalles).ThenInclude(d => d.Producto)
            .OrderByDescending(p => p.FechaHora)
            .ToListAsync();
        return Ok(pedidos);
    }

    // GET: api/pedidos/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Pedido>> GetPedido(int id)
    {
        var pedido = await _context.Pedidos
            .Include(p => p.Cliente)
            .Include(p => p.Usuario)
            .Include(p => p.Mesa)
            .Include(p => p.Detalles).ThenInclude(d => d.Producto)
            .Include(p => p.Pago)
            .FirstOrDefaultAsync(p => p.IdPedido == id);

        if (pedido == null)
            return NotFound(new { mensaje = $"No existe el pedido con id {id}" });
        return Ok(pedido);
    }

    // POST: api/pedidos  (OPERACION PRINCIPAL: crear pedido con sus productos)
    [HttpPost]
    public async Task<ActionResult<Pedido>> CrearPedido(PedidoCreateDTO dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        // Validar empleado
        if (!await _context.Usuarios.AnyAsync(u => u.IdUsuario == dto.IdUsuario))
            return BadRequest(new { mensaje = "El empleado (usuario) indicado no existe" });

        // Validar cliente si viene
        if (dto.IdCliente.HasValue &&
            !await _context.Clientes.AnyAsync(c => c.IdCliente == dto.IdCliente))
            return BadRequest(new { mensaje = "El cliente indicado no existe" });

        // Validar mesa si viene
        if (dto.IdMesa.HasValue &&
            !await _context.Mesas.AnyAsync(m => m.IdMesa == dto.IdMesa))
            return BadRequest(new { mensaje = "La mesa indicada no existe" });

        if (dto.Detalles == null || dto.Detalles.Count == 0)
            return BadRequest(new { mensaje = "El pedido debe tener al menos un producto" });

        // Crear encabezado
        var pedido = new Pedido
        {
            IdCliente = dto.IdCliente,
            IdUsuario = dto.IdUsuario,
            IdMesa = dto.IdMesa,
            Tipo = dto.Tipo,
            Estado = "Pendiente",
            FechaHora = DateTime.Now,
            Total = 0
        };

        decimal total = 0;
        foreach (var item in dto.Detalles)
        {
            var producto = await _context.Productos.FindAsync(item.IdProducto);
            if (producto == null)
                return BadRequest(new { mensaje = $"El producto con id {item.IdProducto} no existe" });
            if (!producto.Disponible)
                return BadRequest(new { mensaje = $"El producto '{producto.Nombre}' no esta disponible" });

            var detalle = new DetallePedido
            {
                IdProducto = producto.IdProducto,
                Cantidad = item.Cantidad,
                PrecioUnitario = producto.Precio
                // Subtotal lo calcula la BD (columna calculada)
            };
            pedido.Detalles.Add(detalle);
            total += producto.Precio * item.Cantidad;
        }

        pedido.Total = total;
        _context.Pedidos.Add(pedido);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetPedido), new { id = pedido.IdPedido }, pedido);
    }

    // PUT: api/pedidos/5/estado  (actualizar estado del pedido)
    [HttpPut("{id}/estado")]
    public async Task<IActionResult> ActualizarEstado(int id, EstadoUpdateDTO dto)
    {
        var estadosValidos = new[] { "Pendiente", "En preparacion", "Listo", "Entregado", "Cancelado" };
        if (!estadosValidos.Contains(dto.Estado))
            return BadRequest(new { mensaje = "Estado invalido. Use: " + string.Join(", ", estadosValidos) });

        var pedido = await _context.Pedidos.FindAsync(id);
        if (pedido == null)
            return NotFound(new { mensaje = $"No existe el pedido con id {id}" });

        pedido.Estado = dto.Estado;
        await _context.SaveChangesAsync();
        return Ok(new { mensaje = $"Pedido {id} actualizado a '{dto.Estado}'", pedido });
    }

    // GET: api/pedidos/ventas-por-dia  (reporte)
    [HttpGet("ventas-por-dia")]
    public async Task<IActionResult> VentasPorDia()
    {
        var ventas = await _context.Pedidos
            .Where(p => p.Estado != "Cancelado")
            .GroupBy(p => p.FechaHora.Date)
            .Select(g => new
            {
                Dia = g.Key,
                CantidadPedidos = g.Count(),
                VentaTotal = g.Sum(p => p.Total)
            })
            .OrderByDescending(x => x.Dia)
            .ToListAsync();
        return Ok(ventas);
    }
}