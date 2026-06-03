<?php require __DIR__.'/helpers.php';$in=input_json();$pdo->prepare('UPDATE aires SET estado=0 WHERE id=?')->execute([intval($in['id'])]);responder(true,'Aire inactivado');
