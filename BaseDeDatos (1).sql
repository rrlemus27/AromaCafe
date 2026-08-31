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

-- Tabla: Auditoria -----------------------------------------------------------
-- Registra automaticamente (via triggers) los cambios realizados sobre las
-- tablas sensibles del sistema: quien, que operacion, en que tabla y cuando.
CREATE TABLE Auditoria (
    id_auditoria  INT           IDENTITY(1,1) NOT NULL,
    tabla_afectada VARCHAR(50)  NOT NULL,
    operacion     VARCHAR(10)   NOT NULL,   -- INSERT / UPDATE / DELETE
    id_registro   INT           NULL,        -- clave del registro afectado
    detalle       VARCHAR(255)  NULL,        -- descripcion del cambio
    usuario_bd    VARCHAR(100)  NOT NULL CONSTRAINT DF_Aud_user DEFAULT (SUSER_SNAME()),
    fecha_hora    DATETIME      NOT NULL CONSTRAINT DF_Aud_fecha DEFAULT (GETDATE()),
    CONSTRAINT PK_Auditoria PRIMARY KEY (id_auditoria),
    CONSTRAINT CK_Aud_operacion CHECK (operacion IN ('INSERT','UPDATE','DELETE'))
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
   4. VISTAS
   Consultas guardadas que simplifican el acceso a la informacion mas usada
   por las aplicaciones web y movil.
--------------------------------------------------------------------------- */

-- 4.1 Vista: catalogo de productos con su categoria
CREATE VIEW vw_CatalogoProductos AS
SELECT  P.id_producto,
        P.nombre        AS producto,
        C.nombre        AS categoria,
        P.precio,
        P.disponible
FROM Producto P
INNER JOIN Categoria C ON P.id_categoria = C.id_categoria;
GO

-- 4.2 Vista: detalle completo de pedidos (encabezado + lineas)
CREATE VIEW vw_DetallePedidos AS
SELECT  PE.id_pedido,
        PE.fecha_hora,
        PE.tipo,
        PE.estado,
        ISNULL(CL.nombre, 'Consumidor final') AS cliente,
        US.nombre       AS atendido_por,
        PR.nombre       AS producto,
        D.cantidad,
        D.precio_unitario,
        D.subtotal
FROM Pedido PE
LEFT  JOIN Cliente CL ON PE.id_cliente = CL.id_cliente
INNER JOIN Usuario US ON PE.id_usuario = US.id_usuario
INNER JOIN DetallePedido D ON PE.id_pedido = D.id_pedido
INNER JOIN Producto PR ON D.id_producto = PR.id_producto;
GO

-- 4.3 Vista: total de ventas por dia
CREATE VIEW vw_VentasPorDia AS
SELECT  CAST(fecha_hora AS DATE) AS dia,
        COUNT(*)   AS cantidad_pedidos,
        SUM(total) AS venta_total
FROM Pedido
WHERE estado <> 'Cancelado'
GROUP BY CAST(fecha_hora AS DATE);
GO

-- 4.4 Vista: productos mas vendidos (ranking)
CREATE VIEW vw_ProductosMasVendidos AS
SELECT  PR.nombre AS producto,
        SUM(D.cantidad) AS unidades_vendidas,
        SUM(D.subtotal) AS ingresos
FROM DetallePedido D
INNER JOIN Producto PR ON D.id_producto = PR.id_producto
GROUP BY PR.nombre;
GO

/* ---------------------------------------------------------------------------
   5. TRIGGERS (DISPARADORES)
   - Los triggers de auditoria registran automaticamente los cambios en las
     tablas sensibles (Producto, Pedido, Pago).
   - El trigger de DetallePedido recalcula el total del pedido cuando se
     agregan, modifican o eliminan lineas.
--------------------------------------------------------------------------- */

-- 5.1 Auditoria de Producto (INSERT / UPDATE / DELETE)
CREATE TRIGGER tr_Auditoria_Producto
ON Producto
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- INSERT: hay filas en inserted y no en deleted
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO Auditoria (tabla_afectada, operacion, id_registro, detalle)
        SELECT 'Producto', 'INSERT', i.id_producto,
               'Alta de producto: ' + i.nombre
        FROM inserted i;

    -- DELETE: hay filas en deleted y no en inserted
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
        INSERT INTO Auditoria (tabla_afectada, operacion, id_registro, detalle)
        SELECT 'Producto', 'DELETE', d.id_producto,
               'Baja de producto: ' + d.nombre
        FROM deleted d;

    -- UPDATE: hay filas en ambas
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO Auditoria (tabla_afectada, operacion, id_registro, detalle)
        SELECT 'Producto', 'UPDATE', i.id_producto,
               'Cambio en producto: ' + i.nombre +
               ' (precio anterior ' + CAST(d.precio AS VARCHAR(10)) +
               ' -> nuevo ' + CAST(i.precio AS VARCHAR(10)) + ')'
        FROM inserted i
        INNER JOIN deleted d ON i.id_producto = d.id_producto;
END;
GO

-- 5.2 Auditoria de Pedido (registra cambios de estado)
CREATE TRIGGER tr_Auditoria_Pedido
ON Pedido
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO Auditoria (tabla_afectada, operacion, id_registro, detalle)
        SELECT 'Pedido', 'INSERT', i.id_pedido,
               'Nuevo pedido en estado: ' + i.estado
        FROM inserted i;

    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
        INSERT INTO Auditoria (tabla_afectada, operacion, id_registro, detalle)
        SELECT 'Pedido', 'DELETE', d.id_pedido,
               'Pedido eliminado'
        FROM deleted d;

    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO Auditoria (tabla_afectada, operacion, id_registro, detalle)
        SELECT 'Pedido', 'UPDATE', i.id_pedido,
               'Estado: ' + d.estado + ' -> ' + i.estado
        FROM inserted i
        INNER JOIN deleted d ON i.id_pedido = d.id_pedido
        WHERE i.estado <> d.estado;
END;
GO

-- 5.3 Auditoria de Pago
CREATE TRIGGER tr_Auditoria_Pago
ON Pago
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted)
        INSERT INTO Auditoria (tabla_afectada, operacion, id_registro, detalle)
        SELECT 'Pago', 'INSERT', i.id_pago,
               'Pago de ' + CAST(i.monto AS VARCHAR(12)) + ' (' + i.metodo_pago + ')'
        FROM inserted i;

    IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO Auditoria (tabla_afectada, operacion, id_registro, detalle)
        SELECT 'Pago', 'DELETE', d.id_pago, 'Pago anulado'
        FROM deleted d;
