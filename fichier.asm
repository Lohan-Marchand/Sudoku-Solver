# ===== Section donnees =====
.data
   filename: .asciiz "./sudoku.txt" # Nom du fichier texte
   buffer: .space 1024             # Tampon pour lire les donnees
   grille: .space 1024		  # Espace pour stocker les donnees copies
   error1:  .asciiz "le sudoku original est invalide"
   error2:  .asciiz "le fichier contenant le sudoku est vide, introuvable ou ne contient pas le bon nombre de caractère"
   NewLine: .asciiz "\n"
   space:  .asciiz "-"
# ===== Section code =====
.text
# ----- Main -----

main:
    jal loadFile
    jal transformAsciiValues
    jal displayGrille
    jal check_sudoku
    beq $t9,1,error_grille1     #si $t9 = 1 alors saut vers error_grille
    jal addNewLine
    jal solve_sudoku
    jal exit

# ----- Fonctions -----


# ----- Fonction addNewLine -----
# objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0
addNewLine:
    li      $v0, 11
    li      $a0, 10
    syscall
    jr $ra



# ----- Fonction displayGrille -----
# Affiche la grille.
# Registres utilises : $v0, $a0, $t[0-4]
displayGrille:
    la      $t0, grille
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    li      $t1, 0
    boucle_displayGrille:
        bge     $t1, 81, end_displayGrille     # Si $t1 est plus grand ou egal a 81 alors branchement a end_displayGrille
            add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb      $a0, ($t2)              # load byte at $t2(adress) in $a0
            beq $a0, 0, afficheSpace            #si $a0 est égal à 0 branchement à afficheSpace
            li      $v0, 1                  # code pour l'affichage d'un entier
            syscall
            j pasSpace                      #saut à pasSpace
            afficheSpace:
            li      $v0, 4                  # code pour l'affichage d'un string
            la $a0,space
            syscall
            pasSpace:
            add     $t1, $t1, 1             # $t1 += 1;

            # Apres chaque ligne de 9 elements, ajouter un saut de ligne
            li $t3, 9		# Verification la fin de la ligne
            rem $t4, $t1, $t3	# Reste de la division de l'index par 9
            bnez $t4, boucle_displayGrille	# Si le reste n'est pas 0, ce n'est pas la fin de la ligne
            li $v0, 4		# Afficher un saut de ligne
            la $a0, NewLine	# Charge l'adresse du caractere de nouvelle ligne
            syscall

        j boucle_displayGrille
    end_displayGrille:
        lw      $ra, 0($sp)                 # On recharge la reference
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra


# ----- Fonction transformAsciiValues -----
# Objectif : transforme la grille de ascii a integer
# Registres utilises : $t[0-3]
transformAsciiValues:
    add     $sp, $sp, -4
    sw      $ra, 0($sp)
    la      $t3, grille
    li      $t0, 0
    boucle_transformAsciiValues:
        bge     $t0, 81, end_transformAsciiValues
            add     $t1, $t3, $t0
            lb      $t2, ($t1)
            sub     $t2, $t2, 48
            sb      $t2, ($t1)
            add     $t0, $t0, 1
        j boucle_transformAsciiValues
    end_transformAsciiValues:
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra


# ----- Fonction getModulo -----
# Objectif : Fait le modulo (a mod b)
#   $a0 represente le nombre a (doit etre positif)
#   $a1 represente le nombre b (doit etre positif)
# Resultat dans : $v0
# Registres utilises : $a0
getModulo:
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)
    boucle_getModulo:
        blt     $a0, $a1, end_getModulo
            sub     $a0, $a0, $a1
        j boucle_getModulo
    end_getModulo:
    move    $v0, $a0
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra


#################################################
#               A completer !                   #
#                                               #
# Nom et prenom binome 1 :Marchand Lohan        #
# Nom et prenom binome 2 :Dovbysh  Oleksii      #


#----------fonction loadFile------------
# objectif: Ouvre le fichier dans le mode spécifié par ses arguments et enregistre le descripteur du fichier dans un registre.
# Registres utilises : $a0, $a1, $v0, $t0
loadFile:
	li $v0, 13               # Appel systeme : open
	la $a0, filename		# Nom du fichier
	li $a1, 0		# MOde lecture
	syscall
	move $t0, $v0		# Sauvgarder le descripteur de fichier dans $t0
	j parseValues           # saut à parseValues


