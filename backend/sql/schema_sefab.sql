CREATE DATABASE IF NOT EXISTS sefab_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sefab_app;

CREATE TABLE roles(id INT AUTO_INCREMENT PRIMARY KEY,nombre VARCHAR(80) NOT NULL,estado TINYINT DEFAULT 1);
CREATE TABLE usuarios(id INT AUTO_INCREMENT PRIMARY KEY,usuario VARCHAR(80) UNIQUE NOT NULL,password VARCHAR(80) NOT NULL,nombres VARCHAR(120) NOT NULL,apellidos VARCHAR(120) NOT NULL,rol_id INT NULL,token VARCHAR(150) NULL,estado TINYINT DEFAULT 1,fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE modulos(id INT AUTO_INCREMENT PRIMARY KEY,nombre VARCHAR(100),ruta VARCHAR(80),icono VARCHAR(80),orden INT DEFAULT 1,estado TINYINT DEFAULT 1);
CREATE TABLE usuario_modulo(id INT AUTO_INCREMENT PRIMARY KEY,usuario_id INT,modulo_id INT,estado TINYINT DEFAULT 1,UNIQUE KEY uk_um(usuario_id,modulo_id));
CREATE TABLE app_version_control(id INT AUTO_INCREMENT PRIMARY KEY,plataforma VARCHAR(20) DEFAULT 'android',version_actual VARCHAR(20),version_minima VARCHAR(20),obligatorio TINYINT DEFAULT 1,mensaje TEXT,url_actualizacion TEXT,estado TINYINT DEFAULT 1);

CREATE TABLE aires(id INT AUTO_INCREMENT PRIMARY KEY,codigo VARCHAR(80),area VARCHAR(150),ubicacion VARCHAR(180),marca VARCHAR(100),modelo VARCHAR(100),serie VARCHAR(120),capacidad_btu VARCHAR(80),tipo VARCHAR(80),fecha_compra DATE NULL,fecha_instalacion DATE NULL,estado_operativo VARCHAR(80),foto VARCHAR(255),estado TINYINT DEFAULT 1,fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE mantenimientos(id INT AUTO_INCREMENT PRIMARY KEY,cliente VARCHAR(160),area VARCHAR(160),fecha_programada DATE,observacion TEXT,estado_mantenimiento VARCHAR(50) DEFAULT 'Programado',estado TINYINT DEFAULT 1,fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE mantenimiento_actividades(id INT AUTO_INCREMENT PRIMARY KEY,mantenimiento_id INT,actividad VARCHAR(255),realizado TINYINT DEFAULT 1,observacion TEXT);
CREATE TABLE informes(id INT AUTO_INCREMENT PRIMARY KEY,numero_informe VARCHAR(80),cliente_nombre VARCHAR(160),cliente_documento VARCHAR(30),asunto VARCHAR(250),fecha_informe DATE,correo_destino VARCHAR(180),archivo_pdf VARCHAR(255),estado TINYINT DEFAULT 1,fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP);

INSERT INTO roles(nombre) VALUES ('Administrador'),('Supervisor'),('Técnico');
INSERT INTO usuarios(usuario,password,nombres,apellidos,rol_id,estado) VALUES ('admin',MD5('123456'),'Felix','Cruz',1,1);
INSERT INTO modulos(nombre,ruta,icono,orden) VALUES ('Usuarios','usuarios','people',1),('Inventario AA','aires','ac_unit',2),('Cronograma','mantenimientos','calendar_month',3),('Informes PDF','informes','picture_as_pdf',4);
INSERT INTO usuario_modulo(usuario_id,modulo_id,estado) SELECT 1,id,1 FROM modulos;
INSERT INTO app_version_control(plataforma,version_actual,version_minima,obligatorio,mensaje,url_actualizacion,estado) VALUES ('android','1.0.0','1.0.0',1,'Debe actualizar la aplicación para continuar.','',1),('ios','1.0.0','1.0.0',1,'Debe actualizar la aplicación para continuar.','',1);
INSERT INTO aires(codigo,area,ubicacion,marca,modelo,serie,capacidad_btu,tipo,fecha_compra,fecha_instalacion,estado_operativo,estado) VALUES ('AA-001','TI','Oficina TI','LG','Dual Inverter','SN001','24000 BTU','Split','2026-01-10','2026-01-15','Operativo',1);
