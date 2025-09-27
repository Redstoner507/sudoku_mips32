
# Nom et prenom binome 1 : Stoll-Geyer Yann                     
# Nom et prenom binome 2 : Courseaux Lucas                    

# ===== Section donnees =====  
.data
    fichier: .asciiz "grille.txt"
    #grille: .asciiz "415638972362479185789215364926341758138756429574982631257164893843597216691823547" #47
    grille: .asciiz "120056789690078215587291463352184697416937528978625341831542976269713854745869132"
    #grille: .asciiz "000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    column_error: .asciiz "Erreur: La colonne est invalide !\n Erreur à l'index: "
    row_error: .asciiz "Erreur: La ligne est invalide !\n Erreur à l'index: "
    square_error: .asciiz "Erreur: Le carre est invalide !\n Erreur à l'index: "
    validation: .asciiz "La grille est valide."
    tiret: .asciiz "-"
    espace: .asciiz " "
    colonne: .asciiz "|| "
    ligne: .asciiz "======================="


# ===== Section code =====  
.text
# ----- Main ----- 

main:
    #jal parseValues #Charge les valeurs du fichier
    jal transformAsciiValues #Convertie les char en int
    la $s0, grille #Charge l'adresse de la grille en $a0
    jal displayGrille
    jal addNewLine
    jal solve_sudoku
    #jal check_sudoku
    jal addNewLine
    #jal displayGrille
    #jal displaySudoku
    j exit

# ----- Fonctions ----- 

# ouvrir un fichier passé en argument : appel systeme 13 
#	$a0 nom du fichier
#	$a1 (= 0 lecture, = 1 ecriture)
# Registres utilises : $v0, $a2
loadFile:
	li $v0, 13
	li $a1, 0
	syscall
	jr $ra

# Fermer le fichier : appel systeme 16
# $a0 descripteur de fichier  ouvert
# Registres utilises : $v0
closeFile:
    li $v0, 16
    syscall
    jr  $ra

# ----- Fonction parseValues -----
parseValues:
    # objectif : lit un fichier et stocke la grille lu.
    # Registres utilises : $v0, $a[0-2], $t0
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)

    la $a0, fichier # Charge le nom du fichier qui contient la gille
    jal loadFile
    move $t0, $v0 # Stocker le descripteur de fichier dans $t0

    li $v0, 14  # Syscall 14 : lire un fichier
    move $a0, $t0 # Charger le descripteur 
    la $a1, grille
    li $a2, 324
    syscall
    jal closeFile
    lw      $ra, 0($sp)                 # On recharge la reference 
    add     $sp, $sp, 4 
    jr $ra #saut de retour


# ----- Fonction zeroToSpace -----
zeroToSpace:
    li		$v0, 4			#code pour afficher un tiret à la place du 0
    la		$a0, tiret
    syscall
 	j endZeroToSpace		#retour dans boucle_displayGrille en ayant passé l'affichage de l'entier

# ----- Fonction addNewLine -----  
# objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0
addNewLine:
    li      $v0, 11 #appel système 11: afficher un caractère
    li      $a0, 10 # Valeur à afficher (\n)
    syscall
    jr $ra #saut de retour
#
#
# ----- Fonction add_column -----
# objectif : Affiche le separateur de colonnes
# Registres utilises : $v0, $a[0-1], $t0
add_column:
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    move    $a0, $t0
    li      $a1, 9
    jal getModulo
    beq $v0, 8, end_add_column
    la      $a0, colonne   #adresse de la chaine a afficher
    li      $v0, 4         #appel systeme 4: afficher une chaine de caractere
    syscall
    end_add_column:
    	lw      $ra, 0($sp)                 # On recharge la reference 
	add     $sp, $sp, 4                 # du dernier jump
    	jr $ra
#
#
# ----- Fonction add_row -----
# objectif : fait un retour a la ligne et affiche le separateur de ligne
# Registres utilises : $v0, $a0, $t0
add_row:
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    li      $v0, 1          	# code de retour pour empecher une boucle infinie
    beq $t0, 80, end_add_row
    la      $a0, ligne   	#adresse de la chaine a afficher
    li      $v0, 4          #appel systeme 4: afficher une chaine de caractere
    syscall
    jal addNewLine
    end_add_row:
    	lw      $ra, 0($sp)                 # On recharge la reference 
    	add     $sp, $sp, 4                 # du dernier jump
    	jr $ra
