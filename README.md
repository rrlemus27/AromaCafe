# AromaCafe — Solución tecnológica para cafetería

Proyecto integrador final (MOD 3.3, 3.4, 3.5) — Colegio Español Padre Arrupe.
Sistema integral de gestión para una cafetería, compuesto por una base de datos
relacional, una API REST en .NET, una aplicación web en Spring Boot y una
aplicación móvil en Flutter/Kotlin, comunicadas mediante HTTP/REST.

**Estudiante:** Rodrigo Cruz Lemus — N.º de lista 5
**Docente:** Daniel Sosa
**Emprendimiento:** Cafetería

## Arquitectura

```
Aplicación Web (Spring Boot) ─┐
                              ├─ HTTP/REST ─► API REST (.NET / ASP.NET Core) ─► Base de Datos (SQL Server)
Aplicación Móvil (Flutter) ───┘
```

## Estructura del repositorio

```
.
├── 01-Analisis-Diseno/
│   ├── Documentacion-Fase1.pdf     Documentación completa de análisis y diseño
│   ├── BaseDeDatos.sql             Script de creación, datos, consultas y CRUD
│   └── diagramas/
│       ├── CasosDeUso.png
│       ├── DiagramaClases.png
│       └── ModeloER.png
├── 02-API/          (Fase 2 — API REST .NET)
├── 03-Web/          (Fase 3 — Aplicación web Spring Boot)
└── 04-Mobile/       (Fase 4 — Aplicación móvil Flutter/Kotlin)
```

## Fase 1 — Análisis y diseño

La carpeta `01-Analisis-Diseno/` contiene:

- Definición del emprendimiento (caso de estudio, actores y procesos).
- 12 requerimientos funcionales.
- Diagrama de casos de uso UML.
- Diagrama de clases UML.
- Modelo entidad-relación.
- Diseño de la base de datos (9 tablas con PK, FK, tipos y restricciones).
- Implementación física en SQL Server (`BaseDeDatos.sql`).

## Tecnologías

| Componente       | Tecnología              |
|------------------|-------------------------|
| Base de datos    | Microsoft SQL Server    |
| API / Microservicios | .NET / ASP.NET Core |
| Aplicación web   | Spring / Spring Boot    |
| Aplicación móvil | Flutter o Kotlin        |
| Comunicación     | API REST / HTTP         |
| Documentación API| Swagger / Postman       |
