# Exercice 3 - Évasion antivirus de base

## Description

Implémentez une ou plusieurs des techniques d'évasion décrites dans votre chargeur/injecteur de shellcode et testez-le contre AV.

## Conseils

Il n'y a pas de solution miracle pour cet exercice, car AV pourrait détecter divers aspects de votre chargeur. De plus, les indicateurs utilisés par AV sont en constante évolution et pourraient être complètement différents demain ! Certains points clés pour discuter des AV sont abordés ci-dessous, mais référez-vous aux diapositives de l'atelier et aux ressources fournies pour un aperçu complet.

> ℹ **Remarque :** Il sera légèrement plus facile de rendre votre chargeur de shellcode local évasif que votre injecteur de shellcode distant.
> Pourquoi ne pas essayer les deux ?

### Obfuscation du shellcode

Les shellcodes générés par des outils tels que msfvenom ou les frameworks C2 sont bien connus et faciles à détecter par les antivirus. Pour contrer cela, nous pouvons encoder/chiffrer notre shellcode, et ne le décoder/déchiffrer que lorsque nous sommes prêts à l'exécuter. L'encodage consiste à modifier le format des données de manière réversible et est souvent utilisé pour transmettre des données (par exemple, l'encodage d'URL ou l'encodage Base64). Le chiffrement consiste à modifier les données à l'aide d'un algorithme mathématique et d'une clé secrète. Les deux sont réversibles et peuvent être utilisés pour modifier le format de votre shellcode. Gardez toutefois à l'esprit que les algorithmes tels que Base64 sont si largement utilisés que les antivirus peuvent également les décoder et les inspecter.

Un choix courant pour chiffrer le shellcode est un schéma XOR simple avec une clé d'un ou plusieurs octets. Bien que peu robuste en termes de chiffrement, l'un des avantages de XOR est qu'il est facilement réversible (la fonction de chiffrement et de déchiffrement sont les mêmes), ce qui le rend très facile à mettre en oeuvre.

> ℹ **Remarque :** Notez que le chiffrement d'un très gros blob de shellcode augmentera l'[entropie](https://malwaretips.com/threads/malware-analysis-2-what-is-entropy-and-how-do-i-find-the-entropy-of-a-file.42333/) de votre fichier, ce qui pourrait devenir un indicateur de malveillance. Pour y remédier, envisagez d'utiliser différents schémas de codage, par exemple en encodant votre shellcode chiffré dans une chaîne de caractères contenant des mots anglais.

### Obfuscation des chaînes de caractères

Les chaînes de caractères définies dans votre code sont enregistrées dans le binaire lui-même. Cela signifie que la définition de variables de chaîne avec un contenu suspect (comme des noms ou des modèles de fonction suspects, ou des chaînes connues pour être mauvaises, telles que des noms de logiciels malveillants) est facilement détectable par les antivirus. Pour contrer cela, nous pouvons stocker une variante encodée ou chiffrée de ces chaînes dans le binaire, et ne les décoder/déchiffrer que lorsque cela est nécessaire. Le processus et les considérations pour ce faire sont les mêmes que ceux décrits ci-dessus.

### Obscurcissement des appels de fonction

> ℹ **Remarque :** si vous utilisez Nim, cette section est moins pertinente. Nim résout automatiquement les fonctions de manière dynamique grâce à son interface de fonctions étrangères (FFI, plus d'informations [ici](https://github.com/byt3bl33d3r/OffensiveNim#opsec-considerations)), ce qui signifie que vous n'avez pas à obfusquer manuellement vos appels de fonction. Très avantageux pour les auteurs de logiciels malveillants !

Les antivirus analysent souvent les fonctions utilisées par un binaire via la table d'adresses d'importation (IAT). Si un ensemble de fonctions suspectes, telles que celles dont nous avons parlé dans les modules précédents, est utilisé conjointement par un binaire, l'antivirus est susceptible de classer ce binaire comme suspect et de le mettre en quarantaine (ou du moins de l'examiner pour une analyse plus approfondie). Pour éviter que les appels de fonction n'apparaissent dans l'IAT, nous pouvons les obfusquer en les résolvant dynamiquement. Cela peut être fait en utilisant les API Windows `GetModuleHandle()` et `GetProcAddress()` pour résoudre l'adresse de la fonction, puis en l'appelant avec la bonne définition de fonction de MSDN (par exemple [VirtualProtect](https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualprotect)). Gardez à l'esprit que toutes les chaînes utilisées pour résoudre dynamiquement les appels de fonction apparaîtront également dans votre binaire ! Envisagez de brouiller ou de chiffrer ces chaînes pour vous débarrasser d'un autre indicateur.

Vous pouvez également utiliser des bibliothèques qui permettent d'invoquer des fonctions de manière dynamique, telles que [D/Invoke](https://github.com/TheWover/DInvoke) pour C# ou [NimlineWhispers](https://github.com/ajpc500/NimlineWhispers2) pour Nim. Ces bibliothèques résolvent et appellent des fonctions au moment de l'exécution, ou implémentent elles-mêmes les fonctions, ce qui permet d'échapper à la fois à l'analyse statique des fonctions importées et à l'analyse dynamique par AV et EDR. Voir également [exercice bonus 3](../BONUS%20Exercise%203%20-%20Basic%20EDR%20Evasion/).

### Contourner l'analyse dynamique

Parce que les antivirus ont des ressources limitées à gérer, les opérations de scan coûteuses ne sont généralement effectuées que sur les processus suspects. Nous pouvons abuser des raccourcis qu'un antivirus prend, par exemple en ne déclenchant notre charge utile que lorsqu'elle correspond à l'environnement cible (« payload keying »), en effectuant des opérations innocentes jusqu'à ce qu'un environnement sandbox expire (30-60s), ou en faisant passer notre code malveillant pour inoffensif lorsque nous attendons qu'un antivirus le scanne (par exemple [suspended thread injection](https://github.com/plackyhacker/Suspended-Thread-Injection)). Il n'y a vraiment aucune limite au déploiement de ces contournements, si ce n'est votre créativité !

### Test contre les antivirus

Les tests contre les produits antivirus (et EDR) peuvent parfois être frustrants, car les fournisseurs limitent délibérément les informations techniques disponibles sur leurs détections. Des sites tels que [VirusTotal](https://www.virustotal.com/) peuvent être utilisés pour vérifier un certain nombre de produits antivirus, mais il n'est **pas conseillé** de tester votre logiciel malveillant sur ces sites, car les échantillons soumis sont partagés avec les défenseurs (ce qui entraînera l'analyse et l'empreinte de votre logiciel malveillant). [Antiscan](https://antiscan.me) promet de fournir ce service sans soumettre d'échantillon, mais on ne peut jamais faire confiance aux sites douteux, n'est-ce pas ? :)

Une alternative viable pour tester Windows Defender est [ThreatCheck](https://github.com/rasta-mouse/ThreatCheck). Cet outil divise votre binaire jusqu'à ce qu'il trouve les octets sur lesquels Defender (ou l'interface d'analyse antimalware, AMSI) signale. Cela vous permettra d'identifier la partie de votre binaire considérée comme malveillante. Le résultat pourrait être une chaîne facile à corriger, mais il pourrait aussi s'agir d'un ensemble d'instructions binaires combinées, ce qui rend la correction plus difficile.

## Références

### Générique

- [Evasions](https://evasions.checkpoint.com/)

### C#

- [D/Invoke](https://github.com/TheWover/DInvoke)
- [Emulating Covert Operations - Dynamic Invocation (Avoiding PInvoke & API Hooks)](https://thewover.github.io/Dynamic-Invoke/)
- [Dynamic Invocation in .NET to bypass hooks](https://blog.nviso.eu/2020/11/20/dynamic-invocation-in-net-to-bypass-hooks/)
- [CheckPlease - C#](https://github.com/Arvanaghi/CheckPlease/tree/master/C%23)
- [encryptedShellcodeWrapper.cs](https://github.com/Arno0x/ShellcodeWrapper/blob/master/templates/encryptedShellcodeWrapper.cs)
- [ConfuserEx](https://github.com/mkaring/ConfuserEx)

### Golang

- [ShellcodeUtils](https://github.com/Ne0nd0g/go-shellcode/blob/master/cmd/ShellcodeUtils/main.go)
- [UuidFromString](https://github.com/Ne0nd0g/go-shellcode/blob/master/cmd/UuidFromString/main.go)

### Nim

- [NimlineWhispers2](https://github.com/ajpc500/NimlineWhispers2) ou [NimlineWhispers3](https://github.com/klezVirus/NimlineWhispers3)
- [suspended_thread_injection.nim](https://github.com/byt3bl33d3r/OffensiveNim/blob/master/src/suspended_thread_injection.nim)
- [Denim](https://github.com/moloch--/denim)

### Rust

- [obfstr](https://docs.rs/obfstr/latest/obfstr/)
- [obfuscate_shellcode-rs](https://github.com/memN0ps/arsenal-rs/blob/main/obfuscate_shellcode-rs/src/main.rs)
- [Injection_Rc4_Loader](https://github.com/trickster0/OffensiveRust/blob/master/Injection_Rc4_Loader/src/main.rs)
- [Injection_AES_Loader](https://github.com/trickster0/OffensiveRust/blob/master/Injection_AES_Loader/src/main.rs)

## Solution

Des exemples de solutions sont fournis dans le [dossier solutions](solutions/). Gardez à l'esprit qu'il n'y a pas de « bonne » réponse, si vous avez réussi à le faire fonctionner, c'est une solution valable !

> ℹ **Remarque :** La solution d'exemple peut être détectée par l'antivirus car elle est disponible publiquement. Vous devriez cependant pouvoir contourner l'antivirus en utilisant des techniques similaires !
