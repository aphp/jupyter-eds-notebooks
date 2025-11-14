# Base EDS Notebook

## Introduction

### Description

Extension de l'image JupyterLab [base-notebook](https://github.com/jupyter/docker-stacks/tree/main/images/base-notebook) fournissant un environnement de travail basique.

### Fonctionnement

L'image se base sur l'image `base-notebook` officielle, et l'étends de la même manière que les autres images officielles plus avancées, afin de conserver une compatibilité importante avec les distributions de JupyterLab.

Cette image est basée sur l'OS `Ubuntu 24.04` en architecture `x86_64`.

Les librairies à ajouter sont configurables dans un fichier copié au moment du build, et l'environnement par défaut est ensuite gelé pour éviter toute dégradation involontaire par les utilisateurs. 

À cet effet, les mesures suivantes ont été appliquées : 

- Les droits du dossier contenant l'environnement `conda` par défaut (`base`) ont été placés en `read-only`
- La variable d'environnement `PYTHONNOUSERSITE` a été placée à `1` afin d'interdire l'utilisation du repository Python `user local`, situé dans `/home/jovyan/.local`, ce qui permettrait de contourner la restriction placée sur l'environnement `conda` par défaut.

## Exploitation

### Configuration

Le dossier `config` contient deux fichiers :

- `.condarc`, contenant la configuration par défaut de la distribution `conda` déployée dans l'image
- `conda-base-env-update.yaml`, qui contient les librairies installées dans l'environnement `conda` par défaut au runtime

#### Modifier la configuration de conda

Modifier le fichier `config/.condarc` en suivant [la documentation officielle de conda](https://conda.io/projects/conda/en/latest/user-guide/configuration/use-condarc.html), puis rebuilder l'image.

#### Ajouter ou retirer une librairie dans l'environnement conda par défaut

Il suffit de manipuler le fichier `config/conda-base-env-update.yaml` pour [y ajouter ou retirer les librairies désirées](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#creating-an-environment-file-manually), puis de rebuilder l'image.

**Important** : Ne pas ajouter au fichier yaml `config/conda-base-env-update.yaml` les clés `name`, `channel`, ou tout autre clés à la racine de la structure ; cela aurait pour effet de créer un nouvel environnement `conda`, plutôt que d'enrichir l'existant contenant tout ce dont JupyterLab à besoin, ce qui rendrait l'image non-fonctionnelle.

## CI/DEVOPS

### Automatique

À chaque modification sur la branche `main`, une image de dev (avec le suffixe `-dev`) sera automatiquement buildée et poussée dans le repository Harbor interne `public/jupyter`. Si ce processus n'échoue pas, il sera ensuite possible de déclencher manuellement le job CI de build & push de l'image de prod (sans suffixe), dans le même repository Harbor.

### Manuel

#### Builder l'image

_Note_ : Ceci est un exemple avec le repository interne `public`. Vous devrez vous logger à ce repository et disposer de droits suffisants si vous souhaitez pusher l'image buildée sur ce repo.

Lancer depuis la racine de ce repository la commande suivante : 

```sh
docker build -t harbor.eds.aphp.fr/public/jupyter/base-eds-notebook:x86_64-ubuntu-24.04 .
```

#### Pusher l'image buildée sur un repository

_Note_ : Ceci est un exemple avec le repository interne `public`. Vous devrez vous logger à ce repository et disposer de droits suffisants si vous souhaitez pusher l'image buildée sur ce repo.

Une fois l'image buildée avec succès, lancer la commande suivante :

```sh
docker push harbor.eds.aphp.fr/public/jupyter/base-eds-notebook:x86_64-ubuntu-24.04
```