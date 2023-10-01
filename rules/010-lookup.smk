import pandas as pd

# Here, each input filepath is determined by a hard-coded TSV file. The
# alternative is to dynamically search a set of given directories. I prefer
# hard-coded paths over the dynamic search strategy, because when the input
# file no longer exists (e.g. the FASTQ file was deleted), the hard-coded
# strategy still gives the same filepath whereas the dynamic search returns
# a changed set of files (from a non-zero to zero set of FASTQ files). For the
# dynamic search strategy, this causes the pipeline to re-run if you ever move
# the FASTQ files.

def look_up(lookup, query_column, query_value, db_column, expected_size):
    query_list = lookup[query_column].tolist()
    query_i_hits = [ i for i, x in enumerate(query_list) if x == query_value ]
    db_list = lookup[db_column].tolist()
    db_hits = [ db_list[i] for i in query_i_hits ]
    db_hits_unique = list(set(db_hits))
    assert len(db_hits_unique) == expected_size, \
        f"Actual size == {len(db_hits_unique)} != expected size {expected_size}"
    return db_hits_unique

lookup = pd.read_csv(config["lookup_fp"], delimiter="\t")
get_fqs_for_read_group = lambda read_group: \
    look_up(lookup, "READ_GROUP", read_group, "FQ_FILEPATH", 2)
get_sample_name_for_read_group = lambda read_group: \
    look_up(lookup, "READ_GROUP", read_group, "SAMPLE_NAME", 1)[0]
get_library_name_for_read_group = lambda read_group: \
    look_up(lookup, "READ_GROUP", read_group, "LIBRARY_NAME", 1)[0]
get_platform_unit_for_read_group = lambda read_group: \
    look_up(lookup, "READ_GROUP", read_group, "PLATFORM_UNIT", 1)[0]
get_platform_for_read_group = lambda read_group: \
    look_up(lookup, "READ_GROUP", read_group, "PLATFORM", 1)[0]
