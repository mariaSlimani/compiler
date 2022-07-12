 %{

        #include <stdio.h>

        #include <stdlib.h>

        #include <string.h>

        char sonType [20];
        FILE *fp;
        char t[50];

        int nline=1;

        int count=1;        

        int tabnd=0;        

        char* saveN ;        

        char* type;        

        int yylex();        

        int yydebug = 1;        

        char valeur[200];

        int yyerror(char* msg);

        int recherche(char entite[]);

        void afficher(); 

        void inserer(char entite[]);

        void insererType(char entite[],char type[]);

        void insererEtat(char entite[],char etat[]);

        void insererTaille(char entite[],int Taille);

        void insererVal(char entite[],char val[]);

        int typeInt(char entite[]);

        int typeFloat(char entite[]);

        int typeString(char entite[]);

        int typeCar(char entite[]);

        int etatConst(char entite[]);

        int etatVar(char entite[]);

        char* getVal (char entite[]);

        char* getType (char entite[]);

        int retournerTaille (char entite[]);

        int declare(char entite[]);

        int constEd(char entite[]);

%}

  

//Partie 2 : déclarations pour yacc

    %union{

        int entier;

        char* str;

        char c;

        float flt;

    }



    %start S

    %type <str>Type 

    %token PROGRAMME MAIN FONCTION SI SINON SSI POUR TQ FAIRE_TQ  ECRIRE LIRE ECRIRE_DANS LIRE_DE IMPORT AFFECTATION

    %token FIN_INSTRUCTION SEPARATEUR CONST VARIABLE

    %token <str>TYPE_ENT <str>TYPE_FLOT <str>TYPE_CAR T<str>TYPE_CH <str>ENREG

    %token <entier> ENTIER <str> CHAR <flt> FLOTTANT <str> CARACTERE <str> ID

    %left OU

    %left ET 

    %right NEGATION

    %left INF_EGAL INF SUPP SUPP_EGAL EGALE PASEGALE

    %left PLUS MOINS DIV MUL MOD

    %right PAR_OUV PAR_FERM

    %right DEB_CORPS FIN_CORPS

    %right BRA_OUV BRA_FERM

    

%%



S: PROGRAMME FIN_INSTRUCTION Bibs Fcts { fprintf( fp, "~~~Le programme est syntaxiquement correct~~~\n");YYACCEPT;}; 

Bibs : TheImport Bibs| ;

TheImport : IMPORT CHAR FIN_INSTRUCTION;

Fcts : Fct Fcts| Meth Fcts|FctMain;

Meth : FONCTION ID BRA_OUV Params BRA_FERM FIN_INSTRUCTION LeCorps { 

    if (declare($2)==0)



	 {   

		insererType($2,"procedure");

	 }



	 else fprintf(fp, "erreur Semantique: double déclaration de la procédure %s, avant la ligne %d, la colonne %d\n", $2, nline,count);}

          

          | FONCTION ID BRA_OUV BRA_FERM FIN_INSTRUCTION LeCorps { 

              if (declare($2)==0)

              {   



                 insererType($2,"procedure");

                }



				 else fprintf(fp, "erreur Semantique: double déclaration de la procédure %s, avant la ligne %d, la colonne %d\n", $2, nline,count);

			 };

			 

 

Fct : FONCTION Type ID BRA_OUV Params BRA_FERM FIN_INSTRUCTION LeCorps { if (declare($3)==0)

						        {   

						        	strcpy(t,"fct_");

						            insererType($3,strcat(t,$2));

						        }

						    else fprintf(fp, "erreur Semantique: double déclaration de la fonction %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

						    }

						    

          | FONCTION Type ID BRA_OUV BRA_FERM FIN_INSTRUCTION LeCorps { if (declare($3)==0)

						        {   

						        	strcpy(t,"fct_");

						            insererType($3,strcat(t,$2));

						        }

						    else fprintf(fp, "erreur Semantique: double déclaration de la fonction %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

						    };

          

Params : Param SEPARATEUR Params | Param;

 

Param: Type ID {if (declare($2)==0)

		{   

			insererType($2,$1);

                        insererEtat($2,"var");

		}

		else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $2, nline,count);

        }

    | Type ID BRA_OUV BRA_FERM {if (declare($2)==0)

				{   

					strcpy(t,"tab_");

					insererType($2,strcat(t,$1));

				}

				else fprintf(fp, "erreur Semantique: double déclaration du tableau %s, avant la ligne %d, la colonne %d\n", $2, nline,count);

    }

    | ENREG ID DEB_CORPS FIN_CORPS {if (declare($2)==0)

				{   

					insererType($2,"enreg");

				}

				else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $2, nline,count);

    };

 

