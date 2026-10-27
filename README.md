# Blox Fruits-inspired Automation — PvE only

Projeto-base para **um jogo próprio no Roblox Studio** ou ambiente de testes autorizado. Não é um executor nem um exploit para Blox Fruits público.

## Importação no Roblox Studio

1. Extraia o ZIP.
2. No Roblox Studio, crie as pastas/objetos conforme `PROJECT_STRUCTURE.md`.
3. Copie cada arquivo `.lua` para o local indicado.
4. Ative `Enable Studio Access to API Services` apenas em um ambiente de teste se quiser testar DataStore.
5. Implemente as funções de `ReplicatedStorage/Shared/GameAPI.lua` com as mecânicas do seu próprio jogo.
6. Teste em servidor privado de desenvolvimento antes de publicar.

## Estado real dos módulos

- GUI, configuração, persistência, navegação por PathfindingService e esqueleto de combate PvE estão incluídos.
- Auto farm, coleta, raids, chefes e maestria dependem da implementação legítima de `GameAPI.lua`.
- O servidor deve validar todas as ações. Nunca confie em dano, XP, loot ou inventário enviado pelo cliente.
- Este projeto não inclui PvP, teleporte por falhas, injeção remota, leitura de memória ou executor externo.

## Importante

Este ZIP é um **projeto-base de Roblox Studio**, não um script pronto para ser executado por executor em Blox Fruits. Algumas funções ficam inativas até você implementar a API do seu jogo.