#----------fonction parseValues------------
# objectif: lire le fichier dans un tampon puis le copier dans grille
# Registres utilises : $a0, $a1, $a2, $v0, $t0, $t1, $t2, $t3, $t4, $t5
parseValues:
	# Lire le fichier dans le tampon
	li $v0, 14		# Appel systeme : read
	move $a0, $t0		# Descripteur de fichier
	la $a1, buffer 		# Tampon pour la lecture
	li $a2, 1024		# Taille maximale de lecture
	syscall
	move $t1, $v0		# Nombre de bytes lus (si necessaire)
	bne $t1, 82,error_file #si le nombre de bytes lu est différent de 82 alors branchement à error_file
	# Copier les donnees du tampon vers grille
	la $t2, buffer		# Debut du tampon
	la $t3, grille		# Debut de l'espace pour la copie
	li $t4, 0		# Compteur de bytes (por la boucle)

copy_loop:
	lb $t5, 0($t2)		# Lire un byte du buffer
	sb $t5, 0($t3)		# L'ecrire dans grille
	addi $t2, $t2, 1		# Incrementer l'adresse du buffer
	addi $t3, $t3, 1		# Incrementer l'adresse de grille
	addi $t4, $t4, 1		# Incrementer le compteur
	bne $t4, $t1, copy_loop	# Si tous les bytes ne sont pas copies, repeter
	j closeFile


#----------fonction closeFile------------
# objectif: fermer le descripteur de fichier
# Registres utilises : $a0, $v0, $t0
closeFile:
	li $v0, 16		# Appel systeme : close
	move $a0, $t0		# Descripteur de fichier
	syscall

	jr $ra



# -----Fonction check_n_column-----
# Pour chaque valeur pouvant être placé dans une case du sudoku,
# on parcours la colonne en comptant son nombre d'apparition
# si elle apparait plus d'une fois alors le sudoku est invalidé.
# Registres utilises : $a0, $t[0,1,2,6,7]
check_n_column:
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    li    $t7,0                 # mettre $t7 à 0
    end_check_n_column:
         add   $t7,$t7,1        #ajouter 1 à $t7 ($t7 vas de 1 à 9 et pour verifier chaque valeurs possible des cases)
         li   $t6,0             #mettre $t6 à 0 (compte le nombre d'apparition de la valeur de $t7)
    boucle_num_column:
        bge    $t7, 10,end_boucle_num_column #si $t7 est plus grand ou egal à 10 branchement à end_boucle_num_column
            li      $t1, 0                   #mettre $t1 à 0 ($t1 permet de se placer sur une case spécifique)
            boucle_check_n_column:
                bge     $t1, 81, end_check_n_column     # Si $t1 est plus grand ou egal a 81 alors branchement a end_check_n_column
                     add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
                     lb      $a0, ($t2)              # charger les bytes à l'adresse de $t2 dans $a0
                     bne $a0,$t7,not_it_column       #si $a0 est different de $t7 branchement à not_it_column (sinon faire les instructions suivantes)
                     add $t6,$t6,1                   #ajouter 1 à $t6
                     bge $t6,2,invalid_sudoku        #si $t6 plus grand ou egal à 2 (il y a plus d'une fois la valeur dans la colonne) branchement à invalid_sudoku
                     not_it_column:
                     add     $t1, $t1, 9             # ajouter 9 à $t1;
                j boucle_check_n_column              #sauter au début de la boucle
    end_boucle_num_column:
        lw      $ra, 0($sp)                 # On recharge la reference
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra


