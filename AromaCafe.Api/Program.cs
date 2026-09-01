// Program.cs
using AromaCafe.Api.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Conexion a SQL Server
builder.Services.AddDbContext<AromaCafeContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("AromaCafeDB")));

// Controllers + evitar ciclos de referencia al serializar JSON
builder.Services.AddControllers()
    .AddJsonOptions(opt =>
    {
        opt.JsonSerializerOptions.ReferenceHandler =
            System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    });

// Swagger / OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// CORS abierto (para que la web y la app movil puedan consumir la API)
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
});

var app = builder.Build();

// Swagger siempre activo (util para la evidencia)
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "AromaCafe API v1");
    c.RoutePrefix = "swagger";
});

app.UseCors();
app.UseAuthorization();
app.MapControllers();

app.Run();