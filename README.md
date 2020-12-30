# Foobartory

## Avant-propos

-   Utilise le langage de ton choix
-   Un output console est suffisant
-   Envoies ta réponse sous la forme d'un repo Github que nous pouvons `git clone` avec un readme expliquant comment le faire fonctionner
-   Le but de ce projet est de comprendre comment tu codes et comment tu appréhendes une question ouverte.
-   Le projet est pensé pour durer environ 3 heures. Nous sommes conscients que tu as d'autres obligations, et nous ne te demandons donc pas la réponse optimale.
-   N'hésite pas à nous contacter si tu as des questions.

## Enoncé

Le but est de coder une chaîne de production automatique de `foobar`.

On dispose au départ de 2 robots, qui sont chacun capables d'effectuer plusieurs actions :

-   Se déplacer pour changer d'activité : occupe le robot pendant 5 secondes.
-   Miner du `foo` : occupe le robot pendant 1 seconde.
-   Miner du `bar` : occupe le robot pendant un temps aléatoire compris entre 0.5 et 2 secondes.
-   Assembler un `foobar` à partir d'un `foo` et d'un `bar` : occupe le robot pendant 2 secondes. L'opération a 60% de chances de succès ; en cas d'échec le `bar` peut être réutilisé, le `foo` est perdu.

Tu as de grands entrepôts, la gestion des stocks n'est pas un problème.
En revanche, la législation impose la traçabilité des pièces ayant servi à fabriquer les `foobars` : chaque `foo` et chaque `bar` doivent avoir un numéro de série unique qu'on doit retrouver sur le `foobar` en sortie d'usine

On souhaite ensuite accélérer la production pour prendre rapidement le contrôle du marché des `foobar`. Les robots peuvent effectuer de nouvelles actions:

-   Vendre des `foobar` : 10s pour vendre de 1 à 5 foobar, on gagne 1€ par foobar vendu
-   Acheter un nouveau robot pour 3€ et 6 `foo`, 0s

Le jeu s'arrête quand on a 30 robots.

Note:
1 seconde du jeu n'a pas besoin d'être une seconde réelle.
Le choix des actvités n'a _pas besoin d'être optimal_ (pas besoin de faire des maths), seulement fonctionnel.
