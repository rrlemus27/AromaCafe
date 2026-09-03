using AromaCafe.Api.Data;
using AromaCafe.Api.DTOs;
using AromaCafe.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AromaCafe.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ClientesController : ControllerBase
{
    private readonly AromaCafeContext _context;
    public ClientesController(AromaCafeContext context) => _context = context;

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Cliente>>> GetClientes()
        => Ok(await _context.Clientes.ToListAsync());

    [HttpGet("{id}")]
    public async Task<ActionResult<Cliente>> GetCliente(int id)
    {
        var cliente = await _context.Clientes.FindAsync(id);
        if (cliente == null)
            return NotFound(new { mensaje = $"No existe el cliente con id {id}" });
        return Ok(cliente);
    }

    [HttpPost]
    public async Task<ActionResult<Cliente>> CrearCliente(ClienteCreateDTO dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        var cliente = new Cliente
        {
            Nombre = dto.Nombre,
            Telefono = dto.Telefono,
            Correo = dto.Correo,
            Direccion = dto.Direccion
        };
        _context.Clientes.Add(cliente);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetCliente), new { id = cliente.IdCliente }, cliente);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> ActualizarCliente(int id, ClienteCreateDTO dto)
    {
        var cliente = await _context.Clientes.FindAsync(id);
        if (cliente == null)
            return NotFound(new { mensaje = $"No existe el cliente con id {id}" });
        cliente.Nombre = dto.Nombre;
        cliente.Telefono = dto.Telefono;
        cliente.Correo = dto.Correo;
        cliente.Direccion = dto.Direccion;
        await _context.SaveChangesAsync();
        return Ok(cliente);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> EliminarCliente(int id)
    {
        var cliente = await _context.Clientes.FindAsync(id);
        if (cliente == null)
            return NotFound(new { mensaje = $"No existe el cliente con id {id}" });
        _context.Clientes.Remove(cliente);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}