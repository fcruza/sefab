<?php require __DIR__.'/helpers.php';
$base=$config['base_url'];$rows=$pdo->query('SELECT * FROM aires WHERE estado IN (0,1) ORDER BY id DESC')->fetchAll();
foreach($rows as &$r){$r['foto_url']=$r['foto']?$base.'uploads/aires/'.$r['foto']:'';} responder(true,'OK',['aires'=>$rows]);
