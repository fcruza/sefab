<?php require __DIR__.'/helpers.php';
$in=input_json(); $u=trim($in['usuario']??''); $p=trim($in['password']??'');
$stmt=$pdo->prepare('SELECT u.*, r.nombre rol FROM usuarios u LEFT JOIN roles r ON r.id=u.rol_id WHERE u.usuario=? AND u.estado=1 LIMIT 1'); $stmt->execute([$u]); $row=$stmt->fetch();
if(!$row || md5($p)!==$row['password']) responder(false,'Usuario o contraseña incorrectos');
$mods=$pdo->prepare('SELECT m.ruta FROM usuario_modulo um INNER JOIN modulos m ON m.id=um.modulo_id WHERE um.usuario_id=? AND um.estado=1'); $mods->execute([$row['id']]);
$token=bin2hex(random_bytes(32)); $pdo->prepare('UPDATE usuarios SET token=? WHERE id=?')->execute([$token,$row['id']]);
responder(true,'Login correcto',['token'=>$token,'user'=>['id'=>$row['id'],'usuario'=>$row['usuario'],'nombres'=>$row['nombres'],'apellidos'=>$row['apellidos'],'rol'=>$row['rol'],'estado'=>$row['estado'],'modulos'=>$mods->fetchAll(PDO::FETCH_COLUMN)]]);