Type : TYPE_ENT {$$=$1;}

	| TYPE_FLOT {$$=$1;}

	| TYPE_CAR {$$=$1;}

	| TYPE_CH {$$=$1;};

FctMain: MAIN FIN_INSTRUCTION LeCorps;

 

LeCorps: DEB_CORPS FIN_INSTRUCTION Corps FIN_CORPS FIN_INSTRUCTION;

 

Corps : Instrus Corps| Ctrl Corps| Boucle Corps| ;



Ctrl : SI Cond {
    //r1
    fprintf(fp, "***Les routines sémantiques pour l'instruction Si-SiSinon-Sinon***\n");
    fprintf(fp, "Si - R1\n");
    fprintf(fp, "QUAD (BZ, , <Cond>, ) \n");
    fprintf(fp, "Sauv-BZ := Qc \n");
    fprintf(fp, "Qc := Qc+1 \n");

} FIN_INSTRUCTION LeCorps {
    //r2
    fprintf(fp, "Si - R2\n");
    fprintf(fp, "QUAD (Qc) := (BR, , , ) \n");
    fprintf(fp, "Sauv-BR := Qc \n");
    fprintf(fp, "Qc := Qc + 1 \n");
    fprintf(fp, "QUAD (Sauv-BZ, 2) := Qc \n");
    

}ResteCtrl {
 //r5
    fprintf(fp, "Si - R5\n");
    fprintf(fp, "QUAD (Sauv-BR, 2) := Qc \n"); //fin
    fprintf(fp, "******\n\n");

};
ResteCtrl : SSI Cond {
    //r3 
    fprintf(fp, "Si - R3\n");
    fprintf(fp, "QUAD (BZ, , <Cond>, ) \n");
    fprintf(fp, "Sauv-BZ2 := Qc \n");
    fprintf(fp, "Qc := Qc+1 \n");

} FIN_INSTRUCTION LeCorps {
    //r4
    fprintf(fp, "Si - R4\n");
    fprintf(fp, "QUAD (Qc) := (BR, , , ) \n");
    fprintf(fp, "Sauv-BR := Qc \n");
    fprintf(fp, "Qc := Qc + 1 \n");
    fprintf(fp, "QUAD (Sauv-BZ2, 2) := Qc \n");

}ResteCtrl 
| SINON FIN_INSTRUCTION LeCorps| ;

Cond : PAR_OUV Comparaison PAR_FERM

          | PAR_OUV NEGATION Cond PAR_FERM  

          |  PAR_OUV Cond ET Cond PAR_FERM

          |  PAR_OUV Cond OU Cond PAR_FERM;

 

 

Comparaison : Expression OpComp Expression ;

 

OpComp : INF_EGAL | INF | SUPP | SUPP_EGAL | EGALE | PASEGALE;

OpAr : PLUS | MOINS | MUL | DIV | MOD ;

Expression : Arg OpAr Expression 

            | PAR_OUV Expression PAR_FERM

            | Arg;

Boucle : PourB | TqB | FtqB;

TqB : TQ {
    //R1
    fprintf(fp, "***Les routines sémantiques pour l'instruction Tant Que***\n");
    fprintf(fp, "TQ- R1\n");
    fprintf(fp, "Sauv-deb := Qc\n"); // sauv du debut afin d'y revenir
    
} Cond {
    //R2
    fprintf(fp, "TQ- R2\n");
    fprintf(fp, "QUAD(Qc) := (BZ, , <Cond>, )\n");
    fprintf(fp, "Sauv-BZ := Qc\n");
    fprintf(fp, "Qc := QC + 1 \n");

} FIN_INSTRUCTION LeCorps {
    //R3
    fprintf(fp, "TQ- R3\n");
    fprintf(fp, "QUAD(Qc) := (BR, Sauv-deb, , ) \n");
    fprintf(fp, "Qc := Qc + 1 \n");
    fprintf(fp, "QUAD(Sauv-BZ, 2) :=Qc \n");
    fprintf(fp, "******\n\n");

};

