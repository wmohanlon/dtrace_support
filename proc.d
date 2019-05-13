#pragma D option quiet

proc:::exec-success
{
        printf("%s\n", curpsinfo->pr_psargs);
}

