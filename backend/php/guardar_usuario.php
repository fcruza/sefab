<?php require __DIR__.'/helpers.php'; $in=input_json();
$id=intval($in['id']??0); $rol=$pdo->prepare('SELECT id FROM roles WHERE nombre=? LIMIT 1'); $rol->execute([$in['rol']??'Técnico']); $rol_id=intval($rol->fetchColumn()?:3);
if($id>0){$sql='UPDATE usuarios SET usuario=?, nombres=?, apellidos=?, rol_id=?, estado=? WHERE id=?';$pdo->prepare($sql)->execute([$in['usuario'],$in['nombres'],$in['apellidos'],$rol_id,intval($in['estado']??1),$id]);}
else{$sql='INSERT INTO usuarios(usuario,password,nombres,apellidos,rol_id,estado) VALUES(?,?,?,?,?,?)';$pdo->prepare($sql)->execute([$in['usuario'],md5($in['password']??'123456'),$in['nombres'],$in['apellidos'],$rol_id,intval($in['estado']??1)]);} responder(true,'Usuario guardado');
