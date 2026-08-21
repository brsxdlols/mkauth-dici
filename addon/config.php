<?php
/** Usa a sessão e a conexão oficiais do MK-Auth; nenhuma credencial é distribuída. */
require_once __DIR__ . '/mkauth_session.php';
$connectionFile = '/opt/mk-auth/include/conexao.php';
if (!is_readable($connectionFile)) {
    http_response_code(500);
    exit('Conexão do MK-Auth não encontrada.');
}
require_once $connectionFile;
if (!isset($LOADMYSQL) || !($LOADMYSQL instanceof mysqli)) {
    http_response_code(500);
    exit('Conexão mysqli do MK-Auth indisponível.');
}
$conexao = $LOADMYSQL;
