
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
    VERSION=$(signalp5 -version | sed 's/.*\\([[:digit:]]\\.[0-9a-zA-Z]*\\).*/\\1/')
    """
}
