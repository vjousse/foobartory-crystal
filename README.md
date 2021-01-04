# Foobartory

## Installation

1. [Install Crystal Lang](https://crystal-lang.org/install/)
2. Clone the project `git clone git@github.com:vjousse/foobartory-crystal.git`
3. Change directory `cd foobartory-crystal`
4. Install dependencies `shards install`
5. Build the project `shards build`
6. Enjoy :)

## Usage

To start the project with the default configuration, in the project directory run:

    ./bin/foobartory

## Configuration

If you want to change some configuration, you can tweak the `.env` file with your own values. Here are the provided defaults:

    FB_CHANGING_ACTIVITY_TIME_SEC=5
    FB_MINE_FOO_TIME_SEC=1
    FB_MINE_BAR_MIN_TIME_SEC=0.5
    FB_MINE_BAR_MAX_TIME_SEC=2
    FB_ASSEMBLE_FOO_BAR_TIME_SEC=2
    FB_SELL_FOO_BAR_TIME_SEC=10

You can also override a value directly on the CLI using an environment variable, for example to set the changing time activity to 0 seconds, just start the project this way:

    FB_CHANGING_ACTIVITY_TIME_SEC=0 ./bin/foobartory

You can tweak the log level by changing the `LOG_LEVEL` environment variable, for example:

    FB_CHANGING_ACTIVITY_TIME_SEC=0 LOG_LEVEL=INFO ./bin/foobartory

## Development

For development, [install watchexec](https://github.com/watchexec/watchexec) to watch for file changes. Then, you can run the project like this:

    FB_CHANGING_ACTIVITY_TIME_SEC=5 LOG_LEVEL=INFO ./dev/watch.sh foobartory

It will recompile and run the project after every file change.

## Testing

You need to make sure to install the Crystal dependencies.

1. [Install watchexec](https://github.com/watchexec/watchexec) to watch for file changes
2. Run `./dev/watch-spec.sh`from the project root

## Contributing

1. Fork it (<https://github.com/your-github-user/foobartory/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Problem to solve

# Avant-propos

-   Utilise le langage de ton choix
-   Un output console est suffisant
-   Envoies ta réponse sous la forme d'un repo Github que nous pouvons `git clone` avec un readme expliquant comment le faire fonctionner
-   Le but de ce projet est de comprendre comment tu codes et comment tu appréhendes une question ouverte.
-   Le projet est pensé pour durer environ 3 heures. Nous sommes conscients que tu as d'autres obligations, et nous ne te demandons donc pas la réponse optimale.
-   N'hésite pas à nous contacter si tu as des questions.

# Enoncé

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
