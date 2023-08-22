<?php

error_reporting(E_ALL | E_STRICT);
$_SERVER['HTTP_CONNECTION'] = 'close';

$socket = socket_create(AF_INET, SOCK_DGRAM, SOL_UDP);
socket_bind($socket, '127.0.0.1', 40001);

$from = '';
$port = 0;
socket_recvfrom($socket, $buf, 100, 0, $from, $port);
socket_close($socket);
echo $buf . PHP_EOL;
?>