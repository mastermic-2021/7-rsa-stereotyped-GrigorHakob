/**
Copyright 2021 cryptoflop.org
Gestion des changements de mots de passe.
**/
randompwd(len) = {
  externstr(Str("base64 /dev/urandom | head -c ",len))[1];
}
dryrun=1;
sendmail(address,subject,message) = {
  cmd = strprintf("echo %d | mail -s '%s' %s",message,subject,address);
  if(dryrun,print(cmd),system(cmd));
}
chpasswd(user,pwd) = {
  cmd = strprintf("yes %s | passwd %s",pwd,user);
  if(dryrun,print(cmd),system(cmd));
}
template = {
  "Cher collaborateur, votre nouveau mot de passe est %s. "
  "Merci de votre comprehension, le service informatique.";
  }
change_password(user,modulus,e=7) = {
  iferr(
    pwd = randompwd(10);
    chpasswd(user, pwd);
    address = strprintf("%s@cryptoflop.org",user);
    mail = strprintf(template, pwd);
    m = fromdigits(Vec(Vecsmall(mail)),128);
    c = lift(Mod(m,modulus)^e);
    sendmail(address,"Nouveau mot de passe",c);
    print("[OK] changed password for user ",user);
  ,E,print("[ERROR] ",E));
}

\\ le 128 vient de la fonction "change_password"

encode(m) = {
	  fromdigits(Vec(Vecsmall(m)),128);
	  }

decode(c) = {
	  Strchr(digits(c,128));
	  }

get_struct()={
	debut = Vec(Vecsmall("Cher collaborateur, votre nouveau mot de passe est "));	

	fin = Vec(Vecsmall(". Merci de votre comprehension, le service informatique."));

	mdp=Vec(0,10);
	\\ longueur 10 pour le mdp

	chiffre=concat(debut,mdp);
	chiffre=concat(chiffre,fin);

	chiffre=encode(chiffre);
	
	return ([chiffre,fin]);
	}

\\ On utilise la méthode zncoppersmith

chiffre_message(n,e,message)={
	    [c,f]=get_struct();
	    padding=128^(#f)*unknown;
	    p = (c + padding)^e;

	    \\ on recherche une chaîne de longueur 10 caractères en base 128

	    k= 128^10;
	    return (zncoppersmith(p - message,n,k));
	    }

print_solution (mdp) = {
 	    print("Cher collaborateur, votre nouveau mot de passe est ",
 	    mdp, 
 	    " Merci de votre comprehension, le service informatique.");
  	    }
  
text = readvec("input.txt");
n = text[1][1];
e = text[1][2];
mail = text[2];
vec_cop= chiffre_message(n, e, mail);
solution=decode(vec_cop[1]);
print_solution(solution);
