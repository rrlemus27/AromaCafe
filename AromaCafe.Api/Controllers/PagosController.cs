using AromaCafe.Api.Data;
using AromaCafe.Api.DTOs;
using AromaCafe.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AromaCafe.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PagosController : ControllerBase
{
    private readonly AromaCafeContext _context;
    public PagosController(AromaCafeContext context) => _context = context;

    // GET: api/pagos
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Pago>>> GetPagos()
        => Ok(await _context.Pagos.Include(p => p.Pedido).ToListAsync());

    // GET: api/pagos/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Pago>> GetPago(int id)
    {
        var pago = await _context.Pagos.Include(p => p.Pedido)
            .FirstOrDefaultAsync(p => p.IdPago == id);
        if (pago == null)
            return NotFound(new { mensaje = $"No existe el pago con id {id}" });
        return Ok(pago);
    }

    // POST: api/pagos  (registrar el pago de un pedido)
    [HttpPost]
    public async Task<ActionResult<Pago>> RegistrarPago(PagoCreateDTO dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var metodosValidos = new[] { "Efectivo", "Tarjeta", "Transferencia" };
        if (!metodosValidos.Contains(dto.MetodoPago))
            return BadRequest(new { mensaje = "Metodo invalido. Use: Efectivo, Tarjeta o Transferencia" });

        var pedido = await _context.Pedidos.FindAsync(dto.IdPedido);
        if (pedido == null)
            return BadRequest(new { mensaje = $"No existe el pedido con id {dto.IdPedido}" });

        // Un pago por pedido (relacion 1:1)
        if (await _context.Pagos.AnyAsync(p => p.IdPedido == dto.IdPedido))
            return BadRequest(new { mensaje = "Este pedido ya tiene un pago registrado" });

        var pago = new Pago
        {
            IdPedido = dto.IdPedido,
            MetodoPago = dto.MetodoPago,
            Monto = dto.Monto,
            FechaHora = DateTime.Now
        };
        _context.Pagos.Add(pago);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetPago), new { id = pago.IdPago }, pago);
    }
}