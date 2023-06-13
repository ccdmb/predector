// Find the versions of each required tool.
// Will fail if any of the required software are missing.
workflow check_env {

    main:
    signalp3 = get_signalp3_version()
    signalp4 = get_signalp4_version()
    signalp5 = get_signalp5_version()
    if ( params.no_signalp6 ) {
        signalp6 = false
    } else {
        signalp6 = get_signalp6_version()
    }
    targetp2 = get_targetp2_version()
    tmhmm2 = get_tmhmm2_version()
    deeploc1 = get_deeploc1_version()
    phobius = get_phobius_version()
    effectorp1 = get_effectorp1_version()
    effectorp2 = get_effectorp2_version()
    effectorp3 = get_effectorp3_version()
    localizer = get_localizer_version()
    apoplastp = get_apoplastp_version()
    deepsig = get_deepsig_version()
    emboss = get_emboss_version()
    mmseqs2 = get_mmseqs2_version()
    hmmer = get_hmmer_version()
    deepredeff1 = get_deepredeff_version()
    predutils = get_predutils_version()

    emit:
    signalp3
    signalp4
    signalp5
    signalp6
    targetp2
    tmhmm2
    deeploc1
    phobius
    effectorp1
    effectorp2
    effectorp3
    localizer
    apoplastp
    deepsig
    emboss
    mmseqs2
    hmmer
    deepredeff1
    predutils
}


process get_signalp3_version {

    label 'signalp3'

    output:
    env VERSION

    script:
    """
    if ! which signalp3 > /dev/null
    then
        echo -e "Could not find the program 'signalp3' in your environment path.\n" 1>&2

        if which signalp > /dev/null
        then
            echo "You do have 'signalp' installed, but because we run multiple versions of signalp, we require executables to be available in the format 'signalp3', 'signalp4', 'signalp5' etc." 1>&2
        fi

        echo "Please either link signalp to signalp3 or install signalp using the conda environment." 1>&2

        exit 127
    fi

    VERSION=\$(signalp3 -v | sed 's/\\([^,]*\\).*/\\1/')
    """
}


process get_signalp4_version {

    label 'signalp4'

    output:
    env VERSION

    script:
    """
    if ! which signalp4 > /dev/null
    then
        echo -e "Could not find the program 'signalp4' in your environment path.\n" 1>&2

        if which signalp > /dev/null
        then
            echo "You do have 'signalp' installed, but because we run multiple versions of signalp, we require executables to be available in the format 'signalp3', 'signalp4', 'signalp5' etc." 1>&2
        fi

        echo "Please either link signalp to signalp4 or install signalp using the conda environment." 1>&2

        exit 127
    fi

    VERSION=\$(signalp4 -V | sed 's/^signalp //')
    """
}


process get_signalp5_version {

    label 'signalp5'

    output:
    env VERSION

    script:
    """
    if ! which signalp5 > /dev/null
    then
        echo -e "Could not find the program 'signalp5' in your environment path.\n" 1>&2

        if which signalp > /dev/null
        then
            echo "You do have 'signalp' installed, but because we run multiple versions of signalp, we require executables to be available in the format 'signalp3', 'signalp4', 'signalp5' etc." 1>&2
        fi

        echo "Please either link signalp to signalp5 or install signalp using the conda environment." 1>&2

        exit 127
    fi

    # signalp -version returns exitcode 1
    VERSION="\$(signalp5 -version || [ \$? -eq 1 ] )"
    VERSION="\$(echo "\${VERSION}" | sed 's/.*\\([[:digit:]]\\.[0-9a-zA-Z]*\\).*/\\1/')"
    """
}

process get_signalp6_version {

    label 'signalp6'

    output:
    env VERSION

    script:
    """
    if ! which signalp6 > /dev/null
    then
        echo -e "Could not find the program 'signalp6' in your environment path.\n" 1>&2

        if which signalp > /dev/null
        then
            echo "You do have 'signalp' installed, but because we run multiple versions of signalp, we require executables to be available in the format 'signalp3', 'signalp4', 'signalp5', 'signalp6' etc." 1>&2
        fi

        echo "Please either link signalp to signalp6 or install signalp using the conda environment." 1>&2
        VERSION="false"
    elif grep -qL "Due to license restrictions, this recipe cannot distribute signalp6 directly" <(signalp6 || :)
    then
        VERSION="false"
    else
        VERSION="\$(python3 -c 'import signalp; print(signalp.__version__)' 2> /dev/null || :)"

        # This shouldn't happen but I might as well
        if [ -z "\${VERSION:-}" ]
        then
            VERSION="\$(signalp6 -h | head -n 1 | sed -E 's/^[^[:digit:]]*([[:digit:]]+\\.?[^[:space:],;:]*).*\$/\\1/')"
        fi
    fi
    """
}


