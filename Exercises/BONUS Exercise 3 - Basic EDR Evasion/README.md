# Bonus Exercice 4 - Évasion de base des EDR

## Description

Modifiez votre loader ou injecteur à partir de l'un des exercices précédents, de manière à ce qu'il mette en oeuvre une ou plusieurs des techniques d'évasion EDR mentionnées. Testez-le contre EDR si vous le pouvez.

## Conseils

N'oubliez pas que l'EDR examine le comportement de votre logiciel malveillant et recueille des données télémétriques provenant de diverses sources. Cela signifie que vous pouvez soit vous concentrer sur la manière d'éviter l'EDR, en déguisant votre logiciel malveillant pour qu'il soit « suffisamment légitime » pour ne pas être détecté (ce qui est malheureusement difficile à faire pour l'injection de shellcode), en trouvant les angles morts de l'EDR, soit en contournant ou en falsifiant activement la collecte de données télémétriques de l'EDR. De nombreux contournements d'EDR (tels que les appels système directs, le décrochage ou le patching ETW) sont axés sur la dernière de ces options. La section « Références » contient quelques bons conseils qui incluent des considérations pour choisir votre méthode de contournement d'EDR préférée.

### Conseils pour les tests

Il n'est pas toujours facile d'accéder à un EDR commercial. Un bon moyen de tester un EDR (partiellement) gratuit est [Elastic Endpoint Security](https://www.elastic.co/security/endpoint-security/). Vous pouvez également essayer des versions d'essai gratuites de logiciels commerciaux. Certains antivirus, tels que BitDefender, proposent également un accrochage API pour une expérience de type EDR.

### Conseils Golang

La solution en Golang implémente des appels système directs grâce au package [`BananaPhone`](https://github.com/C-Sto/BananaPhone). Ce package implémente, pour l'instant, deux techniques pour récupérer l'ID de l'appel système : Halo's gate et Hell's gate. Il y a deux façons d'utiliser ce package.

La première consiste à obtenir l'ID de l'appel système et à l'appeler directement.

```
// Récupérer l'ID de l'appel système pour NtAllocateVirtualMemory
alloc, err := bp.GetSysID(« NtAllocateVirtualMemory »)
...
// Appeler l'appel système avec l'ID de l'appel système et les arguments
_, err = bananaphone.Syscall(
        alloc, //ntallocatevirtualmemory
        thisThread,
        uintptr(unsafe.Pointer(&rPtr)),
        0,
        uintptr(unsafe.Pointer(&regionsize)),
        uintptr(memCommit|memreserve),
		windows.PAGE_EXECUTE_READWRITE,
    )
...
```

Chaque argument de `bananaphone.Syscall` est un uintptr.

La deuxième méthode consiste à utiliser [`mkdirectwinsyscall`](https://github.com/C-Sto/BananaPhone/tree/master/cmd/mkdirectwinsyscall) pour générer un wrapper de syscall.
Pour générer la bonne ligne d'entrée pour `mkdirectwinsyscall`, nous devons obtenir la syntaxe de la fonction. Heureusement, celle-ci est documentée sur [Microsoft](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/ntifs/nf-ntifs-ntallocatevirtualmemory) :

```
__kernel_entry NTSYSCALLAPI NTSTATUS NtAllocateVirtualMemory(
  [in]      HANDLE    ProcessHandle,
  [in, out] PVOID     *BaseAddress,
  [in]      ULONG_PTR ZeroBits,
  [in, out] PSIZE_T   RegionSize,
  [in]      ULONG     AllocationType,
  [in]      ULONG     Protect
);
```

La ligne correspondante pour `mkwinsyscall` est la suivante

```
//dsys NtAllocateVirtualMemory(processHandle windows.Handle, baseAddress *uintptr, zeroBits uintptr, regionSize *uintptr, allocationType uint64, protect uint64) (err error)
```

Il s'agit essentiellement du prototype de la fonction Golang.
La partie délicate consiste à traduire chaque type `C` en un type Golang. Pour simplifier le processus, vous pouvez examiner les lignes existantes dans le package Windows et si quelque chose ne va pas, déboguer avec un outil tel que [APIMonitor](https://apimonitor.com/) et comparer avec un appel fonctionnel de l'API.

Enfin, assurez-vous d'ajouter la ligne suivante dans `syscall.go`

```
//go:generate go run github.com/C-Sto/BananaPhone/cmd/mkdirectwinsyscall -output zsyscall_windows.go syscall.go
```

Et ensuite, le fichier zsyscall_windows.go peut être généré avec :

```bash
go generate syscall.go
```

Ces étapes peuvent prendre du temps, mais vous pouvez trouver plusieurs API déjà implémentées dans le dépôt [bananaWinSyscall](https://github.com/nodauf/bananaWinSyscall).

## Références

### Générique

- [Blinding EDR On Windows](https://synzack.github.io/Blinding-EDR-On-Windows/)
- [Une histoire de méthodes de contournement de l'EDR](https://s3cur3th1ssh1t.github.io/A-tale-of-EDR-bypass-methods/)
- [Créons une EDR... Et contournons-la !](https://ethicalchaos.dev/2020/05/27/lets-create-an-edr-and-bypass-it-part-1/)

Reportez-vous à [Exercice 3](../Exercice%203%20-%20Basic%20AV%20Evasion/) pour plus de références.


### C#

- [D/Invoke](https://github.com/TheWover/DInvoke)

### Golang

- [BananaPhone](https://github.com/C-Sto/BananaPhone)

### Nim

- [NimlineWhispers3](https://github.com/klezVirus/NimlineWhispers3)

### Rust

- [Rust_Syscalls](https://github.com/janoglezcampos/rust_syscalls)

## Solution

Des exemples de solutions sont fournis dans le [dossier solutions](solutions/). Gardez à l'esprit qu'il n'y a pas de « bonne » réponse, si vous avez réussi à le faire fonctionner, c'est une solution valable ! 
