BEGIN {
    FS="::";
    IGNORECASE=1
}

/^\s*$/ { next; }

{
    split($2, data, /-/);
    alA[data[1]]++;
}

NF > 5 {
    # Alinea (b)
    for (i = 3; i < 6; i++) {
        split($i, nomes, /\s+/);
        for (nome in nomes)
            alB[nomes[nome]]++;
        #alB[$i]++;
    }
}

/\<amantes?\>/   { alC["amante"]++; }
/\<avo\>/        { alC["avo"]++; }
/\<irmaos?\>/    { alC["irmao"]++; }
/\<irmas?\>/     { alC["irma"]++; }
/\<maes?\>/      { alC["mae"]++; }
/\<madrastas?\>/ { alC["madrasta"]++; }
/\<padrastos?\>/ { alC["padrasto"]++; }
/\<madrinhas?\>/ { alC["madrinha"]++; }
/\<padrinhos?\>/ { alC["padrinho"]++; }
/\<pais?\>/      { alC["pai"]++; }
/\<primas?\>/    { alC["prima"]++; }
/\<primos?\>/    { alC["primo"]++; }
/\<sobrinhas?\>/ { alC["sobrinha"]++; }
/\<sobrinhos?\>/ { alC["sobrinho"]++; }
/\<tias?\>/      { alC["tia"]++; }
/\<tios?\>/      { alC["tio"]++; }

function alineaB ()
{
    for (nome in alB)
        printf("%s\t%s\n", nome, alB[nome]);
}

function alineaA ()
{
    for (ano in alA)
        printf("%s\t%s\n", ano, alA[ano]);
}

function alineaC ()
{
    for (parentesco in alC)
        printf("%s\t%s\n", parentesco, alC[parentesco]);
}

END {
    alineaA();
    alineaB();
    alineaC();
}
