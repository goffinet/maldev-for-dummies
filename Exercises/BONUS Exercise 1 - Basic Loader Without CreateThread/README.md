# Bonus Exercice 1 - Loader de base sans CreateThread

## Description

Modifiez votre loader de [Exercice 1](../Exercice%201%20-%20Basic%20Shellcode%20Loader/) afin qu'il exécute le shellcode sans appeler `CreateThread()`.

## Astuces

Nous avons discuté de certaines méthodes de chargement dans les diapositives et [Exercice 1](../BONUS%20Exercice%201%20-%20Basic%20Loader%20Without%20CreateThread/). Pour se débarrasser de l'appel à l'API `CreateThread()`, on peut soit utiliser la technique du « casting d'un pointeur », soit utiliser l'API native `NtCreateThreadEx()` pour créer notre thread à la place.

ℹ **Remarque :** Vous vous demandez peut-être pourquoi nous avons utilisé `NtCreateThreadEx()` au lieu de `NtCreateThread()` pour l'exécution locale. La réponse est que `NtCreateThreadEx()` est beaucoup plus simple à utiliser : la fonction `NtCreateThread()` nous oblige à initialiser un « Thread Information Block » (TIB) complet avant de pouvoir l'appeler, ce qui n'est pas le cas de la variante `NtCreateThreadEx()`.

Il existe de nombreuses alternatives à ce qui précède. Consultez [malapi.io](https://malapi.io/) pour un excellent aperçu des fonctions de l'API Windows qui peuvent être utilisées à des fins malveillantes. La section « Injection » est particulièrement pertinente ici !

> 😎 Si vous vous sentez l'âme d'un aventurier, profitez de cette occasion pour vous débarrasser complètement de tous les appels d'API de haut niveau et n'utiliser que l'API native. C'est plus difficile à écrire, mais l'utilisation de cette API deviendra certainement une compétence vitale pour contourner l'EDR par la suite.

## Références

Reportez-vous à [Exercice 1](../BONUS%20Exercice%201%20-%20Basic%20Loader%20Without%20CreateThread/).

## Solution

Des exemples de solutions sont fournis dans le [dossier des solutions](solutions/). Gardez à l'esprit qu'il n'y a pas de « bonne » réponse, si vous avez réussi à le faire fonctionner, c'est une solution valable ! 
