# MK-Auth — Relatório DICI / ANATEL

Distribuição independente do addon de geração dos relatórios DICI Mensal e PPP Trimestral para MK-Auth.

## Instalação ou atualização

Execute como `root` no servidor MK-Auth:

```sh
curl -fsSL https://raw.githubusercontent.com/brsxdlols/mkauth-dici/main/install.sh | sh
```

O instalador baixa sempre a versão atual da branch `main`, valida o PHP, cria backup e atualiza o menu sem duplicação.

## Compatibilidade com o painel MK-Auth

- Carrega as configurações básicas oficiais antes de montar o cabeçalho, corrigindo a tela em branco após o login.
- Mantém a autenticação obrigatória e o suporte a sessões antigas e atuais.
- O instalador registra o atalho **DICI / ANATEL** na aba **Provedor**.
- Correção validada com PHP 7.3 e 8.0; abertura autenticada confirmada no servidor.

## Correção 10.51.1

- Mantém a consulta e os filtros originais do relatório DICI.
- Gera novos CSVs com UTF-8 BOM (`EF BB BF`), separador `;` e CRLF, sem precisar salvar novamente pelo Bloco de Notas.
- Não altera clientes, códigos IBGE ou banco de dados.
- Reutiliza a conexão oficial `/opt/mk-auth/include/conexao.php`; nenhuma senha é distribuída.

## Destinos e backup

- Addon: `/opt/mk-auth/admin/addons/dici`
- Arquivos gerados: `/opt/mk-auth/admin/arquivos`
- Backups: `/opt/mk-auth/backups/dici/AAAAmmdd-HHMMSS`

## Rollback

```sh
curl -fsSL https://raw.githubusercontent.com/brsxdlols/mkauth-dici/main/install.sh -o /tmp/install-mkauth-dici.sh
sh /tmp/install-mkauth-dici.sh --rollback latest
```

Após instalar, autentique-se no MK-Auth, abra **Provedor → DICI / ANATEL** e gere um arquivo de teste. Novos arquivos devem começar com os bytes `EF BB BF`.
