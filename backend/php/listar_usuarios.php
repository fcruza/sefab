<?php require __DIR__.'/helpers.php';
$rows=$pdo->query('SELECT u.id,u.usuario,u.nombres,u.apellidos,u.estado,r.nombre rol FROM usuarios u LEFT JOIN roles r ON r.id=u.rol_id ORDER BY u.id DESC')->fetchAll();
foreach($rows as &$r){$s=$pdo->prepare('SELECT m.ruta FROM usuario_modulo um INNER JOIN modulos m ON m.id=um.modulo_id WHERE um.usuario_id=? AND um.estado=1');$s->execute([$r['id']]);$r['modulos']=$s->fetchAll(PDO::FETCH_COLUMN);} responder(true,'OK',['usuarios'=>$rows]);