#
#
# ----- Fonction displayGrille -----   
# Affiche la grille.
# Registres utilises : $v0, $a0, $t[0-2]
displayGrille:
	#move $t0 $s0 
    la      $t0, grille
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    li      $t1, 0
    boucle_displayGrille:
        bge     $t1, 81, end_displayGrille     # Si $t1 est plus grand ou egal a 81 alors branchement a end_displayGrille
            add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb      $a0, ($t2)              # load byte at $t2(adress) in $a0
            beqz	$a0, zeroToSpace		#si $a0 == 0, on saute à zeroToSpace (on passe l'affichage de l'entier)          
            li      $v0, 1                  # code pour l'affichage d'un entier
            syscall
            endZeroToSpace:
            add     $t1, $t1, 1             # $t1 += 1;
        j boucle_displayGrille
    end_displayGrille:
        lw      $ra, 0($sp)                 # On recharge la reference 
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra

# ----- Fonction displaySudoku -----   
# Affiche la grille de manière matricielle.
# Registres utilises : $v0, $a[0-1], $t[0-1]
displaySudoku:  
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    li      $t0, 0
    jal addNewLine
    boucle_displaySudoku:
        bge     $t0, 81, end_displaySudoku    # Si $t0 est plus grand ou egal a 81 alors branchement a end_displayGrille
            # Afficher l'entier
            add     $t1, $s0, $t0           # $s0 + $t0 -> $t1 ($s0 l'adresse du tableau et $t0 la position dans le tableau)
            lb      $a0, ($t1)              # load byte at $t1(adress) in $a0
            li      $v0, 1                  # code pour l'affichage d'un entier
            syscall
            # Afficher un espace
            la      $a0, espace   	#adresse de la chaine a afficher
    	    li      $v0, 4          	#appel systeme 4: afficher une chaine de caractere
    	    syscall
    	    # Afficher le separateur de colonnes si necessaire
    	    move $a0, $t0 
            li $a1, 3
            jal getModulo
            beq $v0, 2, add_column
            # Sauter une ligne si necessaire
            move $a0, $t0 
            li $a1, 9
            jal getModulo
            beq $v0, 8, addNewLine
            # Afficher le separateur de lignes si necessaire
            move $a0, $t0 
            li $a1, 27
            jal getModulo
            beq $v0, 26, add_row
            # Incrementer $t0
            add     $t0, $t0, 1             # $t0 += 1;
        j boucle_displaySudoku
    end_displaySudoku:
        lw      $ra, 0($sp)                 # On recharge la reference 
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra

# ----- Fonction transformAsciiValues -----   
# Objectif : transforme la grille de ascii a integer
# Registres utilises : $t[0-3]
transformAsciiValues:  
    add     $sp, $sp, -4
    sw      $ra, 0($sp)
    la      $t3, grille #Charge l'adressede la grille dans $t3
    li      $t0, 0 #Charge la valeur 0 dans $t0
    boucle_transformAsciiValues:
        bge     $t0, 81, end_transformAsciiValues #Tant que $t0 >= 81 saut à end
            add     $t1, $t3, $t0 #
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
# Registres utilises : $a0 et $a1
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
                                               
