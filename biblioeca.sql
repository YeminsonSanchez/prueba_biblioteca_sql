-- Requerimientos Parte 1 - Creación del modelo conceptual, lógico y físico:
-- 1. Realizar el modelo conceptual, considerando las entidades y relaciones entre ellas.
-- 2. Realizar el modelo lógico, considerando todas las entidades y las relaciones entre ellas, los atributos, normalización y creación de tablas intermedias de ser necesario.
-- 3. Realizar el modelo físico, considerando la especificación de tablas y columnas, además de las claves externas.
-- Parte 2 - Creando el modelo en la base de datos:
-- 1. Crear el modelo en una base de datos llamada biblioteca, considerando las tablas definidas y sus atributos.
CREATE DATABASE biblioteca;

\c biblioteca;

CREATE TABLE socio (
    rut VARCHAR(12) PRIMARY KEY,
    nombre VARCHAR(30),
    apellido VARCHAR(30),
    direccion VARCHAR(255),
    telefono VARCHAR(15)
);

CREATE TABLE libro (
    isbn VARCHAR(15) PRIMARY KEY,
    titulo VARCHAR(255),
    numero_pagina NUMERIC
);

CREATE TABLE autor (
    codigo SERIAL PRIMARY KEY,
    nombre VARCHAR(30),
    apellido VARCHAR(30),
    anio_nacimiento INT,
    anio_defuncion INT
);

CREATE TABLE prestamo (
    id SERIAL,
    rut_socio VARCHAR(12),
    isbn_libro VARCHAR(15),
    fecha_prestamo DATE,
    fecha_devolucion DATE,
    PRIMARY KEY (rut_socio, isbn_libro),
    FOREIGN KEY (rut_socio) REFERENCES socio(rut),
    FOREIGN KEY (isbn_libro) REFERENCES libro(isbn)
);

CREATE TABLE tipo_autor (
    cod_autor INT,
    isbn_libro VARCHAR(15),
    tipo_autor VARCHAR(10),
    PRIMARY KEY (cod_autor, isbn_libro),
    FOREIGN KEY (cod_autor) REFERENCES autor(codigo),
    FOREIGN KEY (isbn_libro) REFERENCES libro(isbn)
);

-- 2. Se deben insertar los registros en las tablas correspondientes
INSERT INTO
    socio (rut, nombre, apellido, direccion, telefono)
VALUES
    (
        '1111111-1',
        'JUAN',
        'SOTO',
        'AVENIDA 1, SANTIAGO',
        '911111111'
    ),
    (
        '2222222-2',
        'ANA',
        'PEREZ',
        'PASAJE 2, SANTIAGO',
        '922222222'
    ),
    (
        '3333333-3',
        'SANDRA',
        'AGUILAR',
        'AVENIDA 2, SANTIAGO',
        '933333333'
    ),
    (
        '4444444-4',
        'ESTEBAN',
        'JEREZ',
        'AVENIDA 3, SANTIAGO',
        '944444444'
    ),
    (
        '5555555-5',
        'SILVANA',
        'MUÑOZ',
        'PASAJE 3, SANTIAGO',
        '955555555'
    );

INSERT INTO
    libro (isbn, titulo, numero_pagina)
VALUES
    ('111-1111111-111', 'CUENTOS DE TERROR', 344),
    ('222-2222222-222', 'POESIAS CONTEMPORANEAS', 167),
    ('333-3333333-333', 'HISTORIA DE ASIA', 511),
    ('444-4444444-444', 'MANUAL DE MECANICA', 298);

INSERT INTO
    autor (
        nombre,
        apellido,
        anio_nacimiento,
        anio_defuncion
    )
VALUES
    ('JOSE', 'SALGADO', 1968, 2020),
    ('ANA', 'SALGADO', 1972, NULL),
    ('ANDRES', 'ULLOA', 1982, NULL),
    ('SERGIO', 'MARDONES', 1950, 2012),
    ('MARTIN', 'PORTA', 1976, NULL);

INSERT INTO
    tipo_autor (cod_autor, isbn_libro, tipo_autor)