FtqB : FAIRE_TQ FIN_INSTRUCTION{
    //R1
    fprintf(fp, "***Les routines sémantiques pour l'instruction Faire Tant Que***\n");
    fprintf(fp, "FTQ- R1\n");
    fprintf(fp, "Sauv-deb := Qc\n"); // sauv du debut afin d'y revenir
    fprintf(fp, "Qc := Qc + 1 \n");

} LeCorps Cond FIN_INSTRUCTION{
    //R2
    fprintf(fp, "FTQ- R2\n");
    fprintf(fp, "QUAD(Qc) := (BNZ,Sauv-deb, <Cond>, )\n");
    fprintf(fp, "******\n\n");

};

PourB : POUR PourCond FIN_INSTRUCTION LeCorps;

PourCond : PAR_OUV DeclarePour SEPARATEUR Comparaison SEPARATEUR  Incr PAR_FERM

                  | PAR_OUV DeclarePour SEPARATEUR  Comparaison  SEPARATEUR  Dcr PAR_FERM ;

Incr : ID PLUS PLUS {if(declare($1)==0)

                        {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $1, nline,count);} 

                        else{

                            if (etatConst($1)==1)

                            {

                                {fprintf(fp, "erreur Semantique:  %s est une constante: avant la ligne %d, a la colonne %d\n",$1, nline,count);}                             

                            }

                            else if( typeInt($1)!=1 && typeFloat($1)!=1)

                            {

                            fprintf(fp, "erreur Semantique: type de %s est incompatible  : avant la ligne %d, a la colonne %d\n",$1, nline,count);}                         
                        }}

| ID PLUS Num {if(declare($1)==0)

                        {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $1, nline,count);} 

                        else{

                            if (etatConst($1)==1)

                            {

                                {fprintf(fp, "erreur Semantique:  %s est une constante: avant la ligne %d, a la colonne %d\n",$1, nline,count);}                             

                            }

                            else if( typeInt($1)!=1 && typeFloat($1)!=1)

                            {fprintf(fp, "erreur Semantique: type de %s est incompatible  : avant la ligne %d, a la colonne %d\n",$1, nline,count);}      

                            else{

                            			

                            }                       

                        }

                        };

Dcr  : ID  MOINS MOINS  {if(declare($1)==0)

                        {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $1, nline,count);} 

                        else{

                            if (etatConst($1)==1)

                            {

                                {fprintf(fp, "erreur Semantique:  %s est une constante: avant la ligne %d, a la colonne %d\n",$1, nline,count);}                             

                            }

                            else if( typeInt($1)!=1 && typeFloat($1)!=1)

                            {fprintf(fp, "erreur Semantique: type de %s est incompatible  : avant la ligne %d, a la colonne %d\n",$1, nline,count);}

                            else{

                            			

                            }                             

                        }}

| ID MOINS Num {if(declare($1)==0)

                        {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $1, nline,count);} 

                        else{

                            if (etatConst($1)==1)

                            {

                                {fprintf(fp, "erreur Semantique:  %s est une constante: avant la ligne %d, a la colonne %d\n",$1, nline,count);}                             

                            }

                            else if( typeInt($1)!=1 && typeFloat($1)!=1)

                            {fprintf(fp, "erreur Semantique: type de %s est incompatible  : avant la ligne %d, a la colonne %d\n",$1, nline,count);}  

                            else{

                            			

                            }                           

                        }};



DeclarePour :  TYPE_ENT ID AFFECTATION ENTIER { if (declare($2)==0)

						        {   

						            insererType($2,"ent");

                                    char c[50];

                                    sprintf(c, "%d", $4);

                                    insererVal($2,c); 

						        }

						    else fprintf(fp, "erreur Semantique: double déclaration de  %s, avant la ligne %d, la colonne %d\n", $2, nline,count);

						    }

    | TYPE_FLOT ID AFFECTATION FLOTTANT { if (declare($2)==0)

						        {   

						            insererType($2,"flot");

                                    char c[50];

                                    sprintf(c, "%f", $4);

                                    insererVal($2,c); 

						        }

						    else fprintf(fp, "erreur Semantique: double déclaration de  %s, avant la ligne %d, la colonne %d\n", $2, nline,count);

						    };

