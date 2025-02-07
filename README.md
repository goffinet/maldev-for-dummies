# Développement de logiciels malveillants pour les nuls

*À l'ère de l'EDR, les opérateurs de la red team ne peuvent plus se permettre d'utiliser des charges utiles précompilées. Le développement de logiciels malveillants devient donc une compétence essentielle pour tout opérateur. S'initier au maldev peut sembler intimidant, mais c'est en fait très facile. Cet atelier vous montrera tout ce dont vous avez besoin pour commencer !*

Ce dépôt contient les diapositives et les exercices qui accompagnent l'atelier « MalDev for Dummies » qui a été/sera animé à Hack in Paris 2022 et à X33fcon 2023. Bien que les diapositives aient été conçues pour être présentées « en personne », le matériel et les exercices resteront disponibles ici pour être complétés à votre rythme - le processus d'apprentissage ne doit jamais être précipité ! Les questions et les demandes d'ajout à ce dépôt sont les bienvenues.

> ⚠ **Avertissement :** Le développement de logiciels malveillants est une compétence qui peut - et doit - être utilisée à bon escient, pour faire progresser le domaine de la sécurité (offensive) et maintenir nos défenses en alerte. Si jamais vous utilisez ces compétences pour mener des activités pour lesquelles vous n'avez pas d'autorisation, vous êtes plus bête que ce que cet atelier est censé être et vous devriez déguerpir d'ici.

## Description de l'atelier

Les outils antivirus (AV) et de détection et réponse d'entreprise (EDR) gagnant en maturité de minute en minute, l'équipe rouge est obligée de garder une longueur d'avance. L'époque de l'exécution-assemblage et du dépôt de charges utiles non modifiées sur le disque est révolue. Si vous voulez que vos engagements durent plus d'une semaine, vous devrez intensifier votre création de charges utiles et votre développement de logiciels malveillants. Il peut cependant être intimidant de se lancer dans ce domaine et il n'est pas toujours facile de trouver les bonnes ressources.

Cet atelier s'adresse aux débutants dans le domaine et vous guidera dans vos premiers pas en tant que développeur de logiciels malveillants. Il s'adresse principalement aux praticiens offensifs, mais les praticiens défensifs sont également les bienvenus pour y assister et élargir leurs compétences. 

Pendant l'atelier, nous aborderons quelques notions théoriques, après quoi un environnement de laboratoire sera activé. Vous pourrez effectuer différents exercices en fonction de vos compétences actuelles et de votre niveau de maîtrise du sujet. Cependant, l'objectif de l'atelier est d'apprendre, et explicitement *non* de terminer tous les exercices. Vous êtes libre de choisir votre langage de programmation préféré pour le développement de logiciels malveillants, mais l'assistance pendant l'atelier est principalement fournie pour les langages de programmation C# et Nim.

Au cours de l'atelier, nous aborderons les principaux sujets nécessaires pour commencer à créer votre propre malware. Cela inclut (mais n'est pas limité à) :
- L'API Windows
- Les types de fichiers et les méthodes d'exécution
- L'exécution et l'injection de shellcode
- Les méthodes d'évasion AV et EDR

## Pour commencer