# -----Fonction check_n_row-----
# Pour chaque valeur pouvant être placé dans une case du sudoku,
# on parcours la ligne en comptant son nombre d'apparition
# si elle apparait plus d'une fois alors le sudoku est invalidé.
# Registres utilises : $a0, $t[0,1,2,6,7]
check_n_row:
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    li    $t7,0                 #mettre $t7 à 0
    end_check_n_row:
         add   $t7,$t7,1        #ajouter 1 à $t7 ($t7 vas de 1 à 9 et pour verifier chaque valeurs possible des cases)
         li   $t6,0             #mettre $t6 à 0 (compte le nombre d'apparition de la valeur de $t7)
    boucle_num_row:
        bge    $t7, 10,end_boucle_num_row    #si $t7 est plus grand ou egal à 10 branchement à end_boucle_num_row
            li      $t1, 0                   #mettre $t1 à 0 ($t1 permet de se placer sur une case spécifique)
            boucle_check_n_row:
                bge     $t1, 9, end_check_n_row     # Si $t1 est plus grand ou egal à 9 alors branchement a end_check_n_row
                     add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
                     lb      $a0, ($t2)              # charger les bytes à l'adresse de $t2 dans $a0
                     bne $a0,$t7,not_it_row          #si $a0 est different de $t7 branchement à not_it_row (sinon faire les instructions suivantes)
                     add $t6,$t6,1                   #ajouter 1 à $t6
                     bge $t6,2,invalid_sudoku        #si $t6 plus grand ou egal à 2 (il y a plus d'une fois la valeur dans la ligne) branchement à invalid_sudoku
                     not_it_row:
                     add     $t1, $t1, 1             # ajouter 1 à $t1
                j boucle_check_n_row                 #sauter au début de la boucle
    end_boucle_num_row:
        lw      $ra, 0($sp)                 # On recharge la reference
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra


# -----Fonction check_n_square-----
# Pour chaque valeur pouvant être placé dans une case du sudoku,
# on parcours le carré de 9 cases en comptant son nombre d'apparition
# si elle apparait plus d'une fois alors le sudoku est invalidé.
# Registres utilises : $a0, $t[0,1,2,5,6,7]
check_n_square:
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    li    $t7,0                 #mettre $t7 à 0
    end_check_n_square:
         add   $t7,$t7,1        #ajouter 1 à $t7 ($t7 vas de 1 à 9 et pour verifier chaque valeurs possible des cases)
         li   $t6,0             #mettre $t6 à 0 (compte le nombre d'apparition de la valeur de $t7)
    boucle_num_square:
        bge    $t7, 10,end_boucle_num_square    #si $t7 est plus grand ou egal à 10 branchement à end_boucle_num_square
            li      $t1, 0                      #mettre $t1 à 0 ($t1 permet de se placer sur une case spécifique)
            li      $t5, 0                      #mettre $t5 à 0 ($t5 permet se repérer dans les colonnes du carré)
            boucle_check_n_square:
                bge     $t1, 21, end_check_n_square     # Si $t1 est plus grand ou egal a 21 alors branchement a end_check_n_square
                     add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
                     lb      $a0, ($t2)              # charger les bytes à l'adresse de $t2 dans $a0
                     bne $a0,$t7,not_it_square       #si $a0 est different de $t7 branchement à not_it_square (sinon faire les instructions suivantes)
                     add $t6,$t6,1                   #ajouter 1 à $t6
                     bge $t6,2,invalid_sudoku        #si $t6 plus grand ou egal à 2 (il y a plus d'une fois la valeur dans le carré) branchement à invalid_sudoku
                     not_it_square:
                     add     $t1, $t1, 1             #ajouter 1 à $t1
                     add     $t5, $t5, 1             #ajouter 1 à $t5
                     ble  $t5,2,square_same_row      #si $t5 est plus petit ou egal à 2 branchement à square_same_row (sinon faire les instructions suivantes)
                     li $t5,0                        #mettre $t5 à 0
                     add $t1,$t1,6                   #ajouter 6 à $t1
                     square_same_row:
                j boucle_check_n_square              #sauter au début de la boucle
    end_boucle_num_square:
        lw      $ra, 0($sp)                 # On recharge la reference
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra


# -----Fonction check_columns-----
#verifier chaque colonnes (en lançant check_n_column pour chaque colonnes)
# Registres utilises : $t[0,4]
check_columns:
    la  $t0, grille             #charger la grille dans $t0
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
     li $t4,0                   #mettre $t4 à 0
     boucle_check_columns:
     bge $t4,9,end_boucle_check_columns   #si $t4 est plus grand ou egal à 9 branchement à end_boucle_check_columns
     jal check_n_column                   # "appeler" la fonction check_n_column
     add $t0,$t0,1                        #ajouter 1 à $t0 (première valeur de la colonne)
     add $t4,$t4,1                        #ajouter 1 à $t4 (numéro de la colonne)
     j boucle_check_columns               #sauter au début de la boucle
     end_boucle_check_columns:
        lw      $ra, 0($sp)                 # On recharge la reference
        add     $sp, $sp, 4                 # du dernier jump
        jr $ra