DeclareEntVar :  VARIABLE TYPE_ENT ID AFFECTATION ENTIER {if (declare($3)==0)

					{   

						insererType($3,"ent");

						insererEtat($3,"var");
                        

					}

				    else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

                }

 

                             | VARIABLE TYPE_ENT ID {if (declare($3)==0)

                                                        {   

                                                            insererType($3,"ent");

                                                            insererEtat($3,"var");

                                                        }

                                                        else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

                                                    }; 

 

 

DeclareFlotVar :  VARIABLE TYPE_FLOT ID AFFECTATION FLOTTANT {if (declare($3)==0)

					{   

						insererType($3,"flot");

                        insererEtat($3,"var");
                        

					}

				    else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

                }

                | VARIABLE TYPE_FLOT ID {if (declare($3)==0)

					{   

						insererType($3,"flot");

                        			insererEtat($3,"var");

					}

				    else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

                };

 

DeclareCarVar : VARIABLE TYPE_CAR ID AFFECTATION CARACTERE {if (declare($3)==0)

					{   

						insererType($3,"car");

                        insererEtat($3,"var");
                        

					}

				    else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

                }

                             | VARIABLE TYPE_CAR ID {if (declare($3)==0)

					{   

						insererType($3,"car");

                        insererEtat($3,"var");

					}

				    else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

                };

 

DeclareChVar : VARIABLE TYPE_CH ID AFFECTATION CHAR {if (declare($3)==0)

					{   

						insererType($3,"ch");

                        insererEtat($3,"var");
                        

					}

				    else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

                }

                             | VARIABLE TYPE_CH ID {if (declare($3)==0)

					{   

						insererType($3,"ch");

                        insererEtat($3,"var");

					}

				    else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

                };

 

DeclareEntConst :  CONST TYPE_ENT ID AFFECTATION ENTIER {if (declare($3)==0)

					{   

						insererType($3,"ent");

                        insererEtat($3,"const");

                        char c[50];

						sprintf(c, "%d", $5);

                        insererVal($3,c);

					}

				    else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

                } ;

DeclareFlotConst :  CONST TYPE_FLOT ID AFFECTATION FLOTTANT {if (declare($3)==0)

					{   

						insererType($3,"flot");

                        insererEtat($3,"const");

                        char c[50];
						sprintf(c, "%f", $5);

                        insererVal($3, c);

					}

				    else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

                };

 

DeclareCarConst : CONST TYPE_CAR ID AFFECTATION CARACTERE {if (declare($3)==0)

					{   

						insererType($3,"car");

                        insererEtat($3,"const");

                        insererVal($3,$5);

					}

				    else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

                };

DeclareChConst : CONST TYPE_CH ID AFFECTATION CHAR {if (declare($3)==0)

					{   

						insererType($3,"ch");

                        insererEtat($3,"const");

                        insererVal($3,$5);

					}

				    else fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $3, nline,count);

                };

