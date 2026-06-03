<?php require __DIR__.'/helpers.php';
$in=input_json(); $version=trim($in['version_app']??''); $plataforma=trim($in['plataforma']??'android');
$stmt=$pdo->prepare('SELECT * FROM app_version_control WHERE plataforma=? AND estado=1 ORDER BY id DESC LIMIT 1'); $stmt->execute([$plataforma]); $row=$stmt->fetch();
if(!$row) responder(true,'Sin control de versión',['requiere_actualizacion'=>false]);
$ok=version_compare($version,$row['version_minima'],'>=');
responder($ok || intval($row['obligatorio'])===0, $ok?'Versión permitida':($row['mensaje']?:'Debe actualizar la app'), ['requiere_actualizacion'=>!$ok,'obligatorio'=>intval($row['obligatorio'])===1,'version_app'=>$version,'version_minima'=>$row['version_minima'],'version_actual'=>$row['version_actual'],'url_actualizacion'=>$row['url_actualizacion']]);