# ----- Fonction check_n_column -----           #
# Objectif : Verifier que la colonne n est correcte
#	$a0 represente la colonne de la grille (compris entre 0 et 8)
# Resultat dans : $v0
# Registres utilises : $a0, $v0, $t0-7
check_n_column:
    add     $sp, $sp, -4 	# sauvegarde la reference du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    # Calcul de l'index de depart de la colonne: index de depart = n
    move    $t0, $a0		# $t0 = $a0 = n
    # Calcul de l'index de fin de la colonne: index de fin = index de depart + 9*8
    li      $t1, 9	        # $t1 = 9
    li      $t2, 8          # $t2 = 8
    mult    $t1, $t2		# $t1 = 9*8
    mflo    $t1    		# Charge le resultat du produit dans $t1
    add     $t1, $t1, $t0   # $t1 = index de depart + 9*8
    # Initialiser le masque binaire et le bit de decalage
    li      $t2, 0		    # Initialise le masque a  0
    li      $t3, 1          # Initialise 1 pour le decalage: 00000001
    # Initialiser la valeur de retour
    li      $v0, 1          # Par defaut $v0 = 1 (true)
    boucle_check_n_column:
    	bgt     $t0, $t1, end_check_n_column    # Si $t0 > $t1 : fin
    	add     $t4, $s0, $t0                   # Sinon: $t4 = $s0 + $t0
    	lb      $t5, ($t4)                      # Chiffre a  traiter: $t5 <- Mem[$t4]
    	# Sauter si on trouve un zero
    	beq	$t5, 0, skip_check_n_column
        # Creer le bit correspondant au chiffre             
        sllv    $t6, $t3, $t5                   # Decale 1 ($t3) a  gauche de $t5 positions -> Si $t5 = 5: $t6 <- 00010000 
        # Ajouter le bit au masque
        or      $t7, $t2, $t6                   # Met le masque $t2 a  jour dans $t7 pour pouvoir comparer $t7 et $t2 (la version pas a  jour)                  
        beq     $t2, $t7, error_check_n_column  # Sort de la boucle si $t2 = $t7 mis a  jour <=> le meme bit a deja  ete active <=> la ligne compte 2 fois le meme chiffre
        or      $t2, $t2, $t6                   # Met a  jour le masque avec le bit active: $t2 <- $t2 || $t6 (Ex avec $t6 = 9: 00000000 || 100000000 = 100000000)
        skip_check_n_column:
        # Incrementer l'index de recherche
    	addi    $t0, $t0, 9                     # $t0 = $t0 + 9
    	j boucle_check_n_column                 # Relancer la boucle
    end_check_n_column:
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra
    error_check_n_column:
    #Retourner une erreur / l'indicateur que la ligne est fausse
    #la      $a0, column_error   #adresse de la chaa®ne a  afficher
    #li      $v0, 4              #appel systeme 4: afficher une chaa®ne de caractere
    #syscall
    #move    $a0, $t0		# Afficher l'index d'ou provient l'erreur
    #li      $v0, 1          	# code pour l'affichage d'un entier
    #syscall
    li      $v0, 0              # Valeur de retour = 0 (false)
    j end_check_n_column
#						#
#						#
# ----- Fonction check_n_row -----              #
# Objectif : Verifier que la ligne n est correcte
#	$a0 represente la ligne de la grille (compris entre 0 et 8)
# Resultat dans : $v0
# Registres utilises : $a0, $v0, $t0-7
check_n_row:
    add     $sp, $sp, -4 	# sauvegarde la reference du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    # Calcul de l'index de depart de la ligne: index de depart = 9*n
    li      $t0, 9		    # $t0 = 9
    mult    $t0, $a0		# $t0 *= n
    mflo    $t0			# Charge le resultat du produit dans $t0
    # Calcul de l'index de fin de la ligne: index de fin = index de depart + 9
    addi    $t1, $t0, 8		# $t1 = $t0 + 8
    # Initialiser le masque binaire et le bit de decalage
    li      $t2, 0		    # Initialise le masque a  0
    li      $t3, 1          # Initialise 1 pour le decalage: 00000001
    # Initialiser la valeur de retour
    li      $v0, 1          # Par defaut $v0 = 1 (true)
    boucle_check_n_row:
    	bgt     $t0, $t1, end_check_n_row   # Si $t0 > $t1 : fin
    	add     $t4, $s0, $t0               # Sinon: $t4 = $s0 + $t0
    	lb      $t5, ($t4)                  # Chiffre a  traiter: $t5 <- Mem[$t4]
    	# Sauter si on trouve un zero
    	beq	$t5, 0, skip_check_n_row
        # Creer le bit correspondant au chiffre
        sllv    $t6, $t3, $t5               # Decale 1 ($t3) a  gauche de $t5 positions -> Si $t5 = 5: $t6 <- 00010000
        # Ajouter le bit au masque
        or      $t7, $t2, $t6               # Met le masque $t2 a  jour dans $t7 pour pouvoir comparer $t7 et $t2 (la version pas a  jour)                  
        beq     $t2, $t7, error_check_n_row # Sort de la boucle si $t2 = $t7 mis a  jour <=> le meme bit a deja ete active <=> la ligne compte 2 fois le meme chiffre
        or      $t2, $t2, $t6               # Met a jour le masque avec le bit active: $t2 <- $t2 || $t6 (Ex avec $t6 = 9: 00000000 || 100000000 = 100000000)
        skip_check_n_row:
        # Incrementer l'index de recherche
    	addi    $t0, $t0, 1                 # $t0 = $t0 + 1
    	j boucle_check_n_row                # Relancer la boucle
    end_check_n_row:
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra
    error_check_n_row:
    #Retourner une erreur / l'indicateur que la ligne est fausse
    #la      $a0, row_error   # adresse de la chaine a  afficher
    #li      $v0, 4           # appel systeme 4: afficher une chaine de caractere
    #syscall
    #move    $a0, $t0		# Afficher l'index d'ou provient l'erreur
    #li      $v0, 1          	# code pour l'affichage d'un entier
    #syscall
    li      $v0, 0           # Valeur de retour = 0 (false)
    j end_check_n_row