Aff : ID AFFECTATION Expression {if(declare($1)==0)

                            {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $1, nline,count);} 

                        else{

                            if (etatConst($1)==1)

                            {

                                {fprintf(fp, "erreur Semantique:  %s est une constante: avant la ligne %d, a la colonne %d\n",$1, nline,count);}                             

                            }

                            else if((strcmp(getType($1),sonType)!=0)&&((strcmp(getType($1),"flot")!=0)&&(strcmp(sonType,"ent")!=0))) 
                            {
                                fprintf(fp, "erreur Semantique: type de %s est incompatible : avant la ligne %d, a la colonne %d\n",$1, nline,count);}                           

                        }}

        | ID BRA_OUV BRA_FERM AFFECTATION BRA_OUV Args BRA_FERM {if(declare($1)==0)

                            {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $1, nline,count);} 

                        else{

                            if (etatConst($1)==1)

                            {

                                {fprintf(fp, "erreur Semantique:  %s est une constante: avant la ligne %d, a la colonne %d\n",$1, nline,count);}                             

                            }

                            else if (strstr(getType($1),"tab")==NULL)

                            {

                                fprintf(fp, "erreur Semantique:  %s n'est pas un tableau: avant la ligne %d, a la colonne %d\n",$1, nline,count);

                            }

                        }}

        | ID BRA_OUV BRA_FERM AFFECTATION BRA_OUV BRA_FERM {if(declare($1)==0)

                            {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $1, nline,count);} 

                        else{

                            if (etatConst($1)==1)

                            {

                                {fprintf(fp, "erreur Semantique:  %s est une constante: avant la ligne %d, a la colonne %d\n",$1, nline,count);}                             

                            }

                            else if (strstr(getType($1),"tab")==NULL)

                            {

                                fprintf(fp, "erreur Semantique:  %s n'est pas un tableau: avant la ligne %d, a la colonne %d\n",$1, nline,count);

                            }

                        }}

        | ID DEB_CORPS FIN_CORPS AFFECTATION DEB_CORPS Values FIN_CORPS {if(declare($1)==0)

                            {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $1, nline,count);} 

                        else{

                            if (etatConst($1)==1)

                            {

                                {fprintf(fp, "erreur Semantique:  %s est une constante: avant la ligne %d, a la colonne %d\n",$1, nline,count);}                             

                            }

                            else if (strcmp(getType($1),"enreg")!=0)

                            {

                                fprintf(fp, "erreur Semantique:  %s n'est pas un enregistrement: avant la ligne %d, a la colonne %d\n",$1, nline,count);

                            }

                        }}

       |Incr

       |Dcr 

       |AppelFct;

 

 

 

Instrus : DeclareEntVar FIN_INSTRUCTION

        | DeclareFlotVar FIN_INSTRUCTION

        | DeclareCarVar FIN_INSTRUCTION

        | DeclareChVar FIN_INSTRUCTION

        | DeclareEntConst FIN_INSTRUCTION

        | DeclareFlotConst FIN_INSTRUCTION

        | DeclareCarConst FIN_INSTRUCTION

        | DeclareChConst FIN_INSTRUCTION

        | Enregistrement FIN_INSTRUCTION

        | Tab FIN_INSTRUCTION 

        | Aff FIN_INSTRUCTION

        | AppelMeth FIN_INSTRUCTION

        | Affich FIN_INSTRUCTION

        | AffFish FIN_INSTRUCTION

        | Lir FIN_INSTRUCTION

        | LirDe FIN_INSTRUCTION;

 

Affich : ECRIRE PAR_OUV Arg PAR_FERM ;

AffFish : ECRIRE_DANS PAR_OUV Arg SEPARATEUR Arg PAR_FERM;

Lir: LIRE PAR_OUV ID PAR_FERM {if(declare($3)==0)

                            {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $3, nline,count);} 

                        };

LirDe : LIRE_DE PAR_OUV Arg ID PAR_FERM {if(declare($4)==0)

                            {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $4, nline,count);} 

                        };

AppelFct : ID AFFECTATION FONCTION ID BRA_OUV BRA_FERM  {if(declare($1)==0)

                                                        {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $1, nline,count);} 

                                                        else if(declare($4)==0)

                                                        {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $4, nline,count);} 

                                                         else if(strstr(getType($4),"fct")==NULL)

                                                        {fprintf(fp, "erreur Semantique: %s n'est pas une fonction: avant la ligne %d, a la colonne %d\n",$4, nline,count);} 

                                                        else if(strstr(getType($4),getType($1))==NULL)

                                                        {fprintf(fp, "erreur Semantique: type de %s est incompatible : avant la ligne %d, a la colonne %d\n",$1, nline,count);}}

                  | ID AFFECTATION FONCTION ID BRA_OUV Args BRA_FERM {if(declare($1)==0)

                                                        {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $1, nline,count);} 

                                                        if(declare($4)==0)

                                                        {fprintf(fp, "erreur Semantique: %s non declaré, avant la ligne %d, a la colonne %d\n", $4, nline,count);} 

                                                         else if(strstr(getType($4),"fct")==NULL)

                                                        {fprintf(fp, "erreur Semantique: %s n'est pas une fonction: avant la ligne %d, a la colonne %d\n",$4, nline,count);} 

                                                        else if(strstr(getType($4),getType($1))==NULL)

                                                        {fprintf(fp, "erreur Semantique: type de %s est incompatible : avant la ligne %d, a la colonne %d\n",$1, nline,count);}  

                                                        };