Pour commencer à développer des logiciels malveillants, vous aurez besoin d'une machine de développement afin de ne pas être gêné par les outils de défense qui pourraient s'exécuter sur votre machine hôte. Je préfère Windows pour le développement, mais Linux ou MacOS feront tout aussi bien l'affaire. Installez l'éditeur/IDE de votre choix (j'utilise [VS Code](https://code.visualstudio.com/) pour presque tout sauf C#, pour lequel j'utilise [Visual Studio](https://visualstudio.microsoft.com/vs/community/), puis installez les chaînes d'outils requises pour le langage MalDev de votre choix :

- **C#** : Visual Studio vous donnera la possibilité d'inclure les packages .NET dont vous aurez besoin pour développer en C#. Si vous souhaitez développer sans Visual Studio, vous pouvez télécharger le [.NET Framework](https://dotnet.microsoft.com/en-us/download/dotnet-framework) séparément.
- **Nim lang** : Suivez les [instructions de téléchargement](https://nim-lang.org/install.html). [Choosenim](https://github.com/dom96/choosenim) est un utilitaire pratique qui peut être utilisé pour automatiser le processus d'installation.
- **Golang** (merci à @nodauf pour la PR) : Suivez les [instructions de téléchargement](https://go.dev/doc/install).
- **Rust** : [Rustup](https://www.rust-lang.org/tools/install) peut être utilisé pour installer Rust ainsi que les chaînes d'outils requises. 

N'oubliez pas de désactiver Windows Defender ou d'ajouter les exclusions appropriées, afin que votre travail ne soit pas mis en quarantaine ! Plus tard, nous pourrons tester sur une autre machine avec des contrôles défensifs tels que l'antivirus activé.

> ℹ **Remarque :** Souvent, les gestionnaires de paquets tels qu'apt ou les outils de gestion de logiciels tels que Chocolatey ou Winget (désormais intégrés !) peuvent être utilisés pour automatiser l'installation et la gestion des dépendances de manière pratique et reproductible. Sachez toutefois que les versions des gestionnaires de paquets peuvent être en retard de quelques versions par rapport à la réalité ! Vous trouverez ci-dessous un exemple de commande pour installer tous les outils mentionnés en une seule fois.
>
> ```
>  choco install -y nim choosenim go rust vscode visualstudio2019community dotnetfx
> ```

## Compilation des programmes

Les langages dont nous parlerons au cours de cet atelier sont des langages *compilés*, ce qui signifie qu'un compilateur est utilisé pour traduire votre code source en exécutables binaires du format de votre choix. Le processus de compilation diffère selon le langage. 

### C#

Le code C# (fichiers .cs) peut être compilé directement (avec l'utilitaire csc) ou via Visual Studio lui-même. La plupart des codes sources de ce dépôt (à l'exception de la solution de l'exercice bonus 3) peuvent être compilés comme suit.

> ℹ **Remarque :** Assurez-vous d'exécuter la commande ci-dessous dans une « Invite de commande du développeur Visual Studio » afin qu'elle sache où trouver `csc`, il est recommandé d'utiliser l'« Invite de commande des outils natifs x64 » pour votre version de Visual Studio. L'indicateur `/unsafe` sera nécessaire pour la plupart des scripts où nous accédons directement à des fonctionnalités de bas niveau.

```
csc nomfichier.exe
```

Vous pouvez activer les optimisations de compilation avec l'indicateur `/optimize`. Vous pouvez également masquer la fenêtre de la console en ajoutant `/target:winexe`, ou compiler en tant que DLL avec `/target:library` (mais assurez-vous que la structure de votre code est adaptée à cette opération).

### Nim

Le code Nim (fichiers `.nim`) est compilé avec la commande `nim c`. Le code source de ce dépôt peut être compilé comme suit.

Si vous souhaitez optimiser votre build en termes de taille et supprimer les informations de débogage (bien mieux pour l'opsec !), vous pouvez ajouter les indicateurs suivants.

```
nim c filename.nim
```

Si vous souhaitez optimiser votre build en termes de taille et supprimer les informations de débogage (bien mieux pour l'opsec !), vous pouvez ajouter les options suivantes.

```
nim c -d:release -d:strip --opt:size filename.nim
```

Vous pouvez également masquer la fenêtre de la console en ajoutant également`--app:gui`.

### Golang

Le code Golang (fichiers .go) est compilé avec la commande go build. Le code source de ce dépôt peut être compilé comme suit.

```
GOOS=windows go build
```

Si vous souhaitez optimiser votre build en termes de taille et supprimer les informations de débogage (bien mieux pour l'opsec !), vous pouvez ajouter les indicateurs suivants.

```
GOOS=windows go build -ldflags "-s -w"
```

### Rust

Le code Rust (fichiers `.rs`) est compilé via la commande `cargo`. [Cargo](https://doc.rust-lang.org/cargo/guide) peut être utilisé pour gérer vos dépendances et construire votre projet. Le code source de ce dépôt peut être compilé en accédant au dossier du projet et en exécutant la commande suivante.

```
cargo build
```

Si vous souhaitez optimiser votre build en termes de taille et supprimer les informations de débogage, vous pouvez ajouter les options suivantes. Reportez-vous également à la section [profile.release] de chaque fichier Cargo.toml pour connaître certaines options d'opsec de compilation.

```
cargo build --release
```

## Dépendances

### C#

La plupart des solutions peuvent être compilées sans dépendances. Si des dépendances sont nécessaires, un projet Visual Studio est fourni qui se lie aux packages NuGet appropriés.

### Nim

La plupart des programmes Nim dépendent d'une bibliothèque appelée « Winim » pour s'interfacer avec l'API Windows. Vous pouvez installer la bibliothèque avec le gestionnaire de packages Nimble comme suit (après avoir installé Nim) :

```
nimble install winim
```

### Golang

Certaines dépendances sont utilisées dans le code source de ce dépôt. Vous pouvez les installer comme suit (après avoir installé Go) :

```
go mod tidy
```

### Rust

Certains exemples dépendent de la caisse `windows-sys` pour appeler l'API Windows. Comme nous utilisons Cargo, les paquets seront automatiquement gérés lorsque vous compilerez un test ou une version finale.

## Ressources

Les diapositives de l'atelier font référence à certaines ressources que vous pouvez utiliser pour commencer. Des ressources supplémentaires, telles que des blogs pertinents ou des extraits de code, sont répertoriées dans les fichiers README.md de chaque exercice !
