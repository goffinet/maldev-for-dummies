# Bonus Exercice 2 - Injecteur de base avec cible dynamique

## Description

Modifiez votre injecteur de [Exercice 2](../Exercice%202%20-%20Basic%20Shellcode%20Injector/) de manière à ce que le processus cible soit configurable et que le programme crée le processus s'il n'existe pas déjà.

## Astuces

Il s'agit avant tout d'un exercice de programmation. L'ajout de fonctionnalités de ce type est un excellent moyen de se familiariser avec le langage de programmation choisi ! Le programme injecteur doit demander à l'utilisateur un nom de processus via la ligne de commande, et résoudre ce nom en un ID de processus (voir l'API `CreateToolhelp32Snapshot()`) si nécessaire, en créant le processus s'il n'existe pas encore (pour les besoins de cet exercice, vous pouvez supposer que le binaire existera dans le chemin de l'utilisateur). Ensuite, l'injecteur doit utiliser ce processus comme cible d'injection comme précédemment.

## Références

### C#

- [Entrée utilisateur C#](https://www.w3schools.com/cs/cs_user_input.php)
- [Fonction Process.GetProcessesByName()](https://docs.microsoft.com/en-us/dotnet/api/system.diagnostics.process.getprocessesbyname)

### Golang

- [fmt.Scanln](https://pkg.go.dev/fmt#Scanln)

### Nim

- [commandLineParams](https://nim-lang.org/docs/os.html#commandLineParams)
- [minidump_bin.nim](https://github.com/byt3bl33d3r/OffensiveNim/blob/965c44cec96575758eaa42622f699b6ea0d1041a/src/minidump_bin.nim#L36-L48)

### Rust

- [std::io::Stdin::read_line()](https://doc.rust-lang.org/stable/std/io/struct.Stdin.html#method.read_line)
- [Exemple d'implémentation de l'entrée utilisateur dans srdi-rs/inject](https://github.com/trickster0/OffensiveRust/blob/master/memN0ps/srdi-rs/inject/src/main.rs#L115-L119)

## Solution

Des exemples de solutions sont fournis dans le [dossier solutions](solutions/). Gardez à l'esprit qu'il n'y a pas de « bonne » réponse, si vous avez réussi à le faire fonctionner, c'est une solution valable ! 