# -----Fonction check_rows-----
#verifier chaque lignes (en lançant check_n_row pour chaque lignes)
# Registres utilises : $t[0,4]
check_rows:
    la  $t0, grille             #charger la grille dans $t0
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
     li $t4,0                   #mettre $t4 à 0
     boucle_check_rows:
     bge $t4,9,end_boucle_check_rows   #si $t4 est plus grand ou egal à 9 branchement à end_boucle_check_rows
     jal check_n_row                   # "appeler" la fonction check_n_row
     add $t0,$t0,9                        #ajouter 9 à $t0 (première valeur de la ligne)
     add $t4,$t4,1                        #ajouter 1 à $t4 (numéro de la ligne)
     j boucle_check_rows                  #sauter au début de la boucle
     end_boucle_check_rows:
        lw      $ra, 0($sp)                 # On recharge la reference
        add     $sp, $sp, 4                 # du dernier jump
        jr $ra

# -----Fonction check_squares-----
#verifier chaque carrés (en lançant check_n_square pour chaque carrés)
# Registres utilises : $t[0,4,8]
check_squares:
    la  $t0, grille             #charger la grille dans $t0
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
     li $t4,0                   #mettre $t4 à 0
     li $t8,0                   #mettre $t8 à 0 (numéro du carrée de la ligne)
     boucle_check_squares:
     bge $t4,9,end_boucle_check_squares   #si $t4 est plus grand ou egal à 9 branchement à end_boucle_check_squares
     jal check_n_square                   # "appeler" la fonction check_n_square
     add $t0,$t0,3                        #ajouter 3 à $t0 (première valeur du carré)
     add $t4,$t4,1                        #ajouter 1 à $t4 (numéro du carré)
     add $t8,$t8,1                        #ajouter 1 à $t8
     bne $t8,3,same_row2                  #si $t8 différent de 3 branchement à same_row2 (sinon faire les instructions suivantes
     li $t8,0                             #mettre $t8 à 0
     add $t0,$t0,18                       #ajouter 18 à $t0
     same_row2:
     j boucle_check_squares               #sauter au début de la boucle
     end_boucle_check_squares:
        lw      $ra, 0($sp)                 # On recharge la reference
        add     $sp, $sp, 4                 # du dernier jump
        jr $ra

# -----Fonction check_sudoku-----
#verifie les colonnes, les lignes et les carrés de tout le sudoku
# Registres utilises : $t[0,9]
check_sudoku:
        la  $t9,0                  #mettre $t9 à 0 (booléen de validiter du sudoku)
        la  $t0, grille            #enregistrer la grille dans $t0
        add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
        sw      $ra, 0($sp)
    jal check_columns              #"appeler" la fonction check_columns
    jal check_rows                 #"appeler" la fonction check_rows
    jal check_squares              #"appeler" la fonction check_squares
        lw      $ra, 0($sp)                 # On recharge la reference
        add     $sp, $sp, 4                 # du dernier jump
        jr $ra
