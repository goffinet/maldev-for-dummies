# Exercice 1 - Chargeur de shellcode de base

## Description

Utilisez `msfvenom` pour générer du shellcode, et écrivez un loader de base qui l'exécute dans le processus en cours.

## Astuces

Cet exercice vous plonge dans le grand bain par principe ! Si vous êtes perdu, commencez par regarder quelques exemples open-source, puis essayez de reproduire vous-même ce qu'ils font.

ℹ **Remarque :** il peut être tentant de copier-coller des exemples entiers, mais ce n'est pas conseillé pour plusieurs raisons :

1. Vous apprenez mieux en appliquant les techniques vous-même.
2. Le code public est souvent marqué, le faire à votre façon aidera à l'évasion.
3. Certains dépôts peuvent inclure du code malveillant (par exemple, du mauvais shellcode) que vous pourriez exécuter accidentellement.

### msfvenom

Avec `msfvenom`, vous pouvez choisir un « format » (`-f`) pour obtenir les octets au format adapté à votre langage. Il dispose de "formateurs" pour la plupart des langages, que vous pouvez vérifier en exécutant `--list formats`. Les formats pertinents ici sont `-f csharp`, `-f nim`, `-f go` ou `-f rust`, mais il en existe d'autres. Voici une commande d'exemple qui génère du shellcode que vous pouvez utiliser pour afficher une boîte de message (fonctionne bien comme preuve de concept !) :

```bash
msfvenom -p windows/x64/messagebox TEXT='Task failed successfully!' TITLE='Error!' -f nim
```

### Combinaisons d'API Windows

Rappelez-vous les différents appels d'API que vous pouvez utiliser. Il existe deux combinaisons qui sont les plus pertinentes pour cet exercice :

- [copie de la mémoire] + `VirtualProtect()` + `CreateThread()`
 
    C'est la façon la plus simple de faire exécuter votre shellcode. Comme le shellcode est déjà placé en mémoire au moment où vous définissez une variable, vous pouvez « sauter » la première étape et simplement cibler la variable avec votre shellcode avec l'appel `VirtualProtect()` pour la rendre exécutable. Après cela, vous pouvez utiliser `CreateThread()` pour exécuter le shellcode (ou lancer un pointeur, voir ci-dessous).

- `VirtualAlloc()` + copie de la mémoire + `CreateThread()`
 
    Il s'agit d'une alternative à la méthode ci-dessus, une autre façon très populaire d'exécuter du shellcode. Vous pouvez utiliser `VirtualAlloc()` pour allouer une région de mémoire exécutable pour le shellcode, puis copier votre shellcode dans la mémoire allouée. Le résultat est le même que pour la première méthode.

La copie de la mémoire peut être effectuée sans appel à l'API à l'aide de fonctions intégrées, telles que `Marshal.copy` pour C#, `copyMem` pour Nim, `std::ptr::copy` pour Rust.

> ⚠ **Remarque :** selon le type de shellcode que vous utilisez, vous devrez peut-être utiliser l'API `WaitForSingleObject()` pour maintenir votre programme en vie pendant qu'il exécute votre shellcode. Cela n'est nécessaire que pour les shellcodes à exécution longue, comme une balise [CobaltStrike](https://www.cobaltstrike.com).

