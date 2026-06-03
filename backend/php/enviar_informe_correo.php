<?php require __DIR__.'/helpers.php';
require_once __DIR__.'/vendor/autoload.php';
use PHPMailer\PHPMailer\PHPMailer;
$in=input_json();$id=intval($in['id']??0);$correo=trim($in['correo']??'');if($correo==='')responder(false,'Ingrese correo');
$stmt=$pdo->prepare('SELECT * FROM informes WHERE id=?');$stmt->execute([$id]);$inf=$stmt->fetch();if(!$inf)responder(false,'Informe no encontrado');
$file=__DIR__.'/uploads/informes/'.$inf['archivo_pdf'];if(!file_exists($file))responder(false,'PDF no existe');
$mail=new PHPMailer(true);$mail->isSMTP();$mail->Host=$config['smtp_host'];$mail->SMTPAuth=true;$mail->Username=$config['smtp_user'];$mail->Password=$config['smtp_pass'];$mail->SMTPSecure=PHPMailer::ENCRYPTION_STARTTLS;$mail->Port=intval($config['smtp_port']);$mail->CharSet='UTF-8';$mail->setFrom($config['smtp_user'],$config['smtp_from_name']);$mail->addAddress($correo);$mail->Subject='Informe de mantenimiento - SEFAB';$mail->Body='Estimados, adjuntamos el informe técnico de mantenimiento preventivo de aires acondicionados.';$mail->addAttachment($file,$inf['archivo_pdf']);$mail->send();responder(true,'Correo enviado');
