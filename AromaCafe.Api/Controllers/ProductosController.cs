using AromaCafe.Api.Data;
using AromaCafe.Api.DTOs;
using AromaCafe.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AromaCafe.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductosController : ControllerBase
{
    private readonly AromaCafeContext _context;
    public ProductosController(AromaCafeContext context) => _context = context;

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProductoResponseDTO>>> GetProductos()
    {
        var productos = await _context.Productos
            .Include(p => p.Categoria)
            .Select(p => new ProductoResponseDTO
            {
                IdProducto = p.IdProducto,
                Nombre = p.Nombre,
                Descripcion = p.Descripcion,
                Precio = p.Precio,
                IdCategoria = p.IdCategoria,
                Categoria = p.Categoria != null ? p.Categoria.Nombre : null,
                Disponible = p.Disponible
            })
            .ToListAsync();
        return Ok(productos);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ProductoResponseDTO>> GetProducto(int id)
    {
        var p = await _context.Productos.Include(x => x.Categoria)
            .FirstOrDefaultAsync(x => x.IdProducto == id);
        if (p == null)
            return NotFound(new { mensaje = $"No existe el producto con id {id}" });

        return Ok(new ProductoResponseDTO
        {
            IdProducto = p.IdProducto,
            Nombre = p.Nombre,
            Descripcion = p.Descripcion,
            Precio = p.Precio,
            IdCategoria = p.IdCategoria,
            Categoria = p.Categoria?.Nombre,
            Disponible = p.Disponible
        });
    }

    [HttpPost]
    public async Task<ActionResult<Producto>> CrearProducto(ProductoCreateDTO dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        if (!await _context.Categorias.AnyAsync(c => c.IdCategoria == dto.IdCategoria))
            return BadRequest(new { mensaje = "La categoria indicada no existe" });

        var producto = new Producto
        {
            Nombre = dto.Nombre,
            Descripcion = dto.Descripcion,
            Precio = dto.Precio,
            IdCategoria = dto.IdCategoria,
            Disponible = dto.Disponible
        };
        _context.Productos.Add(producto);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetProducto), new { id = producto.IdProducto }, producto);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> ActualizarProducto(int id, ProductoCreateDTO dto)
    {
        var producto = await _context.Productos.FindAsync(id);
        if (producto == null)
            return NotFound(new { mensaje = $"No existe el producto con id {id}" });
        if (!await _context.Categorias.AnyAsync(c => c.IdCategoria == dto.IdCategoria))
            return BadRequest(new { mensaje = "La categoria indicada no existe" });

        producto.Nombre = dto.Nombre;
        producto.Descripcion = dto.Descripcion;
        producto.Precio = dto.Precio;
        producto.IdCategoria = dto.IdCategoria;
        producto.Disponible = dto.Disponible;
        await _context.SaveChangesAsync();
        return Ok(producto);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> EliminarProducto(int id)
    {
        var producto = await _context.Productos.FindAsync(id);
        if (producto == null)
            return NotFound(new { mensaje = $"No existe el producto con id {id}" });
        _context.Productos.Remove(producto);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}