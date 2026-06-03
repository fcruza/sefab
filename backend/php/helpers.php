<?php
header('Content-Type: application/json; charset=utf-8');
$config = require __DIR__ . '/db.php';
try {
  $pdo = new PDO("mysql:host={$config['host']};dbname={$config['db']};charset={$config['charset']}", $config['user'], $config['pass'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
} catch (Throwable $e) { responder(false, 'Error DB: '.$e->getMessage(), [], 500); }
function responder($ok, $msg='', $extra=[], $code=200){ http_response_code($code); echo json_encode(array_merge(['ok'=>$ok,'msg'=>$msg],$extra), JSON_UNESCAPED_UNICODE); exit; }
function validar_api_key($config){ $h=getallheaders(); $key=$h['X-API-KEY'] ?? $h['x-api-key'] ?? ''; if($key !== $config['api_key']) responder(false,'API KEY inválida',[],401); }
function input_json(){ $raw=file_get_contents('php://input'); $data=json_decode($raw,true); return is_array($data)?$data:$_POST; }
validar_api_key($config);