END;
GO

-- 5.4 Recalculo automatico del total del pedido al cambiar su detalle
CREATE TRIGGER tr_RecalcularTotalPedido
ON DetallePedido
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Reunir los id_pedido afectados (tanto de inserted como de deleted)
    DECLARE @pedidos TABLE (id_pedido INT);
    INSERT INTO @pedidos (id_pedido)
        SELECT id_pedido FROM inserted
        UNION
        SELECT id_pedido FROM deleted;

    UPDATE P
    SET P.total = ISNULL((SELECT SUM(D.subtotal)
                          FROM DetallePedido D
                          WHERE D.id_pedido = P.id_pedido), 0)
    FROM Pedido P
    INNER JOIN @pedidos A ON P.id_pedido = A.id_pedido;
END;
GO

/* ---------------------------------------------------------------------------
   6. CONSULTAS DE DEMOSTRACION (usando las vistas)
--------------------------------------------------------------------------- */

-- 6.1 Catalogo de productos disponibles
SELECT * FROM vw_CatalogoProductos
WHERE disponible = 1
ORDER BY categoria, producto;
GO

-- 6.2 Detalle completo de un pedido
SELECT * FROM vw_DetallePedidos WHERE id_pedido = 1;
GO

-- 6.3 Ventas por dia
SELECT * FROM vw_VentasPorDia ORDER BY dia DESC;
GO

-- 6.4 Ranking de productos mas vendidos
SELECT * FROM vw_ProductosMasVendidos ORDER BY unidades_vendidas DESC;
GO

-- 6.5 Pedidos pendientes o en preparacion (para la cocina)
SELECT PE.id_pedido, PE.estado, M.numero AS mesa, US.nombre AS empleado
FROM Pedido PE
LEFT JOIN Mesa M ON PE.id_mesa = M.id_mesa
INNER JOIN Usuario US ON PE.id_usuario = US.id_usuario
WHERE PE.estado IN ('Pendiente','En preparacion')
ORDER BY PE.fecha_hora;
GO

/* ---------------------------------------------------------------------------
   7. OPERACIONES CRUD DE EJEMPLO
   (cada operacion dispara automaticamente los triggers de auditoria)
--------------------------------------------------------------------------- */

-- CREATE: agregar un nuevo producto  -> genera registro de auditoria
INSERT INTO Producto (nombre, descripcion, precio, id_categoria, disponible)
VALUES ('Mocha', 'Espresso con chocolate y leche', 3.00, 1, 1);
GO

-- READ: consultar el producto recien creado
SELECT * FROM Producto WHERE nombre = 'Mocha';
GO

-- UPDATE: cambiar precio del producto y estado del pedido -> auditoria
UPDATE Producto SET precio = 3.25 WHERE nombre = 'Mocha';
UPDATE Pedido   SET estado = 'Entregado' WHERE id_pedido = 3;
GO

-- DELETE: eliminar un producto -> auditoria
DELETE FROM Producto WHERE nombre = 'Mocha';
GO

-- Verificar el registro de auditoria generado por las operaciones anteriores
SELECT id_auditoria, tabla_afectada, operacion, id_registro, detalle, fecha_hora
FROM Auditoria
ORDER BY id_auditoria;
GO

/* ============================================================================
   FIN DEL SCRIPT
============================================================================ */
