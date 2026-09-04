@echo -off
echo ============================================================
echo  BC-250 FLASH SEGURO v2 - compativel com EFI Shell 1.x
echo ============================================================
echo ============================================================
echo  Verificando arquivos no device atual:
echo ============================================================
ls
echo ============================================================
echo  PRECISA aparecer Robin5.00 e AfuEfix64.efi na lista acima.
echo  Se NAO aparecerem: digite fs0: (ou fs1:) e rode de novo.
echo ============================================================
echo  O flash comeca em 20 segundos. Pressione CTRL+C para CANCELAR.
echo ============================================================
stall 20000000
echo --> Executando: AfuEfix64.efi Robin5.00 /p /b /n /k /x /rlc:e
AfuEfix64.efi Robin5.00 /p /b /n /k /x /rlc:e
echo ============================================================
echo  RESULTADO ACIMA.
echo  Se apareceu ERRO: anote/fotografe e NAO reinicie. Me envie.
echo  Se apareceu barra de progresso e successful: flash OK.
echo ============================================================
echo  Reiniciando em 30 segundos (CTRL+C para cancelar e ler de novo).
echo ============================================================
stall 30000000
reset
