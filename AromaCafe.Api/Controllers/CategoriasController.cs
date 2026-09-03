using AromaCafe.Api.Data;
using AromaCafe.Api.DTOs;
using AromaCafe.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AromaCafe.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoriasController : ControllerBase
{
    private readonly AromaCafeContext _context;
    public CategoriasController(AromaCafeContext context) => _context = context;

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Categoria>>> GetCategorias()
        => Ok(await _context.Categorias.ToListAsync());

    [HttpGet("{id}")]
    public async Task<ActionResult<Categoria>> GetCategoria(int id)
    {
        var categoria = await _context.Categorias.FindAsync(id);
        if (categoria == null)
            return NotFound(new { mensaje = $"No existe la categoria con id {id}" });
        return Ok(categoria);
    }

    [HttpPost]
    public async Task<ActionResult<Categoria>> CrearCategoria(CategoriaCreateDTO dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        var categoria = new Categoria { Nombre = dto.Nombre, Descripcion = dto.Descripcion };
        _context.Categorias.Add(categoria);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetCategoria), new { id = categoria.IdCategoria }, categoria);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> ActualizarCategoria(int id, CategoriaCreateDTO dto)
    {
        var categoria = await _context.Categorias.FindAsync(id);
        if (categoria == null)
            return NotFound(new { mensaje = $"No existe la categoria con id {id}" });
        categoria.Nombre = dto.Nombre;
        categoria.Descripcion = dto.Descripcion;
        await _context.SaveChangesAsync();
        return Ok(categoria);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> EliminarCategoria(int id)
    {
        var categoria = await _context.Categorias.FindAsync(id);
        if (categoria == null)
            return NotFound(new { mensaje = $"No existe la categoria con id {id}" });
        _context.Categorias.Remove(categoria);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}