AppelMeth : FONCTION ID BRA_OUV BRA_FERM 

                      | FONCTION ID BRA_OUV Args BRA_FERM ;

Args: Expression SEPARATEUR Args| Expression ;



Arg: ID {strcpy(sonType , getType($1));} 

| ENTIER {strcpy(sonType , "ent");}

| FLOTTANT {strcpy(sonType , "flot");}

| CHAR {strcpy(sonType , "ch");}

| CARACTERE{strcpy(sonType , "car");};

 

Num :  ENTIER {$<entier>$=$1;

		

                        			char c[50];

						sprintf(c, "%d", $1);

						strcpy(valeur, c);}

| FLOTTANT {$<flt>$=$1;

						char c[50];

						sprintf(c, "%f", $1);

						strcpy(valeur, c);};

 

Tab : Type ID BRA_OUV BRA_FERM  {if(declare($2)==1)

                            {fprintf(fp, "erreur Semantique: %s  double déclaration de, avant la ligne %d, a la colonne %d\n", $2, nline,count);}

                             else{

                                 insererType($2,strcat ("tab ",$1));

                                 insererEtat($2,"var");

                             }

                        }

          |  Type ID BRA_OUV BRA_FERM AFFECTATION BRA_OUV BRA_FERM {if(declare($2)==1)

                            {fprintf(fp, "erreur Semantique: %s  double déclaration de, avant la ligne %d, a la colonne %d\n", $2, nline,count);}

                             else{

                                 insererType($2,strcat ("tab ",$1));

                                 insererEtat($2,"var");

                             }

                        }

          |  Type ID BRA_OUV BRA_FERM AFFECTATION BRA_OUV Args BRA_FERM {if(declare($2)==1)

                            {fprintf(fp, "erreur Semantique:  double déclaration de %s , avant la ligne %d, a la colonne %d\n", $2, nline,count);}

                             else{

                                 insererType($2,strcat ("tab ",$1));

                                 insererEtat($2,"var");

                             }

                        };



Enregistrement :   ENREG ID DEB_CORPS FIN_CORPS {if(declare($2)==1)

                            {fprintf(fp, "erreur Semantique: double déclaration de %s , avant la ligne %d, a la colonne %d\n", $2, nline,count);}

                             else{

                                 insererType($2,"enreg ");

                                 insererEtat($2,"var");

                             }

                        }

                                | ENREG ID DEB_CORPS FIN_CORPS AFFECTATION DEB_CORPS  Values FIN_CORPS {if(declare($2)==1)

                            {fprintf(fp, "erreur Semantique: double déclaration de %s , avant la ligne %d, a la colonne %d\n", $2, nline,count);}

                             else{

                                 insererType($2,"enreg ");

                                 insererEtat($2,"var");

                             }

                        }; 

 

Values :  Value FIN_INSTRUCTION Values | Value| ;


Value:   TYPE_ENT ID AFFECTATION ENTIER {if (declare($2)==1)

                                            {

                                             fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $2, nline,count);

                                            }

                                        }

| TYPE_FLOT ID AFFECTATION FLOTTANT   {if (declare($2)==1)

                                            {

                                             fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $2, nline,count);

                                            }

                                        }

| TYPE_CAR ID AFFECTATION CARACTERE   {if (declare($2)==1)

                                            {

                                             fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $2, nline,count);

                                            }

                                        }

| TYPE_CH ID AFFECTATION CHAR  {if (declare($2)==1)

                                            {

                                             fprintf(fp, "erreur Semantique: double déclaration de %s, avant la ligne %d, la colonne %d\n", $2, nline,count);

                                            }

                                        };

 

 

%%

int main()

{
    fp = fopen("Output.txt", "w");
    yyparse();

    afficher();

} 

int yyerror(char* msg)

{

    fprintf(fp, "Erreur syntaxique rencontree a la ligne %d, la colonne %d\n",nline,count);

}