> 😎 Si vous vous sentez l'âme d'un aventurier, vous pouvez utiliser les équivalents natifs de ces fonctions (fonctions Nt de `NTDLL.dll`). Voir aussi [exercice bonus 1](../BONUS%20Exercise%201%20-%20Basic%20Loader%20Without%20CreateThread/). Il existe également de nombreuses autres fonctions API à explorer. Pour un aperçu, consultez [malapi.io](https://malapi.io/).

### Appeler l'API Windows (C# uniquement)

C# ne dispose pas d'un support natif pour appeler l'API Windows, vous devrez donc définir vous-même les fonctions API que vous souhaitez utiliser. C'est ce qu'on appelle le P/Invoke. Heureusement, la plupart des fonctions API et la manière de les appeler ont été bien documentées, par exemple sur [pinvoke.net](https://pinvoke.net/).

Vous pouvez également choisir de résoudre dynamiquement les appels de fonction. Bien que plus difficile à mettre en oeuvre, cette solution est beaucoup plus sûre sur le plan de la sécurité opérationnelle. La [bibliothèque D/Invoke](https://github.com/TheWover/DInvoke) peut être utilisée pour la mettre en oeuvre.

### Casting de pointeurs - une alternative à `CreateThread()`

Au lieu d'utiliser l'API `CreateThread()`, vous pouvez utiliser une technique appelée « casting de pointeur » pour transformer votre shellcode en mémoire en une fonction et l'exécuter dans le thread actuel. Vous pouvez voir des exemples [ici (C#)](https://tbhaxor.com/execute-unmanaged-code-via-c-pinvoke/), [ici (Rust)](https://stackoverflow.com/a/46134764), et [ici (Nim)](https://github.com/byt3bl33d3r/OffensiveNim/issues/16#issuecomment-757228116). Cela évite d'appeler une fonction API suspecte, mais pose des problèmes en soi (comme le blocage du thread ou les éventuels plantages du programme après le retour de votre shellcode).

### Astuces pour Rust

Il existe plusieurs « crates » (bibliothèques) que vous pouvez utiliser pour appeler l'API Windows depuis Rust. Microsoft gère deux crates officielles appelées [`windows`](https://microsoft.github.io/windows-docs-rs/) et [`windows-sys`](https://docs.rs/windows-sys), la première introduisant une certaine surcharge mais permettant une programmation plus idiomatique dans Rust, et la seconde étant essentiellement une bibliothèque avec des fonctions brutes et des liaisons de types. Il existe également des crates tierces telles que `winapi` qui atteignent essentiellement le même objectif. Vous pouvez jouer avec les différentes crates pour voir celle que vous préférez.

### Astuces Golang

La bibliothèque `golang.org/x/sys/windows` est la bibliothèque officielle de Golang qui implémente l'API Windows. Cependant, certaines API inhabituelles que nous utilisons dans le développement de logiciels malveillants peuvent être absentes de cette bibliothèque. Par exemple, la fonction CreateThread n'est pas disponible.

Pour implémenter cette fonction dans notre code, nous pouvons utiliser le package `golang.org/x/sys/windows/mkwinsyscall` pour générer un fichier (généralement [`zsyscall_windows.go`](https://github.com/golang/sys/blob/master/windows/zsyscall_windows.go) généré à partir de [`syscall_windows.go`](https://github. com/golang/sys/blob/c0bba94af5f85fbad9f6dc2e04ed5b8fac9696cf/windows/syscall_windows.go#L168)) qui contiendra toutes nos API Windows implémentées en Golang.

Pour générer la bonne ligne d'entrée pour `mkwinsyscall`, nous devons obtenir la syntaxe de la fonction. Heureusement, celle-ci est documentée sur [Microsoft](https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createthread) :

```
HANDLE CreateThread(
  [in, optional]  LPSECURITY_ATTRIBUTES   lpThreadAttributes,
  [in]            SIZE_T                  dwStackSize,
  [in]            LPTHREAD_START_ROUTINE  lpStartAddress,
  [in, optional]  __drv_aliasesMem LPVOID lpParameter,
  [in]            DWORD                   dwCreationFlags,
  [out, optional] LPDWORD                 lpThreadId
);
```

La ligne correspondante pour `mkwinsyscall` est la suivante

```
//sys   CreateThread(lpThreadAttributes *SecurityAttributes, dwStackSize uint32, lpStartAddress uintptr, lpParameter uintptr, dwCreationFlags uint32, lpThreadId *uint32)(threadHandle windows.Handle, err error) = kernel32.CreateThread
```

Il s'agit en gros du prototype de la fonction avec à la fin l'emplacement de la fonction dans l'API Windows, dans notre cas `kernel32.CreateRemoteThread`.
La partie délicate consiste à traduire chaque type `C` en un type Golang. Pour simplifier le processus, vous pouvez examiner les lignes existantes dans le package Windows et si quelque chose ne va pas, déboguer avec un outil tel que [APIMonitor](https://apimonitor.com/) et comparer avec un appel fonctionnel de l'API.

Enfin, assurez-vous d'ajouter la ligne suivante dans `syscall_windows.go`

```golang
//go:generate go run golang.org/x/sys/windows/mkwinsyscall -output zsyscall_windows.go syscall_windows.go
```

Ensuite, le fichier zsyscall_windows.go peut être généré avec :

```bash
go generate syscall_windows.go
```

Ces étapes peuvent prendre du temps, mais en attendant la mise à jour du package Windows, vous pouvez trouver plusieurs API déjà implémentées dans le dépôt [go-windows](https://github.com/nodauf/go-windows).


## Références

### C#

- [Exécuter du code non géré via C# P/Invoke](https://tbhaxor.com/execute-unmanaged-code-via-c-pinvoke/)
- [Offensive P/Invoke: Leveraging the Win32 API from Managed Code](https://posts.specterops.io/offensive-p-invoke-leveraging-the-win32-api-from-managed-code-7eef4fdef16d)
- [x64ShellcodeLoader.cs](https://gist.github.com/matterpreter/03e2bd3cf8b26d57044f3b494e73bbea)

### Golang

- [CreateThread/main.go](https://github.com/Ne0nd0g/go-shellcode/blob/master/cmd/CreateThread/main.go)

### Nim

- [shellcode_loader.nim](https://github.com/sh3d0ww01f/nim_shellloader/blob/master/shellcode_loader.nim)
- [Exécution du shellcode dans le même thread](https://github.com/byt3bl33d3r/OffensiveNim/issues/16#issuecomment-757228116)

### Rust

- [Shellcode_Local_Inject](https://github.com/trickster0/OffensiveRust/blob/master/Shellcode_Local_inject/src/main.rs)
- [Process_Injection_Self_EnumSystemGeoID](https://github.com/trickster0/OffensiveRust/blob/master/Process_Injection_Self_EnumSystemGeoID/src/main.rs)

## Solution

Des exemples de solutions sont fournis dans le [dossier solutions](solutions/). Gardez à l'esprit qu'il n'y a pas de « bonne » réponse, si vous avez réussi à faire fonctionner le système, c'est une solution valable ! 
