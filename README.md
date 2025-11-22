# Sudoku-Solver

## Objectif
Le but de ce projet est d'implémenter un générateur pour un jeu populaire : le Sudoku.

Le Sudoku est un jeu de réflexion sous forme de grille inventé en 1979 par Howard Garns. Il s'inspire du carré latin et du célèbre problème des 36 officiers de Leonhard Euler. 

L'objectif du jeu est de compléter la grille avec des chiffres, des lettres ou des symboles distincts, de manière à ce qu'aucun symbole ne soit répété sur une même ligne, colonne ou sous-grille. 

Le principe repose sur le remplissage d'une grille 9x9 avec des chiffres allant de 1 à 9, sans répétition dans une ligne, une colonne ou une sous-grille 3x3.

L'objectif est de résoudre le Sudoku à partir d'une grille partiellement remplie. Si plusieurs solutions sont possibles, elles doivent toutes être affichées.

## Contraintes
  - Le projet a dû être réalisé en MIPS32
  - Le contenu de chaque fonctions ne doit pas dépasser 30 lignes

## Fonctionnement général

Lors de son exécution, votre programme devra :
  
  1. Lire la grille initiale du Sudoku, actuellement définie en dur dans la section .data. 
  1. Afficher cette grille sur le terminal.
  1. Chercher toutes les solutions possibles.
  1. Les afficher dans le terminal

## Algorithme
 Algorithme principal

L'algorithme principal pour résoudre le Sudoku repose sur une approche "force brute" récursive avec rétro-rétropropagation.

Voici une description détaillée de cet algorithme :
### 1. Initialisation :
  - Initialiser la grille initiale du Sudoku en mémoire. 
  - Afficher cette grille sur le terminal. 
### 2. Validation de la grille : 
  - Vérifier que les lignes, colonnes, et toutes les sous-grilles 3x3 respectent les règles du Sudoku. Cette étape utilise les fonctions check_n_row, check_n_column, et check_n_square. 
### 3. Résolution du Sudoku : 
  - Utiliser ce sous-algorithme qui explore toutes les solutions possibles : 
  - Trouver une case vide dans la grille.
  - Essayer chaque chiffre de 1 à 9 dans cette case.
  - Valider la grille après chaque tentative en appelant check_sudoku. 
  - Si la grille reste valide, continuer avec un appel récursif pour résoudre les cases suivantes. 
  - Si aucune valeur ne fonctionne, revenez en arrière (rétro-propagation) et tester les possibilités suivantes.
 ### 4. Affichage des résultats :
  - Afficher toutes les solutions possibles sous le format spécifié précédemment.
 ### 5. Gestion des erreurs :
  - Si aucune solution n'est trouvée pour une grille initiale donnée, affichez un message indiquant que la grille est invalide ou insoluble.
