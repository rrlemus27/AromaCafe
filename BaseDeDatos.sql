/* ============================================================================
   PROYECTO INTEGRADOR - CAFETERIA "AromaCafe"
   Fase 1 - Diseno e implementacion de la base de datos
   Motor: Microsoft SQL Server
   Autor: Rodrigo Cruz Lemus
   ----------------------------------------------------------------------------
   Contenido:
     1. Creacion de la base de datos
     2. Creacion de tablas (PK, FK, tipos de datos y restricciones)
     3. Insercion de datos de prueba
     4. Consultas de demostracion
     5. Operaciones CRUD de ejemplo
============================================================================ */

/* ---------------------------------------------------------------------------
   1. CREACION DE LA BASE DE DATOS
--------------------------------------------------------------------------- */
IF DB_ID('AromaCafeDB') IS NOT NULL
BEGIN
    ALTER DATABASE AromaCafeDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AromaCafeDB;
END
GO

CREATE DATABASE AromaCafeDB;
GO

USE AromaCafeDB;
GO

/* ---------------------------------------------------------------------------
   2. CREACION DE TABLAS
--------------------------------------------------------------------------- */

-- Tabla: Rol -----------------------------------------------------------------
CREATE TABLE Rol (
    id_rol        INT           IDENTITY(1,1) NOT NULL,
    nombre        VARCHAR(30)   NOT NULL,
    descripcion   VARCHAR(100)  NULL,
    CONSTRAINT PK_Rol PRIMARY KEY (id_rol),
    CONSTRAINT UQ_Rol_nombre UNIQUE (nombre)
);
GO

-- Tabla: Usuario -------------------------------------------------------------
CREATE TABLE Usuario (
    id_usuario     INT           IDENTITY(1,1) NOT NULL,
    nombre         VARCHAR(80)   NOT NULL,
    correo         VARCHAR(120)  NOT NULL,
    password_hash  VARCHAR(255)  NOT NULL,
    id_rol         INT           NOT NULL,
    activo         BIT           NOT NULL CONSTRAINT DF_Usuario_activo DEFAULT (1),
    fecha_registro DATETIME      NOT NULL CONSTRAINT DF_Usuario_fecha DEFAULT (GETDATE()),
    CONSTRAINT PK_Usuario PRIMARY KEY (id_usuario),
    CONSTRAINT UQ_Usuario_correo UNIQUE (correo),
    CONSTRAINT FK_Usuario_Rol FOREIGN KEY (id_rol) REFERENCES Rol(id_rol)
);
GO

-- Tabla: Cliente -------------------------------------------------------------
CREATE TABLE Cliente (
    id_cliente     INT           IDENTITY(1,1) NOT NULL,
    nombre         VARCHAR(80)   NOT NULL,
    telefono       VARCHAR(15)   NULL,
    correo         VARCHAR(120)  NULL,
    direccion      VARCHAR(150)  NULL,
    fecha_registro DATETIME      NOT NULL CONSTRAINT DF_Cliente_fecha DEFAULT (GETDATE()),
    CONSTRAINT PK_Cliente PRIMARY KEY (id_cliente)
);
GO

-- Tabla: Categoria -----------------------------------------------------------
CREATE TABLE Categoria (
    id_categoria  INT           IDENTITY(1,1) NOT NULL,
    nombre        VARCHAR(50)   NOT NULL,
    descripcion   VARCHAR(150)  NULL,
    CONSTRAINT PK_Categoria PRIMARY KEY (id_categoria),
    CONSTRAINT UQ_Categoria_nombre UNIQUE (nombre)
);
GO

-- Tabla: Producto ------------------------------------------------------------
CREATE TABLE Producto (
    id_producto   INT           IDENTITY(1,1) NOT NULL,
    nombre        VARCHAR(80)   NOT NULL,
    descripcion   VARCHAR(200)  NULL,
    precio        DECIMAL(8,2)  NOT NULL,
    id_categoria  INT           NOT NULL,
    disponible    BIT           NOT NULL CONSTRAINT DF_Producto_disp DEFAULT (1),
    CONSTRAINT PK_Producto PRIMARY KEY (id_producto),
    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria),
    CONSTRAINT CK_Producto_precio CHECK (precio >= 0)
);
GO

