
process get_signalp3_version {

    label 'signalp3'

    output:
    env VERSION

    script:
    """
    VERSION=$(signalp3 -v | sed 's/\\([^,]*\\).*/\\1/')
    """
}


process get_signalp4_version {

    label 'signalp4'

    output:
    env VERSION

    script:
    """
    VERSION=$(signalp4 -V | sed 's/^signalp //')
    """
}


process get_signalp5_version {

    label 'signalp5'

    output:
    env VERSION

    script:
    """
    VERSION=\$(signalp5 -version | sed 's/.*\\([[:digit:]]\\.[0-9a-zA-Z]*\\).*/\\1/')
    """
}


process get_targetp2_version {

    label 'signalp2'

    output:
    env VERSION

    script:
    """
    VERSION=\$(targetp2 -version | sed 's/.*\\([[:digit:]]\\.[0-9a-zA-Z]*\\).*/\\1/')
    """
}


process get_tmhmm2_version {

    label 'tmhmm'

    output:
    env VERSION

    script:
    """
    VERSION=\$(grep '# This is version' "\$(which tmhmm)" \
             | sed 's/# This is version \\([^[:space:]]*\\).*\$/\\1/')
    """

}


process get_deeploc1_version {

    label 'tmhmm'

    output:
    env VERSION

    script:
    """
    VERSION=\$(python3 -m pip freeze | grep "DeepLoc" | sed "s/.*DeepLoc==//")
    """
}


process get_phobius_version {

    label 'phobius'

    output:
    env VERSION

    scripts:
    """
    VERSION=\$(phobius.pl -h 2>&1 | head -n1 | sed 's/Phobius ver[[:space:]]*//')
    """
}
