# Rage Simulator

Rage Simulator e um jogo 2D de plataforma feito em Godot, com foco em mobile. O projeto nasceu no Godot 4.3 e esta sendo migrado para Godot 4.6.

## Conceito

O jogador controla um especime/minion dentro de uma simulacao cheia de armadilhas, plataformas, portas, chaves, checkpoints e coletaveis. A proposta e criar fases curtas, precisas e desafiadoras, onde morrer faz parte do aprendizado e o jogador pode repetir fases para melhorar seu desempenho.

O loop principal e:

1. Escolher ou continuar uma fase.
2. Completar o trajeto evitando armadilhas.
3. Coletar engrenagens e chaves.
4. Usar checkpoints para manter progresso dentro da fase.
5. Finalizar a simulacao e avaliar tempo, mortes e coletaveis.
6. Liberar novas fases e tentar cumprir objetivos extras.

## Estado atual

- Engine: Godot 4.6.
- Cena inicial: `res://Scenes/Home.tscn`.
- Plataformas previstas: Windows, Android e Web.
- Foco principal: Android/mobile.
- Idiomas configurados: ingles, portugues do Brasil, espanhol e alemao.
- Integracoes presentes: AdMob e Google Play Services.

## Estrutura principal

- `Assets/`: artes, sprites, audio, tilesets, fontes e UI.
- `Scenes/`: telas principais, selecao de fases, templates e fases jogaveis.
- `Prefab/`: cenas reutilizaveis, como jogador, UI, checkpoints, portas, armadilhas e objetos.
- `Scripts/`: logica de gameplay, save, menus, player, fases e integracoes.
- `Rescources/`: resources de configuracao de progresso/fases.
- `Tilesets/`: tilesets montados para as fases.
- `Translation/`: arquivos de traducao do jogo.
- `addons/`: plugins nativos e integracoes externas usadas pelo projeto.

## Sistemas importantes

- `Scripts/GameManager.gd`: controla fluxo de jogo, respawn, fases, vidas, chaves, engrenagens, checkpoints e fim de fase.
- `Scripts/SaveManager.gd`: controla save local em `user://memorycard.json` e sincronizacao com dados de fase.
- `Scripts/player_final.gd`: movimento do personagem, incluindo pulo variavel, coyote time, wall slide e wall jump.
- `Rescources/stage_select_library.tres`: lista de capitulos/fases, progresso inicial e objetivos.
- `Scripts/pos_game_ui.gd`: tela de resultado com avaliacao da simulacao.

## Cuidados de Git

Arquivos de cache, temporarios, exports e backups locais ficam fora do Git. Em Godot 4.6, arquivos `*.uid` devem ser versionados, pois guardam IDs estaveis de recursos. Arquivos `*.import` tambem devem ser versionados, pois guardam configuracoes de importacao dos assets.

Antes de compartilhar uma branch ou commit, confira:

```powershell
git status --short
```

## Observacoes de migracao

- O projeto ja esta com `config/features` apontando para Godot 4.6.
- A pasta `.godot/` e o template Android gerado em `/android/` nao devem ser versionados.
- Caso o Android use Ads, Google Play Services ou checagem de internet, revisar permissao de internet no preset de exportacao antes de publicar.
