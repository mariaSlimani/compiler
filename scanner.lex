%{



#include <stdio.h>



#include <stdlib.h>



#include <string.h>



#include "y.tab.h"



#include "tsbib.h"



extern YYSTYPE yylval;



static void skip_single_line_comment(void);



extern int count;



extern int nline;

 



%}



 



 



chiffre     [0-9]



lettre      [a-zA-Z]



car         [']{lettre}[']



ID          [a-zA-Z_][a-zA-Z0-9_]*



ent         (([1-9]{chiffre}*)|(0))



flot        {ent}+"."+{ent}



blancs      [ \t]+



ch          \"(\\.|[^"\\])*\"



type        [“ent”|”flot”|”ch”|”car”|”bool”]



programme   #.[a-zA-Z_][a-zA-Z0-9_]*

 

enreg       "enreg".{blancs}.[a-zA-Z_][a-zA-Z0-9_]*

 



%%







"//"    	skip_single_line_comment();



{car}       {	count=count+yyleng;

		yylval.str = strdup(yytext);

		return CARACTERE;

		}



{ch}        {			
		count=count+yyleng;

		yylval.str = strdup(yytext);

		return CHAR;

		}





{ent}       {	count=count+yyleng;

		yylval.entier = atoi(yytext);

		return ENTIER;

		}



{flot}      {	count=count+yyleng;

		yylval.flt = atof(yytext);

		return FLOTTANT;

		}





"importer"  {count=count+8;

		return IMPORT;}



"$Prog"    {count=count+5;

		return MAIN;}



"$"         {count=count+1;

		return FONCTION;}



"var"       {count=count+3;

		return VARIABLE;}



"const"     {count=count+5;

		return CONST;}



"ent"       {count=count+3;

		yylval.str = strdup(yytext);

		return TYPE_ENT;

		}



"flot"      {count=count+4;

		yylval.str = strdup(yytext);

		return TYPE_FLOT;

		}



"car"       {count=count+3;

		yylval.str = strdup(yytext);

		return TYPE_CAR;

		}



"ch"        {	count=count+2;

		yylval.str = strdup(yytext);

		return TYPE_CH;

		}



"lire"      {count=count+4;

		return LIRE;}



"ecrire"    {count=count+6;

		return ECRIRE;}



"lireDe"    {count=count+6;

		return LIRE_DE;}



"ecrireDans" {count=count+10;

		return ECRIRE_DANS;}



"tq"        {count=count+2;

		return TQ;}



"pour"      {count=count+4;

		return POUR;}



"faireTq"   {count=count+7;

		return FAIRE_TQ;}



"si"        {count=count+2;

		return SI;}



"ssi"       {count=count+3;

		return SSI;}



"sinon"     {count=count+5;

		return SINON;}



"enreg"     {count=count+5;

		return ENREG;}



{programme} {		
		count=count+yyleng;

		return PROGRAMME;

		}



{ID}        {	count=count+yyleng;

		yylval.str = strdup(yytext);

		inserer(yytext);

		return ID;

		}



{blancs}    {	count=count+yyleng;}; 



"\n"        {
		nline++;

		count =1;

		return FIN_INSTRUCTION;

	}



"+"         {count++;

		return PLUS;}



"/"         {count++;

		return DIV;}



"-"         {count++;

		return MOINS;}



"*"         {count++;

		return MUL;}



"%"         {count++;

		return MOD;}



"("         {count++;

		return PAR_OUV;}



")"         {count++;

		return PAR_FERM;}



"<=="       {count=count+3;

		return INF_EGAL;}



"<"         {count++;

		return INF;}



">"         {count=count+1;

		return SUPP;}



">=="       {count=count+3;

		return SUPP_EGAL;}



"==="       {count=count+3;

		return EGALE;}



"!=="       {count=count+3;

		return PASEGALE;}



"!"         {count++;

		return NEGATION;}



"&"         {count++;

		return ET;}



"|"         {count++;

		return OU;}



"="         {count++;

		return AFFECTATION;}



"{"         {count++;

		return DEB_CORPS;}



"}"         {count++;

		return FIN_CORPS;}



"["         {count++;

	return BRA_OUV;}



"]"         {count++;

		return BRA_FERM;}



","         {count++;

		return SEPARATEUR ;}

.   {

    printf("Erreur %s code %d ligne %d colonne %d\n",yytext,yytext[0], nline,count);

    count+=strlen(yytext);

}



 



%%





static void skip_single_line_comment(void)

{

  int c;

		nline++;

  while((c = input()) != '\n' && c != EOF)

{


	count =1;

}



  if(c == EOF)

    unput(c);

}



int yywrap(){

    return 1;

}





 



 