-- Tabla: Mesa ----------------------------------------------------------------
CREATE TABLE Mesa (
    id_mesa       INT           IDENTITY(1,1) NOT NULL,
    numero        INT           NOT NULL,
    capacidad     INT           NOT NULL,
    estado        VARCHAR(20)   NOT NULL CONSTRAINT DF_Mesa_estado DEFAULT ('Libre'),
    CONSTRAINT PK_Mesa PRIMARY KEY (id_mesa),
    CONSTRAINT UQ_Mesa_numero UNIQUE (numero),
    CONSTRAINT CK_Mesa_capacidad CHECK (capacidad > 0),
    CONSTRAINT CK_Mesa_estado CHECK (estado IN ('Libre','Ocupada','Reservada'))
);
GO

-- Tabla: Pedido --------------------------------------------------------------
CREATE TABLE Pedido (
    id_pedido     INT           IDENTITY(1,1) NOT NULL,
    id_cliente    INT           NULL,   -- puede ser venta rapida sin cliente registrado
    id_usuario    INT           NOT NULL,
    id_mesa       INT           NULL,   -- NULL cuando el pedido es "Para llevar"
    fecha_hora    DATETIME      NOT NULL CONSTRAINT DF_Pedido_fecha DEFAULT (GETDATE()),
    tipo          VARCHAR(20)   NOT NULL CONSTRAINT DF_Pedido_tipo DEFAULT ('Local'),
    estado        VARCHAR(20)   NOT NULL CONSTRAINT DF_Pedido_estado DEFAULT ('Pendiente'),
    total         DECIMAL(10,2) NOT NULL CONSTRAINT DF_Pedido_total DEFAULT (0),
    CONSTRAINT PK_Pedido PRIMARY KEY (id_pedido),
    CONSTRAINT FK_Pedido_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT FK_Pedido_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    CONSTRAINT FK_Pedido_Mesa    FOREIGN KEY (id_mesa)    REFERENCES Mesa(id_mesa),
    CONSTRAINT CK_Pedido_tipo   CHECK (tipo   IN ('Local','Para llevar','Domicilio')),
    CONSTRAINT CK_Pedido_estado CHECK (estado IN ('Pendiente','En preparacion','Listo','Entregado','Cancelado')),
    CONSTRAINT CK_Pedido_total  CHECK (total >= 0)
);
GO

-- Tabla: DetallePedido -------------------------------------------------------
CREATE TABLE DetallePedido (
    id_detalle      INT           IDENTITY(1,1) NOT NULL,
    id_pedido       INT           NOT NULL,
    id_producto     INT           NOT NULL,
    cantidad        INT           NOT NULL,
    precio_unitario DECIMAL(8,2)  NOT NULL,
    subtotal        AS (cantidad * precio_unitario) PERSISTED,  -- columna calculada
    CONSTRAINT PK_DetallePedido PRIMARY KEY (id_detalle),
    CONSTRAINT FK_Detalle_Pedido   FOREIGN KEY (id_pedido)   REFERENCES Pedido(id_pedido) ON DELETE CASCADE,
    CONSTRAINT FK_Detalle_Producto FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
    CONSTRAINT CK_Detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_Detalle_precio   CHECK (precio_unitario >= 0)
);
GO

-- Tabla: Pago ----------------------------------------------------------------
CREATE TABLE Pago (
    id_pago      INT           IDENTITY(1,1) NOT NULL,
    id_pedido    INT           NOT NULL,
    metodo_pago  VARCHAR(20)   NOT NULL,
    monto        DECIMAL(10,2) NOT NULL,
    fecha_hora   DATETIME      NOT NULL CONSTRAINT DF_Pago_fecha DEFAULT (GETDATE()),
    CONSTRAINT PK_Pago PRIMARY KEY (id_pago),
    CONSTRAINT UQ_Pago_pedido UNIQUE (id_pedido),  -- un pago por pedido (relacion 1:1)
    CONSTRAINT FK_Pago_Pedido FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    CONSTRAINT CK_Pago_metodo CHECK (metodo_pago IN ('Efectivo','Tarjeta','Transferencia')),
    CONSTRAINT CK_Pago_monto  CHECK (monto >= 0)
);
GO

