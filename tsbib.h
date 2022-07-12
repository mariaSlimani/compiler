typedef struct
{
   char NomEntite[50];
   char TypeEntite[50];
   char EtatEntite[50];
   int TailleEntite;
   char val[256];
}TypeTS;


TypeTS ts[1000];
int cts=0;

int recherche(char entite[])
{
   int i=0;

   while(i<cts)
   {
   
       if(strcmp(entite,ts[i].NomEntite)==0)return i;
       i++;
   }

   return -1;

}

void afficher()

{
   printf("\n/***************Table des symboles ******************/\n");


   printf("\t_____________________________________________________\n");


   printf("\t| NomEntite | TypeEntite | TailleEntite | Etat| Val |\n");


   printf("\t_____________________________________________________\n");
   int i=0;


   while(i<cts)

   {

       printf("\t| %10s | %12s | %d |%s | %s\n",ts[i].NomEntite,ts[i].TypeEntite,ts[i].TailleEntite,ts[i].EtatEntite,ts[i].val);

       i++;

   }
}
void inserer(char entite[])

{

   if(recherche(entite)==-1)

   {
       strcpy(ts[cts].NomEntite,entite);
       cts++;
   }
}


void insererType(char entite[],char type[])
{
   int ie=recherche(entite);
   if(ie!=-1)
   {
       strcpy(ts[ie].TypeEntite,type);
   }
}
void insererEtat(char entite[],char etat[])
{
   int ie=recherche(entite);
   if(ie!=-1)
   {
       strcpy(ts[ie].EtatEntite,etat);
   }
}

void insererTaille(char entite[],int Taille)
{
   int ie=recherche(entite);
   if(ie!=-1) 
       ts[ie].TailleEntite=Taille;
}

void insererVal(char entite[],char* val)
{
   int ie=recherche(entite);
   if(ie!=-1) 
       {
       		strcpy(ts[ie].val,val);
       }
} 

int typeInt(char entite[])
{
   int ie=recherche(entite);
   if(ie!=-1 && strcmp(ts[ie].TypeEntite,"ent")==0)
   {return 1;}
   return 0;

}

int typeFloat(char entite[])

{

   int ie=recherche(entite);
   
   if(ie!=-1 && strcmp(ts[ie].TypeEntite,"flot")==0)
   {return 1;}
   return 0;
}

int typeString(char entite[])
{

   int ie=recherche(entite);
   if(ie!=-1 && strcmp(ts[ie].TypeEntite,"ch")==0)
   {return 1;}
   return 0;
}

int typeCar(char entite[])
{

   int ie=recherche(entite);
   if(ie!=-1 && strcmp(ts[ie].TypeEntite,"car")==0)
   {return 1;}
   return 0;
}


int etatConst(char entite[])
{
   int ie=recherche(entite);
   if(ie!=-1 && strcmp(ts[ie].EtatEntite,"const")==0)
   {return 1;}
   return 0;
}

int etatVar(char entite[])
{
   int ie=recherche(entite);
   if(ie!=-1 && strcmp(ts[ie].EtatEntite,"var")==0)
   {return 1;}
   return 0;
}

char* getVal (char entite[]) 
{
	int ie=recherche(entite);
	if(ie!=-1)
	{
		return ts[ie].val;	
	}
	return 0;
}
char* getType (char entite[]) 
{
	int ie=recherche(entite);
	if(ie!=-1)
	{
		return ts[ie].TypeEntite;	
	}
	return 0;
}
int retournerTaille (char entite[])
{
   int ie=recherche(entite);
   if(ie!=-1)
    return ts[ie].TailleEntite;
}

int declare(char entite[])
{
   int ie=recherche(entite);
   if(strcmp(ts[ie].TypeEntite,"")==0)
       return 0;
   else
       return 1;
}


int constEd(char entite[])
{
   int ie=recherche(entite);
   if(strcmp(ts[ie].TypeEntite,"CONST")==0)
       return 1;
   return 0;
}