#						#
#						#
# ----- Fonction check_n_square -----           #
# Objectif : Verifier que le carre n est correct
#	$a0 represente le carre de la grille (compris entre 0 et 8)
# Resultat dans : $v0
# Registres utilises : $a0, $v0, $t0-8
check_n_square:
    add     $sp, $sp, -4 	# sauvegarde la reference du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    # Calcul de l'index de depart de la ligne: index de depart = 3*(n%3) + 27*(n/3)
    move    $t0, $a0        # $t0 = n
    li      $a1, 3          # $a1 = 3
    jal getModulo           # $v0 = n%3
    move    $t1, $v0        # $t1 = n%3
    mult    $t1, $a1        # $t1 = 3*(n%3)
    mflo    $t1		    # Charge le resultat du produit dans $t1
    li      $t2, 27         # $t2 = 27
    div     $t0, $a1        # $t0 = n/3
    mflo    $t0             # Charge le resultat du produit dans $t0
    mult    $t0, $t2        # $t0 = (n/3)*27
    mflo    $t0		    # Charge le resultat du produit dans $t0
    add     $t0, $t0, $t1   # $t0 = (n/3)*27 + 3*(n%3)
    # Calcul de l'index de fin de la ligne: index de fin = index de depart + 20
    addi    $t1, $t0, 20		# $t1 = $t0 + 20
    # Initialiser le masque binaire et le bit de decalage
    li      $t2, 0		    # Initialise le masque a  0
    li      $t3, 1          # Initialise 1 pour le decalage: 00000001
    # Initialiser la valeur de retour
    li      $v0, 1          # Par defaut $v0 = 1 (true)
    # Initialiser le compteur
    li	    $t8, 0	    # $t8 = 0
    boucle_check_n_square:
    	bgt     $t0, $t1, end_check_n_square    # Si $t0 > $t1 : fin
    	add     $t4, $s0, $t0                   # Sinon: $t4 = $s0 + $t0
    	lb      $t5, ($t4)                      # Chiffre a  traiter: $t5 <- Mem[$t4]
    	# Sauter si on trouve un zero
    	beq	$t5, 0, skip_check_n_square
        # Creer le bit correspondant au chiffre
        sllv    $t6, $t3, $t5                   # Decale 1 ($t3) a  gauche de $t5 positions -> Si $t5 = 5: $t6 <- 00010000
        # Ajouter le bit au masque
        or      $t7, $t2, $t6                   # Met le masque $t2 a  jour dans $t7 pour pouvoir comparer $t7 et $t2 (la version pas a  jour)                  
        beq     $t2, $t7, error_check_n_square  # Sort de la boucle si $t2 = $t7 mis a  jour <=> le meme bit a deja  ete active <=> la ligne compte 2 fois le meme chiffre
        or      $t2, $t2, $t6                   # Met a  jour le masque avec le bit active: $t2 <- $t2 || $t6 (Ex avec $t6 = 9: 00000000 || 100000000 = 100000000)
        skip_check_n_square:
        # Incrementer l'index de recherche
        addi	$t8, $t8, 1
        beq	$t8, 3, next_line
        addi    $t0, $t0, 1                     # $t0 = $t0 + 1
        j boucle_check_n_square         # Relancer la boucle
   next_line:
   	li 	$t8, 0			# $t8 = 0
       	addi    $t0, $t0, 7		# $t0 = $t0 + 7
    	j boucle_check_n_square         # Relancer la boucle
    end_check_n_square:
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra
    error_check_n_square:
    #Retourner une erreur / l'indicateur que la ligne est fausse
    #la      $a0, square_error   #adresse de la chaa®ne a  afficher
    #li      $v0, 4              #appel systeme 4: afficher une chaa®ne de caractere
    #syscall
    #move    $a0, $t0		# Afficher l'index d'ou provient l'erreur
    #li      $v0, 1          	# code pour l'affichage d'un entier
    #syscall
    li      $v0, 0              # Valeur de retour = 0 (false)
    j end_check_n_square