process get_targetp2_version {

    label 'targetp2'

    output:
    env VERSION

    script:
    """
    if ! ( which targetp || which targetp2 ) > /dev/null
    then
        echo -e "Could not find the program 'targetp' or 'targetp2' in your environment path.\n" 1>&2
        echo "Please install targetp version 2." 1>&2

        exit 127
    fi

    if ! which targetp
    then
        alias target=targetp2
    fi

    # Targetp version returns exitcode 1
    VERSION="\$(targetp -version || [ \$? -eq 1 ])"
    VERSION="\$(echo "\${VERSION}" | sed 's/.*\\([[:digit:]]\\.[0-9a-zA-Z]*\\).*/\\1/')"
    """
}


process get_tmhmm2_version {

    label 'tmhmm'

    output:
    env VERSION

    script:
    """
    if ! ( which tmhmm || which tmhmm2 ) > /dev/null
    then
        echo -e "Could not find the program 'tmhmm' or 'tmhmm2' in your environment path.\n" 1>&2
        echo "Please install TMHMM version 2." 1>&2

        exit 127
    fi

    if ! which tmhmm
    then
        alias tmhmm=tmhmm2
    fi

    VERSION=\$(grep '# This is version' "\$(which tmhmm)" \
             | sed 's/# This is version \\([^[:space:]]*\\).*\$/\\1/')
    """

}


process get_deeploc1_version {

    label 'deeploc'

    output:
    env VERSION

    script:
    """
    if ! which deeploc > /dev/null
    then
        echo -e "Could not find the program 'deeploc' in your environment path.\n" 1>&2
        echo "Please install deeploc version 1." 1>&2

        exit 127
    fi

    # (python3 -m pip freeze | grep "DeepLoc" | sed "s/.*DeepLoc==//")
    # I don't have a good general way of getting this info.
    # The pip freeze method does weird things in conda environments.
    VERSION=1.0
    """
}


process get_phobius_version {

    label 'phobius'

    output:
    env VERSION

    script:
    """
    if ! which phobius.pl > /dev/null
    then
        echo -e "Could not find the program 'phobius.pl' in your environment path.\n" 1>&2
        echo "Please install Phobius version 1." 1>&2

        exit 127
    fi

    VERSION="\$(phobius.pl --help 2>&1 | sed -n '1 s/Phobius ver[[:space:]]*//p')"
    """
}


process get_effectorp1_version {

    label 'effectorp1'

    output:
    env VERSION

    script:
    """
    if ! which EffectorP1.py > /dev/null
    then
        echo -e "Could not find the program 'EffectorP1.py' in your environment path.\n" 1>&2

        if which EffectorP.py > /dev/null
        then
            echo "You do have 'EffectorP.py' installed, but because we run multiple versions of EffectorP, we require executables to be available in the format 'EffectorP1.py' and 'EffectorP2.py' etc." 1>&2
        fi

        echo "Please either link EffectorP.py to EffectorP1.py or install EffectorP1 using the conda environment." 1>&2

        exit 127
    fi

    if ! which EffectorP1.py
    then
        alias EffectorP1.py=EffectorP.py
    fi

    VERSION=\$(EffectorP1.py -h | grep "^# EffectorP [[:digit:]]" | sed 's/^# EffectorP \\([[:digit:]]*\\.*[^[:space:]]*\\).*\$/\\1/')
    """
}


process get_effectorp2_version {

    label 'effectorp2'

    output:
    env VERSION

    script:
    """
    if ! which EffectorP2.py > /dev/null
    then
        echo -e "Could not find the program 'EffectorP2.py' in your environment path.\n" 1>&2

        if which EffectorP.py > /dev/null
        then
            echo "You do have 'EffectorP.py' installed, but because we run multiple versions of EffectorP, we require executables to be available in the format 'EffectorP1.py' and 'EffectorP2.py' etc." 1>&2
        fi

        echo "Please either link EffectorP.py to EffectorP2.py or install EffectorP2 using the conda environment." 1>&2

        exit 127
    fi

    if ! which EffectorP2.py
    then
        alias EffectorP2.py=EffectorP.py
    fi

    VERSION=\$(EffectorP2.py -h | grep "^# EffectorP [[:digit:]]" | sed 's/^# EffectorP \\([[:digit:]]*\\.*[^[:space:]]*\\).*\$/\\1/')
    """
}


