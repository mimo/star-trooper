

## 12/09/2019

Implémenté l'orientation du personnage, j'ai galéré le temps de me rappeler que la fonction cosinus inversée ne retour pas d'angle de plus de 180.

J'ai eu un bug du a l'absence de type enumeres, pour indexer les animations jai utilisé les chaines : left right up down
Sauf que au moment de 

## 13/09/2019

Mon problème est que trop souvent je peux produire du code trop passant rapidement d'un point à un autre,
rapidement voulant dire en ayant fait la moitié et sans contrôle à la fin.

Quand il y a une erreur, 
Exemple en capture j'avais oublié de mettre un end générant une erreur en attendu en fin de fichier,
étant focalisé sur le point suivant j'ai rapidement mis un end à la fin de la fonction en réalisation.
Je n'ai dans un premier temps que corrigé ce qui empêche le code de se lancer, alors seulement je constate le bug
et me colle une analyse pour trouver la cause de l'origine.

## 22/09/2019

J'ai eu du mal mais j'ai enfin implémenté le déplacement avec les pas latéraux.


Pour le strafe le point visé doit se déplacer de manière identique au joueur. Sauf que quand j'ai commencé à utiliser les fonctions love.mouse.setPosition pour déplacer le curseur love a arrondi les coordonnées du curseur qui n'était plus synchro avec le perso.


Pour qu'elles collent j'ai d'abord restreint les translations à des valeurs entières (la partie entière retournée par la fonction math.modf, le reste est accumulé dans une variable globale).
Le strafe était fonctionnel mais le déplacement était saccadé.


J'ai résolu le problème en gérant moi même les coordonnées de la souris, mais j'ai dû appeler love.mouse.setRelativeMode(true) dans love.load() pour que la souris soit indépendante du bord de la fenêtre qui maintenant capture le curseur Windows.