#                                               #
#                                               #
# ----- Fonction check_columns -----            #
# Objectif : Verifier la validite toutes les colonnes de la grille de sudoku
# Resultat dans : $v0
# Registres utilises : $a0, $t9
check_columns:
    add     $sp, $sp, -4 	# sauvegarde la reference du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    li      $t9, 0		    # $t9 <- 0
    # Initialiser la valeur de retour
    li      $v0, 1          # Par defaut $v0 = 1 (true)
    boucle_check_columns:
   	bge     $t9, 9, end_check_columns	        # Si $t9 < 9:
   	move      $a0, $t9			                # Affectation du registre d'argument a  la ligne que l'on souhaite verifier: $a0 <- $t9
    	jal check_n_column			            # Appel de la fonction check_n_rows
    	beq     $v0, $0, end_check_columns	    # Si la valeur de retour != 0:    (Sinon Fin)
        addi    $t9, $t9, 1			            # $t9 <- $t9 + 1
    	j boucle_check_columns			        # relancer la boucle
    end_check_columns:
    lw      $ra, 0($sp)		# On recharge la reference 
    add     $sp, $sp, 4		# du dernier jump
    jr $ra
#                                               #
#                                               #
# ----- Fonction check_rows -----               #
# Objectif : Verifier la validite de toutes les lignes de la grille de sudoku
# Resultat dans : $v0
# Registres utilises : $a0, $t9
check_rows:
    add     $sp, $sp, -4 	# sauvegarde la reference du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    li      $t9, 0		    # $t9 <- 0
    boucle_check_rows:
   	bge     $t9, 9, end_check_rows		    # Si $t9 < 9:
   	move      $a0, $t9			            # Affectation du registre d'argument a  la ligne a  verifier: $a0 <- $t9
    	jal check_n_row			            # Appel de la fonction check_n_rows
    	beq     $v0, $0, end_check_rows		# Si la valeur de retour != 0:    (Sinon Fin)
        addi    $t9, $t9, 1			        # $t9 <- $t9 + 1
    	j boucle_check_rows			        # relancer la boucle
    end_check_rows:
    lw      $ra, 0($sp)		# On recharge la reference 
    add     $sp, $sp, 4		# du dernier jump
    jr $ra
#                                               #
#                                               #
# ----- Fonction check_squares -----            #
# Objectif : Verifier la validite de tous les carres de la grille de sudoku
# Resultat dans : $v0
# Registres utilises : $a0, $t0
check_squares:
    add     $sp, $sp, -4 	# sauvegarde la reference du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    li      $t9, 0		    # $t9 <- 0
    boucle_check_squares:
   	bge     $t9, 9, end_check_squares	        # Si $t9 < 9:
   	move      $a0, $t9			                # Affectation du registre d'argument a  la ligne que l'on souhaite verifier: $a0 <- $t9
    	jal check_n_square			            # Appel de la fonction check_n_rows
    	beq     $v0, $0, end_check_squares	    # Si la valeur de retour != 0:    (Sinon Fin)
        addi    $t9, $t9, 1			            # $t9 <- $t9 + 1
    	j boucle_check_squares			        # relancer la boucle
    end_check_squares:
    lw      $ra, 0($sp)		# On recharge la reference 
    add     $sp, $sp, 4		# du dernier jump
    jr $ra
