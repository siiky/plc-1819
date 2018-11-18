BEGIN {
    FS="::";
    IGNORECASE=1
}

/^\s*$/ { next; }

{ # Alinea (a)
    split($2, data, /-/);
    alA[data[1]]++;
}

{ # Alinea (b)
    for (i = 3; i < 6; i++) {
        # Tirar Expostos/Solteiras/etc
        gsub(/,.*$/, "", $i);

        split($i, nomes, /\s+/);

        for (nome in nomes)
            alB[nomes[nome]]++;
    }
}

# Alinea (c)
$6 ~ /,\<amantes?\>([ ]+[mp]atern[oa]s?)?\./   { alC["amante"]++; }
$6 ~ /,\<avo\>([ ]+[mp]atern[oa]s?)?\./        { alC["avo"]++; }
$6 ~ /,\<irmaos?\>([ ]+[mp]atern[oa]s?)?\./    { alC["irmao"]++; }
$6 ~ /,\<irmas?\>([ ]+[mp]atern[oa]s?)?\./     { alC["irma"]++; }
$6 ~ /,\<maes?\>([ ]+[mp]atern[oa]s?)?\./      { alC["mae"]++; }
$6 ~ /,\<madrastas?\>([ ]+[mp]atern[oa]s?)?\./ { alC["madrasta"]++; }
$6 ~ /,\<padrastos?\>([ ]+[mp]atern[oa]s?)?\./ { alC["padrasto"]++; }
$6 ~ /,\<madrinhas?\>([ ]+[mp]atern[oa]s?)?\./ { alC["madrinha"]++; }
$6 ~ /,\<padrinhos?\>([ ]+[mp]atern[oa]s?)?\./ { alC["padrinho"]++; }
$6 ~ /,\<pais?\>([ ]+[mp]atern[oa]s?)?\./      { alC["pai"]++; }
$6 ~ /,\<primas?\>([ ]+[mp]atern[oa]s?)?\./    { alC["prima"]++; }
$6 ~ /,\<primos?\>([ ]+[mp]atern[oa]s?)?\./    { alC["primo"]++; }
$6 ~ /,\<sobrinhas?\>([ ]+[mp]atern[oa]s?)?\./ { alC["sobrinha"]++; }
$6 ~ /,\<sobrinhos?\>([ ]+[mp]atern[oa]s?)?\./ { alC["sobrinho"]++; }
$6 ~ /,\<tias?\>([ ]+[mp]atern[oa]s?)?\./      { alC["tia"]++; }
$6 ~ /,\<tios?\>([ ]+[mp]atern[oa]s?)?\./      { alC["tio"]++; }

function alineaA (outf)
{
    printf "" > outf;
    for (ano in alA)
        printf("%s\t%s\n", ano, alA[ano]) >> outf;
}

function alineaB (outf)
{
    printf "" > outf;
    for (nome in alB)
        printf("%s\t%s\n", nome, alB[nome]) >> outf;
}

function alineaC (outf)
{
    printf "" > outf;
    for (parentesco in alC)
        printf("%s\t%s\n", parentesco, alC[parentesco]) >> outf;
}

END {
    alineaA("anos.txt");
    alineaB("nomes.txt");
    alineaC("parentescos.txt");
}