process get_effectorp3_version {

    label 'effectorp3'

    output:
    env VERSION

    script:
    """
    if ! which EffectorP3.py > /dev/null
    then
        echo -e "Could not find the program 'EffectorP3.py' in your environment path.\n" 1>&2

        if which EffectorP.py > /dev/null
        then
            echo "You do have 'EffectorP.py' installed, but because we run multiple versions of EffectorP, we require executables to be available in the format 'EffectorP2.py' and 'EffectorP3.py' etc." 1>&2
        fi

        echo "Please either link EffectorP.py to EffectorP3.py or install EffectorP3 using the conda environment." 1>&2

        exit 127
    fi

    if ! which EffectorP3.py
    then
        alias EffectorP3.py=EffectorP.py
    fi

    VERSION=\$(EffectorP3.py -h | grep "^# EffectorP [[:digit:]]" | sed 's/^# EffectorP \\([[:digit:]]*\\.*[^[:space:];:,]*\\).*\$/\\1/')
    """
}

process get_localizer_version {

    label 'localizer'

    output:
    env VERSION

    script:
    """
    if ! which LOCALIZER.py > /dev/null
    then
        echo -e "Could not find the program 'LOCALIZER.py' in your environment path.\n" 1>&2

        echo "Please install LOCALIZER using the conda environment." 1>&2

        exit 127
    fi

    VERSION=\$(LOCALIZER.py -h | grep "^# LOCALIZER [[:digit:]]" | sed 's/^# LOCALIZER \\([[:digit:]]*\\.*[^[:space:]]*\\).*\$/\\1/')
    """
}


process get_apoplastp_version {

    label 'apoplastp'

    output:
    env VERSION

    script:
    """
    if ! which ApoplastP.py > /dev/null
    then
        echo -e "Could not find the program 'ApoplastP.py' in your environment path.\n" 1>&2

        echo "Please install ApoplastP using the conda environment." 1>&2

        exit 127
    fi

    VERSION=\$(ApoplastP.py -h | grep "^# ApoplastP [[:digit:]]" | sed 's/^# ApoplastP \\([[:digit:]]*\\.*[^[:space:]]*\\).*\$/\\1/')
    """
}


process get_deepsig_version {

    label 'deepsig'

    output:
    env VERSION

    script:
    """
    if ! which deepsig.py > /dev/null
    then
        echo -e "Could not find the program 'deepsig.py' in your environment path.\n" 1>&2

        echo "Please install deepsig using the conda environment." 1>&2

        exit 127
    fi

    # Deepsig doesn't distribute any version information, so we have to hard code it for now.
    VERSION="0f1e1d9"
    """
}


process get_emboss_version {

    label 'emboss'

    output:
    env VERSION

    script:
    """
    if ! which pepstats > /dev/null
    then
        echo -e "Could not find the program 'pepstats' in your environment path.\n" 1>&2

        echo "Please install EMBOSS using the conda environment." 1>&2

        exit 127
    fi

    VERSION="\$(pepstats -help 2>&1 | grep 'Version:' | sed 's/^Version: EMBOSS:\\([^[:space:]]*\\).*\$/\\1/')"
    """
}


process get_mmseqs2_version {

    label 'mmseqs2'

    output:
    env VERSION

    script:
    """
    if ! which mmseqs > /dev/null
    then
        echo -e "Could not find the program 'mmseqs' in your environment path.\n" 1>&2

        echo "Please install mmseqs2 using the conda environment." 1>&2

        exit 127
    fi

    VERSION="\$(mmseqs version)"
    """
}


process get_hmmer_version {

    label 'hmmer'

    output:
    env VERSION

    script:
    """
    if ! which hmmscan > /dev/null
    then
        echo -e "Could not find the program 'hmmscan' in your environment path.\n" 1>&2

        echo "Please install HMMER v3 using the conda environment." 1>&2

        exit 127
    fi

    VERSION="\$(hmmsearch -h | grep "# HMMER [[:digit:]]" | sed 's/^# HMMER \\([[:digit:]]*\\.*[^[:space:]]*\\).*\$/\\1/')"
    """
}


process get_deepredeff_version {

    label 'deepredeff'

    output:
    env VERSION

    script:
    """
    VERSION="\$(deepredeff --version | cut -d' ' -f 2)"
    """
}


process get_predutils_version {

    label "predectorutils"

    output:
    env VERSION

    script:
    """
    VERSION="\$(predutils --version)"
    """
}