VALUES
    (1, '111-1111111-111', 'PRINCIPAL'),
    (2, '111-1111111-111', 'COAUTOR'),
    (3, '222-2222222-222', 'PRINCIPAL'),
    (4, '333-3333333-333', 'PRINCIPAL'),
    (5, '444-4444444-444', 'PRINCIPAL');

INSERT INTO
    prestamo (
        rut_socio,
        isbn_libro,
        fecha_prestamo,
        fecha_devolucion
    )
VALUES
    (
        '1111111-1',
        '111-1111111-111',
        '2020-01-20',
        '2020-01-27'
    ),
    (
        '5555555-5',
        '222-2222222-222',
        '2020-01-20',
        '2020-01-30'
    ),
    (
        '3333333-3',
        '333-3333333-333',
        '2020-01-22',
        '2020-01-30'
    ),
    (
        '4444444-4',
        '444-4444444-444',
        '2020-01-23',
        '2020-01-30'
    ),
    (
        '2222222-2',
        '111-1111111-111',
        '2020-01-27',
        '2020-02-04'
    ),
    (
        '1111111-1',
        '444-4444444-444',
        '2020-01-31',
        '2020-02-12'
    ),
    (
        '3333333-3',
        '222-2222222-222',
        '2020-01-31',
        '2020-02-12'
    );

-- 3. Realizar las siguientes consultas:
-- a. Mostrar todos los libros que posean menos de 300 páginas.
SELECT
    *
FROM
    libro
WHERE
    numero_pagina < 300;

-- b. Mostrar todos los autores que hayan nacido después del 01-01-1970.
SELECT
    *
FROM
    autor
WHERE
    anio_nacimiento > 1970;

-- c. ¿Cuál es el libro más solicitado? (El libro que más veces se solicitó) ya que hubieron 3 libros que tienen la misma cantidas
-- de solicitudes escogi solo 1 de los 3 con el LIMIT 1 pero tambien se puede usar LIMIT 3 para que muestre todos los resultados.
SELECT
    COUNT(p.isbn_libro) veces_prestado,
    l.titulo
FROM
    prestamo p
    INNER JOIN libro l ON p.isbn_libro = l.isbn
GROUP BY
    l.titulo
ORDER BY
    MAX(p.isbn_libro) DESC
LIMIT
    1;

-- otro metodo es usando el COUNT(p.isbn_libro) DESC LIMIT (1-3)
-- d. Si se cobrara una multa de $100 por cada día de atraso, 
--mostrar cuánto debería pagar cada usuario que entregue el préstamo después de 7 días.
SELECT
    l.titulo,
    s.rut,
    s.nombre,
    s.apellido,
    ((p.fecha_devolucion - p.fecha_prestamo) - 7) dias_de_atraso,
    (
        ((p.fecha_devolucion - p.fecha_prestamo) - 7) * 100
    ) multa
FROM
    prestamo p
    INNER JOIN socio s ON p.rut_socio = s.rut
    INNER JOIN libro l ON p.isbn_libro = l.isbn
WHERE
    (p.fecha_devolucion - p.fecha_prestamo) > 7
ORDER BY
    rut;

----------------------------------- OTRAS CONSULTAS A CRITERIO DEL ESTUDIANTE -----------------------------------
-- mostrar todos los libros con sus autores y coautores.
SELECT
    l.titulo,
    a.nombre nombre_autor,
    a.apellido apellido_autor,
    a.anio_nacimiento,
    a.anio_defuncion,
    a.codigo,
    t.tipo_autor
From
    tipo_autor t,
    autor a,
    libro l
WHERE
    t.cod_autor = a.codigo
    AND t.isbn_libro = l.isbn;

-- mostrar todos los libros prestados al socio Juan soto.
SELECT
    *
FROM
    prestamo
WHERE
    rut_socio = '1111111-1';

-- mostar todas las tablas de la base de datos biblioteca.
SELECT
    *
FROM
    socio;

SELECT
    *
FROM
    libro;

SELECT
    *
FROM
    prestamo;

SELECT
    *
FROM
    tipo_autor;

SELECT
    *
FROM
    autor;