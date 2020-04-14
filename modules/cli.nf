#!/usr/bin/env nextflow

is_null = { f -> (f == null || f == '') }

/**
 * Raises a generic error if we hit a branch that should be controlled for.
 * This means we fail early rather than some time downstream.
 */
def param_unexpected_error() {
    log.error "We encountered an error while validating input arguments that " +
        "should be possible. Please raise an issue on github or contact the " +
        "authors."
    exit 1
}


/**
 * Convenience function to convert a filepath to a value channel.
 * Expects the filepath to not be empty.
 *
 * @param filepath The path to the file to get a channel for.
 * @return Value channel containing a single file object.
 */
def get_file(filepath) {
    if ( filepath ) {
        handle = Channel.value( file(filepath, checkIfExists: true) )
    } else {
        // The expectation is that you would check that filepath is not false
        // before you use this.
        param_unexpected_error()
    }

    return handle
}
