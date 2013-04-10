#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AutomatedAnnotation::ParseGenesFromGFFs');
}

my $obj;

ok(
    $obj = Bio::AutomatedAnnotation::ParseGenesFromGFFs->new(
        gff_files     => ['t/data/example_annotation.gff'],
        search_query => 'yfnB'
    ),
    'initialise obj with all defaults'
);
is($obj->output_file, 'output.yfnB.fa', 'create outputfilename');
ok($obj->create_fasta_file, 'Create a fasta file');
is(read_file('output.yfnB.fa'), read_file('t/data/expected_output.yfnB.fa'), 'output fasta is as expected');
unlink('output.yfnB.fa');



ok(
    $obj = Bio::AutomatedAnnotation::ParseGenesFromGFFs->new(
        gff_files     => ['t/data/example_annotation.gff'],
        search_query => 'hypothetical'
    ),
    'initialise obj with all defaults for hypothetical proteins'
);
is($obj->output_file, 'output.hypothetical.fa', 'create outputfilename');
ok($obj->create_fasta_file, 'Create a fasta file containing all hypothetical proteins');
is(read_file('output.hypothetical.fa'), read_file('t/data/expected_output.hypothetical.fa'), 'output fasta is as expected with all hypothetical proteins');
unlink('output.hypothetical.fa');

done_testing();
