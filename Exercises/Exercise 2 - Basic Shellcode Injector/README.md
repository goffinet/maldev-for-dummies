# Exercice 2 - Injecteur de shellcode de base

## Description

Créez un nouveau projet qui injecte votre shellcode dans un processus distant, tel que `explorer.exe`.

## Astuces

Cet exercice est en fait très similaire à l'[Exercice 1](../Exercice%201%20-%20Basic%20Shellcode%20Loader/) en termes de mise en oeuvre. L'approche de base est comparable à la méthode `VirtualAlloc()` que nous avons vue précédemment, sauf que cette fois-ci nous utilisons une combinaison d'API différente : `OpenProcess()` pour obtenir un handle sur le processus cible, `VirtualAllocEx()` pour allouer de la mémoire exécutable dans le processus distant, `WriteProcessMemory()` pour copier le shellcode dans la mémoire allouée, et `CreateRemoteThread()` pour exécuter le shellcode en tant que partie du processus cible.

> ℹ **Remarque :** Il existe de nombreuses alternatives aux appels d'API ci-dessus. Consultez [malapi.io](https://malapi.io/) pour un excellent aperçu des fonctions de l'API Windows qui peuvent être utilisées à des fins malveillantes. La section « Injection » est particulièrement pertinente ici !

> 😎 Si vous vous sentez l'âme d'un aventurier, vous pouvez utiliser les équivalents natifs de ces fonctions (fonctions Nt de `NTDLL.dll`). Vous pouvez également chercher d'autres moyens d'exposer votre shellcode à la mémoire du processus cible, tels que `NtCreateSection()` et `NtMapViewOfSection()` (exemple [ici](https://www.ired.team/offensive-security/code-injection-process-injection/ntcreatesection-+-ntmapviewofsection-code-injection)).

### Obtenir un handle

Gardez à l'esprit que pour obtenir un handle, nous devons disposer de privilèges suffisants sur le processus cible. Cela signifie généralement que vous ne pouvez obtenir un handle que pour un processus appartenant à l'utilisateur actuel, et non pour ceux appartenant à d'autres utilisateurs ou gérés par le système lui-même (c'est logique, non ?). Cependant, si vous exécutez depuis un contexte privilégié (c'est-à-dire en tant que SYSTEM ou avec le privilège SeDebugPrivilege activé), vous pouvez obtenir un handle pour n'importe quel processus, y compris les processus système. 

Lorsque vous concevez un logiciel malveillant qui s'injecte à distance, vous devez être conscient du processus cible que vous choisissez. Choisir le mauvais processus peut entraîner l'échec de votre logiciel malveillant car le processus n'est pas présent ou vous n'avez pas suffisamment de privilèges. De plus, l'injection à partir d'un contexte privilégié dans un processus à faibles privilèges fera baisser vos privilèges.

> ℹ **Remarque :** C'est pourquoi il est judicieux de rendre le processus cible configurable et de le baser sur l'environnement cible. Vous pouvez coder en dur le nom ou l'ID de processus de `explorer.exe` pour l'instant, nous améliorerons cette fonctionnalité dans [exercice bonus 2](../BONUS%20Exercise%202%20-%20Basic%20Injector%20With%20Dynamic%20Target/).

## Références

### C#

- [Un exemple simple d'injection de code Windows écrit en C#](https://andreafortuna.org/2019/03/06/a-simple-windows-code-injection-example-written-in-c/)

### Golang

- [CreateRemoteThread/main.go](https://github.com/Ne0nd0g/go-shellcode/blob/master/cmd/CreateRemoteThread/main.go)

### Nim

- [shellcode_bin.nim](https://github.com/byt3bl33d3r/OffensiveNim/blob/master/src/shellcode_bin.nim)

### Rust

- [Process_Injection_CreateRemoteThread](https://github.com/trickster0/OffensiveRust/blob/master/Process_Injection_CreateRemoteThread/src/main.rs)
- [Shellcode_Runner_Classic-rs](https://github.com/memN0ps/arsenal-rs/blob/main/shellcode_runner_classic-rs/src/main.rs)

## Solution

Des exemples de solutions sont fournis dans le [dossier solutions](solutions/). Gardez à l'esprit qu'il n'y a pas de « bonne » réponse, si vous avez réussi à le faire fonctionner, c'est une solution valable ! 
