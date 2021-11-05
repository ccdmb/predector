#!/usr/bin/env Rscript

VALID_TAXON = c("bacteria", "fungi", "oomycete")

suppressPackageStartupMessages(library("optparse"))
suppressPackageStartupMessages(library("deepredeff"))

VERSION = packageVersion("deepredeff")


option_list <- list(
    make_option(
        c("-i", "--infile"),
        type="character",
        action="store",
        help="The input aligned fasta (required)."
    ),
    make_option(
        c("-o", "--outfile"),
        type="character",
        action="store",
	default="",
        help="The output file to write to (default: stdout)."
    ),
    make_option(
        "--version",
        type="logical",
        action="store_true",
        default=FALSE,
        help="Print version and exit.",
    )
)

parser <- OptionParser(
    usage = "%prog --infile in.fasta --outfile out.fasta",
    option_list = option_list
)

args <- parse_args(parser)

log_stderr <- function(...) {
  cat(sprintf(...), sep='', file=stderr())
}

quit_with_err <- function(...) {
  log_stderr(...)
  quit(save = "no", status = 1, runLast = FALSE)
}

validate_file <- function(path) {
  if (is.null(path)) {
    quit_with_err("Please provide required file")
  }
}


main <- function(args) {
  if (args$version) {
    cat(VERSION, file=stdout())
    quit(save = "no", status = 0, runLast = FALSE)
  }

  if (!args$taxon %in% VALID_TAXON) {
    quit_with_err(paste(c("--taxon must be one of", paste(VALID_TAXON, collapse = ", "))))
  }

  validate_file(args$infile)
  validate_file(args$outfile)

  seqs = fasta_to_df(args$infile)

  capture.output(pred_result <- predict_effector(input = seqs, taxon = args$taxon))

  write.table(pred_result[, c("name", "s_score", "prediction")], file = args$outfile, sep = "\t", quote = FALSE, row.names = FALSE)
}

main(args)