/* ---------------------------------------------------------------------------
   3. INSERCION DE DATOS DE PRUEBA
--------------------------------------------------------------------------- */

-- Roles
INSERT INTO Rol (nombre, descripcion) VALUES
('Administrador', 'Acceso total al sistema'),
('Empleado',      'Cajero / Barista, registra pedidos y pagos');
GO

-- Usuarios (password_hash es un valor de ejemplo, en produccion se usa BCrypt)
INSERT INTO Usuario (nombre, correo, password_hash, id_rol, activo) VALUES
('Rodrigo Cruz',   'admin@aromacafe.com',    'HASH_ADMIN_123',   1, 1),
('Andrea Morales', 'andrea@aromacafe.com',   'HASH_EMP_456',     2, 1),
('Luis Ramirez',   'luis@aromacafe.com',     'HASH_EMP_789',     2, 1);
GO

-- Clientes
INSERT INTO Cliente (nombre, telefono, correo, direccion) VALUES
('Maria Fernandez', '7845-1122', 'maria.f@gmail.com',  'Col. Escalon, San Salvador'),
('Carlos Mejia',    '7033-8890', 'carlos.m@gmail.com', 'Soyapango, San Salvador'),
('Ana Ruiz',        '7712-4455', 'ana.ruiz@gmail.com', 'Santa Tecla, La Libertad');
GO

-- Categorias
INSERT INTO Categoria (nombre, descripcion) VALUES
('Cafe caliente', 'Bebidas de cafe servidas calientes'),
('Cafe frio',     'Bebidas frias a base de cafe'),
('Reposteria',    'Postres y panaderia'),
('Bebidas',       'Bebidas sin cafe');
GO

-- Productos
INSERT INTO Producto (nombre, descripcion, precio, id_categoria, disponible) VALUES
('Espresso',           'Cafe concentrado 30ml',              1.25, 1, 1),
('Capuchino',          'Espresso con leche vaporizada',      2.50, 1, 1),
('Latte',              'Cafe con leche y espuma',            2.75, 1, 1),
('Frappe de caramelo', 'Bebida frozen de cafe y caramelo',   3.50, 2, 1),
('Cold brew',          'Cafe de extraccion en frio',         3.00, 2, 1),
('Cheesecake',         'Rebanada de pastel de queso',        3.25, 3, 1),
('Muffin de arandano', 'Panecillo con arandanos',            1.75, 3, 1),
('Croissant',          'Croissant de mantequilla',           1.50, 3, 1),
('Jugo de naranja',    'Jugo natural 350ml',                 2.00, 4, 1),
('Agua embotellada',   'Botella de agua 500ml',              0.75, 4, 1);
GO

-- Mesas
INSERT INTO Mesa (numero, capacidad, estado) VALUES
(1, 2, 'Libre'),
(2, 4, 'Libre'),
(3, 4, 'Ocupada'),
(4, 6, 'Libre'),
(5, 2, 'Reservada');
GO

-- Pedidos
INSERT INTO Pedido (id_cliente, id_usuario, id_mesa, tipo, estado) VALUES
(1, 2, 3, 'Local',       'Entregado'),
(2, 2, NULL, 'Para llevar','Listo'),
(NULL, 3, 1, 'Local',     'En preparacion');
GO

-- Detalle de pedidos
-- Pedido 1
INSERT INTO DetallePedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 2, 2, 2.50),
(1, 6, 1, 3.25);
-- Pedido 2
INSERT INTO DetallePedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(2, 4, 1, 3.50),
(2, 8, 2, 1.50);
-- Pedido 3
INSERT INTO DetallePedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(3, 3, 1, 2.75),
(3, 7, 1, 1.75);
GO