#                                               #
#                                               #
# ----- Fonction check_sudoku -----             #
# Objectif : Verifier que la grille de sudoku est valide
# Resultat dans : $v0
# Registres utilises : 
check_sudoku:
    add     $sp, $sp, -4 	# sauvegarde la reference du dernier jump dans le pointeur de pile
    sw      $ra, 0($sp) 	# RAM[$sp + 0] <- $ra (adresse de retour)
    jal check_rows			# Saut vers le fonction check_rows
    beq     $v0, $0, end_check_sudoku	# Si la valeur de retour est 0 (false) Alors Fin
    jal check_columns			        # Sinon, saut vers le fonction check_columns
    beq     $v0, $0, end_check_sudoku	# Si la valeur de retour est 0 (false) Alors Fin
    jal check_squares			        # Sinon, saut vers le fonction check_squares
    beq     $v0, $0, end_check_sudoku	# Si la valeur de retour est 0 (false) Alors Fin
    # Sinon: Message validation de la grille
    #la      $a0, validation   	#adresse de la chaine a afficher
    #li      $v0, 4              #appel systeme 4: afficher une chaa®ne de caractere
    #syscall
    end_check_sudoku:
    lw      $ra, 0($sp)     # On recharge la reference 
    add     $sp, $sp, 4     # du dernier jump
    jr $ra


# Fonction solve_sudoku
# $s0 = Adresse du tableau
# $s1 = Variable de boucle_case_vide
solve_sudoku:	
	# Sauvegarde de la reference du dernier jump
	sub     $sp, $sp, 4 
	sw      $ra, 0($sp) 
	
	li      $s1, 0 #Initialisation pour la boucle case vide
	li      $s3, 1 #Initialisation pour la boucle chiffre

	#Trouver l'adresse de la première case vide
    	boucle_case_vide: 
    		bge $s1, 81, solution #Si aucune case vide alors solution
    			add     $s2, $s0, $s1           # $s0 + $s1 -> $s2 ($s0 l'adresse du tableau et $s1 la position dans le tableau)
            		lb      $a0, ($s2)		#Charge la valeur contenue à cet emplacement
			beqz 	$a0, boucle_chiffre  	#Branch si la valeur à cet emplacement est 0
    			add $s1, $s1, 1 		# $s1 += 1
        	j boucle_case_vide # Et on reboucle !
        
        #Tester pour 1 à 9 les valeurs dans la case vide	
	boucle_chiffre:
		bgt     $s3, 9, fin_boucle_chiffre #Si la variable de boule atteint 9 on sort
			sb $s3, 0($s2) #On essaye le chiffre en le plaçant dans la case vide
			jal check_sudoku #On vérifie si la grille est toujours correct
			
			beqz $v0, fin_test #Si le $v0 = 0 alors le test est faux donc on ne propage pas
				sub     $sp, $sp, 8
            			sw      $s2, 0($sp)
            			sw      $s3, 4($sp) #Sauvegarde des variables de boules et adresses
            			jal solve_sudoku # Retro propagation
            			lw      $s2, 0($sp)
            			lw      $s3, 4($sp)
            			add     $sp, $sp, 8
			fin_test:
				sb $zero, 0($s2) #Remet 0 dans la case
		
		add $s3, $s3, 1 #Sinon on continue la boucle
        	j boucle_chiffre # Et on reboucle !
	fin_boucle_chiffre:#Retourne au saut précedent
		lw      $ra, 0($sp)                 
    		add     $sp, $sp, 4 
        	jr $ra
	
    	solution:
        	jal displayGrille #Affiche la grille comme solution
        	jal addNewLine
        	# On recharge la reference 
        	lw      $ra, 0($sp)                 
    		add     $sp, $sp, 4 
        	jr $ra

exit: 
    li $v0, 10
    syscall
