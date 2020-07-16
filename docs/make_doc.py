#!/usr/bin/env python3

import sys


def num_hashes(string):
    return len(string) - len(string.lstrip("#"))


def header_to_toc(line):
    nhash = num_hashes(line)
    tag = line.strip("# .")
    link = (
        line
        .lower()
        .strip("# ")
        .replace(".", "")
        .replace("(", "")
        .replace(")", "")
        .replace("[", "")
        .replace("]", "")
        .replace("{", "")
        .replace("}", "")
        .replace("'", "")
        .replace('"', "")
        .replace(':', "")
        .replace(';', "")
        .replace(',', "")
        .replace('#', "")
        .replace('/', "")
        .replace('\\', "")
        .replace('`', "")
        .replace('*', "")
        .replace('!', "")
        .replace('@', "")
        .replace('$', "")
        .replace('%', "")
        .replace('^', "")
        .replace('&', "")
        .replace('_', "")
        .replace('+', "")
        .replace('=', "")
        .replace('|', "")
        .replace('~', "")
        .replace('<', "")
        .replace('>', "")
        .replace('?', "")
        .replace(' ', '-')
    )
    return ("  " * (nhash - 2)) + f"- [{tag}](#{link})"


def main():
    if len(sys.argv) < 2:
        print("Usage: make_doc.py order.md > docs.md")
        sys.exit(0)

    mds = [""]

    with open(sys.argv[1]) as handle:
        for line in handle:
            with open(line.strip()) as md:
                mds.extend(s.rstrip() for s in md.readlines())
                mds.append("")

    toc = ["# Predector", "", "## Table of contents", ""]
    code = False
    for line in mds:

        # This is to avoid comments in code blocks becoming TOC headers.
        if line.startswith('```'):
            code = not code

        elif not code and line.startswith("#"):
            toc.append(header_to_toc(line))

    print("\n".join(toc))
    print("\n".join(mds))
    return


if __name__ == "__main__":
    main()