-- Recalcular el total de cada pedido a partir de su detalle
UPDATE P
SET P.total = (SELECT SUM(D.subtotal) FROM DetallePedido D WHERE D.id_pedido = P.id_pedido)
FROM Pedido P;
GO

-- Pagos (solo pedidos ya cobrados)
INSERT INTO Pago (id_pedido, metodo_pago, monto) VALUES
(1, 'Tarjeta',  8.25),
(2, 'Efectivo', 6.50);
GO

/* ---------------------------------------------------------------------------
   4. CONSULTAS DE DEMOSTRACION
--------------------------------------------------------------------------- */

-- 4.1 Catalogo de productos con su categoria
SELECT P.id_producto, P.nombre AS producto, C.nombre AS categoria,
       P.precio, CASE WHEN P.disponible = 1 THEN 'Si' ELSE 'No' END AS disponible
FROM Producto P
INNER JOIN Categoria C ON P.id_categoria = C.id_categoria
ORDER BY C.nombre, P.nombre;
GO

-- 4.2 Detalle completo de un pedido (encabezado + lineas)
SELECT  PE.id_pedido, PE.fecha_hora, PE.tipo, PE.estado,
        ISNULL(CL.nombre, 'Consumidor final') AS cliente,
        US.nombre AS atendido_por,
        PR.nombre AS producto, D.cantidad, D.precio_unitario, D.subtotal
FROM Pedido PE
LEFT  JOIN Cliente CL ON PE.id_cliente = CL.id_cliente
INNER JOIN Usuario US ON PE.id_usuario = US.id_usuario
INNER JOIN DetallePedido D ON PE.id_pedido = D.id_pedido
INNER JOIN Producto PR ON D.id_producto = PR.id_producto
WHERE PE.id_pedido = 1;
GO

-- 4.3 Total de ventas por dia
SELECT CAST(fecha_hora AS DATE) AS dia,
       COUNT(*) AS cantidad_pedidos,
       SUM(total) AS venta_total
FROM Pedido
WHERE estado <> 'Cancelado'
GROUP BY CAST(fecha_hora AS DATE)
ORDER BY dia DESC;
GO

-- 4.4 Productos mas vendidos (ranking)
SELECT PR.nombre AS producto,
       SUM(D.cantidad) AS unidades_vendidas,
       SUM(D.subtotal) AS ingresos
FROM DetallePedido D
INNER JOIN Producto PR ON D.id_producto = PR.id_producto
GROUP BY PR.nombre
ORDER BY unidades_vendidas DESC;
GO

-- 4.5 Pedidos pendientes o en preparacion (para la cocina)
SELECT PE.id_pedido, PE.estado, M.numero AS mesa, US.nombre AS empleado
FROM Pedido PE
LEFT JOIN Mesa M ON PE.id_mesa = M.id_mesa
INNER JOIN Usuario US ON PE.id_usuario = US.id_usuario
WHERE PE.estado IN ('Pendiente','En preparacion')
ORDER BY PE.fecha_hora;
GO

/* ---------------------------------------------------------------------------
   5. OPERACIONES CRUD DE EJEMPLO
--------------------------------------------------------------------------- */

-- CREATE: agregar un nuevo producto
INSERT INTO Producto (nombre, descripcion, precio, id_categoria, disponible)
VALUES ('Mocha', 'Espresso con chocolate y leche', 3.00, 1, 1);
GO

-- READ: consultar el producto recien creado
SELECT * FROM Producto WHERE nombre = 'Mocha';
GO

-- UPDATE: cambiar el precio y el estado del pedido
UPDATE Producto SET precio = 3.25 WHERE nombre = 'Mocha';
UPDATE Pedido   SET estado = 'Entregado' WHERE id_pedido = 3;
GO

-- DELETE: eliminar un producto que ya no se ofrece
-- (se marca como no disponible en lugar de borrarlo, buena practica)
UPDATE Producto SET disponible = 0 WHERE nombre = 'Agua embotellada';
-- Borrado fisico de ejemplo:
DELETE FROM Producto WHERE nombre = 'Mocha';
GO

/* ============================================================================
   FIN DEL SCRIPT
============================================================================ */
