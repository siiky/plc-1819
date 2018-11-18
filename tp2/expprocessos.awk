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
$6 ~ /,\<avo\>([ ]+[mp]atern[oa]s?)?\./        { alC["avo"]++; }
$6 ~ /,\<irmaos?\>\./                          { alC["irmao"]++; }
$6 ~ /,\<irmas?\>\./                           { alC["irma"]++; }
$6 ~ /,\<mae\>\./                              { alC["mae"]++; }
$6 ~ /,\<madrastas?\>\./                       { alC["madrasta"]++; }
$6 ~ /,\<padrastos?\>\./                       { alC["padrasto"]++; }
$6 ~ /,\<madrinhas?\>\./                       { alC["madrinha"]++; }
$6 ~ /,\<padrinhos?\>\./                       { alC["padrinho"]++; }
$6 ~ /,\<pai\>\./                              { alC["pai"]++; }
$6 ~ /,\<primas?\>([ ]+[mp]atern[oa]s?)?\./    { alC["prima"]++; }
$6 ~ /,\<primos?\>([ ]+[mp]atern[oa]s?)?\./    { alC["primo"]++; }
$6 ~ /,\<sobrinhas?\>([ ]+[mp]atern[oa]s?)?\./ { alC["sobrinha"]++; }
$6 ~ /,\<sobrinhos?\>([ ]+[mp]atern[oa]s?)?\./ { alC["sobrinho"]++; }
$6 ~ /,\<tias?\>([ ]+[mp]atern[oa]s?)?\./      { alC["tia"]++; }
$6 ~ /,\<tios?\>([ ]+[mp]atern[oa]s?)?\./      { alC["tio"]++; }


function alineaA (outf)
{
    printf "Frequencia de processos por ano:\n" > outf;
    for (ano in alA)
        printf("%s\t%s\n", ano, alA[ano]) >> outf;
}

function alineaB (outf)
{
    printf "Frequencia de nomes:\n" > outf;
    for (nome in alB)
        printf("%s\t%s\n", nome, alB[nome]) >> outf;
}

function alineaC (outf)
{
    printf "Frequencia dos varios tipos de relacao:\n" > outf;
    for (parentesco in alC)
        printf("%s\t%s\n", parentesco, alC[parentesco]) >> outf;
}

END {
    alineaA("anos.txt");
    alineaB("nomes.txt");
    alineaC("parentescos.txt");
}