#
# Fonction solve_sudoku
# Registres utilises : $sp, $a0, $t[0,1,3]
solve_sudoku:
    la $t0, -1
    add     $sp, $sp, -4        # Sauvegarde la valeur -1 dans la pile
       sw      $t0, 0($sp)
    add     $sp, $sp, -4        # Sauvegarde la valeur -1 dans la pile
       sw      $t0, 0($sp)
    la $t3, -1                  # Mettre $t3 à -1
    parcours_grille_solve:
    add $t3,$t3,1               # Ajouter 1 à $t3
    ble $t3,80,pas_au_bout      # Si $t3 est plus petit ou égal à 80 branchement à pas_au_bout (car pas au bout du sudoku) sinon, faire les instructions suivantes)

       jal addNewLine           # saut à addNewLine
       jal displayGrille        # saut à displayGrille pour afficher le résultat
       la $t1, grille           # $t1 pointe vers la première valeur de la grille
       lw      $t3, 0($sp)                 # charger la première valeur de la pile dans $t3
       add     $sp, $sp, 4                 # supprimer la première valeur de la pile
       add $t1,$t1,$t3                     # ajouter $t3 à $t1
       la $a0,0                            # mettre $a0 à 0
       sb $a0,($t1)                        # enregistrer la valeur contenue dans $a0 dans la zone pointer par $t1
       lw      $t3, 0($sp)                 # charger la première valeur de la pile dans $t3
       beq $t3,-1,exit                     # si $t3 = -1 alors branchement à exit, sinon faire l'instructions suivantes
       j val_test                          # saut à val_test
    pas_au_bout:
       la $t1, grille                      # $t1 pointe vers la première valeur de la grille
       add $t1,$t1,$t3                     # ajouter $t3 à $t1
       lb $a0,($t1)                        # charger dans $a0 la valeur pointé par $t1
       bne $a0,0,parcours_grille_solve     # si $a0 est différent de 0 alors branchement à parcours_grille_solve
       add     $sp, $sp, -4                # Sauvegarde la coordonées du zéro dans la pile
          sw      $t3, 0($sp)              #
       j val_test                          # saut à val_test

# Autres fonctions que nous avons ajoute :

#---------Fonction val_test----------
#test les valeurs de 1 à 9 pour remplacer les 0
# Registres utilises : $sp, $a0, $t[0,3,9]
val_test:
       la $t1, grille                      # $t1 pointe vers la première valeur de la grille
       add $t1,$t1,$t3                     # ajouter $t3 à $t1
       lb $a0,($t1)                        # charger la valeur pointée par $t1 dans $a0
   bge $a0,9,toutes_valeurs_faites         # si $a0 est plus grand ou égal à 9 alors brachement à toutes_valeurs_faites sinon faire les instructions suivantes
       add $a0,$a0,1                       # ajouter 1 à $a0
       la $t1, grille                      # $t1 pointe vers la première valeur de la grille
       add $t1,$t1,$t3                     # ajouter $t3 à $t1
       sb $a0,($t1)                        # enregistrer la valeur contenue dans $a0 dans la zone pointer par $t1
       jal check_sudoku                    # saut à check_sudoku
       beq $t9,1,val_test                  # si $t9 est égal à 1 alors branchement à val_test
       j parcours_grille_solve             # saut à parcours_grille_solve
   toutes_valeurs_faites:
       la $a0,0                            # mettre $a0 à 0
       la $t1, grille                      # $t1 pointe vers la première valeur de la grille
       add $t1,$t1,$t3                     # ajouter $t3 à $t1
       sb $a0,($t1)                        # charger la valeur pointée par $t1 dans $a0
       add     $sp, $sp, 4                 # supprimer la première valeur de la pile
       lw      $t3, 0($sp)                 # charger la première valeur de la pile dans $t3
       beq $t3,-1,exit                     # si $t3 = -1 alors branchement à exit
       j val_test                          # sinon saut à val_test

# ---------Fonction invalid_sudoku-----------
# objectif: renvoyé une valeur si le sudoku est invalide
# Registres utilises : $t9
invalid_sudoku:
       li   $t9,1                           #mettre le booléen $t9 à 1
        lw      $ra, 0($sp)                 # On recharge la reference
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra

#----------fonction error_grille------------
# objectif: afficher quand la grille originale est invalide et arrêter le programme
# Registres utilises : $a0, $v0
error_grille1:
     jal addNewLine                       #aller à la ligne
     la $a0,error1     #charger le string error dans $a0
     li $v0,4         #selectionner le code syscall 4 pour écrire la chaine de character de $a0
     syscall
     j exit           #sauter à l'arrêt du programme

#----------fonction error_file------------
# objectif: afficher quand le fichier est innaccessible ou pas correcte et arrêter le programme
# Registres utilises : $a0, $v0
error_file:
     jal addNewLine                       #aller à la ligne
     la $a0,error2     #charger le string error dans $a0
     li $v0,4         #selectionner le code syscall 4 pour écrire la chaine de caractère de $a0
     syscall
     j exit           #sauter à l'arrêt du programme

#                                               #
#################################################





exit:
    li $v0, 10       #code d'appelle système fin de programme
    syscall
