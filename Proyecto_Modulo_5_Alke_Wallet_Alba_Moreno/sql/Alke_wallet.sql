CREATE DATABASE IF NOT EXISTS AlkeWallet;
USE AlkeWallet;
-- Tabla moneda
CREATE TABLE moneda (
    currency_id INT AUTO_INCREMENT PRIMARY KEY,
    currency_name VARCHAR(50) NOT NULL,
    currency_symbol VARCHAR(10) NOT NULL
);

-- Tabla usuario
CREATE TABLE usuario (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    contrasena VARCHAR(100) NOT NULL,
    saldo DECIMAL(12,2) NOT NULL DEFAULT 0,
    currency_id INT NOT NULL,
    FOREIGN KEY (currency_id) REFERENCES moneda(currency_id)
);

-- Tabla transaccion
CREATE TABLE transaccion (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_user_id INT NOT NULL,
    receiver_user_id INT NOT NULL,
    importe DECIMAL(12,2) NOT NULL,
    transaction_date DATETIME NOT NULL,
    FOREIGN KEY (sender_user_id) REFERENCES usuario(user_id),
    FOREIGN KEY (receiver_user_id) REFERENCES usuario(user_id)
);
-- Datos de prueba para moneda
INSERT INTO moneda (currency_name, currency_symbol) VALUES
('Peso Chileno', 'CLP'),
('Dolar Estadounidense', 'USD'),
('Euro', 'EUR');

-- Datos de prueba para usuario
INSERT INTO usuario
(nombre, correo, contrasena, saldo, currency_id) VALUES
('Ana Perez', 'ana@email.com', 'clave123', 350000, 1),
('Luis Soto', 'luis@email.com', 'clave456', 180000, 1),
('Maria Rojas', 'maria@email.com', 'clave789', 950, 2);

-- Datos de prueba para transaccion
INSERT INTO transaccion
(sender_user_id, receiver_user_id, importe, transaction_date) VALUES
(1, 2, 25000, '2026-09-10 10:30:00'),
(2, 1, 15000, '2026-09-11 12:15:00'),
(1, 3, 30000, '2026-09-12 17:45:00');
SELECT * FROM moneda;

SELECT * FROM usuario;

SELECT * FROM transaccion;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE transaccion;
TRUNCATE TABLE usuario;
TRUNCATE TABLE moneda;

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO moneda (currency_name, currency_symbol) VALUES
('Peso Chileno', 'CLP'),
('Dolar Estadounidense', 'USD'),
('Euro', 'EUR');

INSERT INTO usuario
(nombre, correo, contrasena, saldo, currency_id) VALUES
('Ana Perez', 'ana@email.com', 'clave123', 350000, 1),
('Luis Soto', 'luis@email.com', 'clave456', 180000, 1),
('Maria Rojas', 'maria@email.com', 'clave789', 950, 2);

INSERT INTO transaccion
(sender_user_id, receiver_user_id, importe, transaction_date) VALUES
(1, 2, 25000, '2026-09-10 10:30:00'),
(2, 1, 15000, '2026-09-11 12:15:00'),
(1, 3, 30000, '2026-09-12 17:45:00');

-- Consulta 1: moneda elegida por un usuario
SELECT 
    u.nombre,
    m.currency_name,
    m.currency_symbol
FROM usuario u
INNER JOIN moneda m
    ON u.currency_id = m.currency_id
WHERE u.user_id = 1;

-- Consulta 2: obtener todas las transacciones registradas
SELECT * FROM transaccion;

-- Consulta 3: transacciones de un usuario especifico
SELECT *
FROM transaccion
WHERE sender_user_id = 1
   OR receiver_user_id = 1;
   
-- Consulta 4: modificar el correo de un usuario
UPDATE usuario
SET correo = 'ana.perez@email.com'
WHERE user_id = 1;

-- Comprobar que el correo fue modificado
SELECT user_id, nombre, correo
FROM usuario
WHERE user_id = 1;

-- Consulta 5: eliminar una transaccion
DELETE FROM transaccion
WHERE transaction_id = 3;

-- Comprobar que la transaccion fue eliminada
SELECT * FROM transaccion;

-- Consulta adicional: mostrar transacciones con nombre de emisor y receptor
SELECT
    t.transaction_id,
    u1.nombre AS emisor,
    u2.nombre AS receptor,
    t.importe,
    t.transaction_date
FROM transaccion t
INNER JOIN usuario u1
    ON t.sender_user_id = u1.user_id
INNER JOIN usuario u2
    ON t.receiver_user_id = u2.user_id;
    
    -- Consulta adicional: cantidad de transacciones y total enviado por usuario
SELECT
    u.nombre,
    COUNT(t.transaction_id) AS cantidad_transacciones,
    SUM(t.importe) AS total_enviado
FROM usuario u
LEFT JOIN transaccion t
    ON u.user_id = t.sender_user_id
GROUP BY u.user_id, u.nombre;

-- Ejemplo de transaccionalidad

START TRANSACTION;

UPDATE usuario
SET saldo = saldo - 10000
WHERE user_id = 1;

UPDATE usuario
SET saldo = saldo + 10000
WHERE user_id = 2;

INSERT INTO transaccion
(sender_user_id, receiver_user_id, importe, transaction_date)
VALUES (1, 2, 10000, NOW());

-- Ver los cambios antes de deshacerlos
SELECT user_id, nombre, saldo
FROM usuario
WHERE user_id IN (1, 2);

SELECT * FROM transaccion;

ROLLBACK;

-- Comprobar que ROLLBACK deshizo los cambios
SELECT user_id, nombre, saldo
FROM usuario
WHERE user_id IN (1, 2);

SELECT * FROM transaccion;
   
   -- Ejemplo de transacción confirmada con COMMIT

START TRANSACTION;

UPDATE usuario
SET saldo = saldo - 5000
WHERE user_id = 1;

UPDATE usuario
SET saldo = saldo + 5000
WHERE user_id = 2;

INSERT INTO transaccion
(sender_user_id, receiver_user_id, importe, transaction_date)
VALUES (1, 2, 5000, NOW());

COMMIT;

-- Comprobar que los cambios fueron confirmados
SELECT user_id, nombre, saldo
FROM usuario
WHERE user_id IN (1, 2);

SELECT * FROM transaccion;

-- Comprobar las tablas creadas
SHOW TABLES;

-- Revisar estructura de cada tabla
DESCRIBE moneda;

DESCRIBE usuario;

DESCRIBE transaccion;

-- Prueba de integridad referencial

START TRANSACTION;

INSERT INTO transaccion
(sender_user_id, receiver_user_id, importe, transaction_date)
VALUES (999, 1, 10000, NOW());

ROLLBACK;

-- Comprobar que no se agregó la transacción inválida
SELECT * FROM transaccion;

USE AlkeWallet;

-- Crear un índice compuesto para las transacciones
CREATE INDEX idx_emisor_receptor
ON transaccion (sender_user_id, receiver_user_id);

-- Comprobar que el índice fue creado
SHOW INDEX FROM transaccion;
