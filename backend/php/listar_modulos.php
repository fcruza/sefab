<?php require __DIR__.'/helpers.php';
$res=$pdo->query('SELECT id,nombre,ruta,icono FROM modulos WHERE estado=1 ORDER BY orden,nombre')->fetchAll(); responder(true,'OK',['modulos'=>$res]);
