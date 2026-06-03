<?php require __DIR__.'/helpers.php'; $in=input_json(); $uid=intval($in['usuario_id']);$mid=intval($in['modulo_id']);$asig=intval($in['asignado']);
$stmt=$pdo->prepare('SELECT id FROM usuario_modulo WHERE usuario_id=? AND modulo_id=?');$stmt->execute([$uid,$mid]);$id=$stmt->fetchColumn();
if($id){$pdo->prepare('UPDATE usuario_modulo SET estado=? WHERE id=?')->execute([$asig,$id]);} else {$pdo->prepare('INSERT INTO usuario_modulo(usuario_id,modulo_id,estado) VALUES(?,?,?)')->execute([$uid,$mid,$asig]);} responder(true,'Módulo actualizado');
