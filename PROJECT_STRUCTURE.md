# Estrutura no Roblox Studio

Crie estes objetos e coloque o conteúdo dos arquivos correspondentes:

```text
ReplicatedStorage
├── Shared (Folder)
│   ├── Config (ModuleScript)
│   ├── Util (ModuleScript)
│   ├── Remotes (ModuleScript)
│   └── GameAPI (ModuleScript)
ServerScriptService
└── Server (Folder)
    ├── init.server.lua (Script)
    ├── ConfigStore (ModuleScript)
    ├── NavigationService (ModuleScript)
    ├── CombatService (ModuleScript)
    ├── AutoFarmService (ModuleScript)
    ├── InventoryService (ModuleScript)
    ├── RaidService (ModuleScript)
    ├── BossService (ModuleScript)
    └── MasteryService (ModuleScript)
StarterPlayer
└── StarterPlayerScripts
    └── Client (Folder)
        ├── init.client.lua (LocalScript)
        └── UI (Folder)
            ├── Components (ModuleScript)
            └── MainPanel (ModuleScript)
```

Os nomes dos objetos no Studio precisam corresponder aos nomes usados nos `require`.
