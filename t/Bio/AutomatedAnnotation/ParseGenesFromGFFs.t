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
        search_query => 'yfnB',
        search_qualifiers => [ 'gene', 'product' ]
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
        search_query => 'hypothetical',
        search_qualifiers => [ 'gene', 'product' ]
    ),
    'initialise obj with all defaults for hypothetical proteins'
);
is($obj->output_file, 'output.hypothetical.fa', 'create outputfilename');
ok($obj->create_fasta_file, 'Create a fasta file containing all hypothetical proteins');
is(read_file('output.hypothetical.fa'), read_file('t/data/expected_output.hypothetical.fa'), 'output fasta is as expected with all hypothetical proteins');
unlink('output.hypothetical.fa');

ok(
    $obj = Bio::AutomatedAnnotation::ParseGenesFromGFFs->new(
        gff_files         => ['t/data/example_annotation.gff'],
        search_query      => '16S ribosomal RNA',
        search_qualifiers => [ 'gene', 'product' ]
    ),
    'initialise obj for 16S with spaces'
);
is($obj->output_file, 'output.16SribosomalRNA.fa', 'create outputfilename for search with spaces');
ok($obj->create_fasta_file, 'Create a fasta file containing all hypothetical proteins');
is(read_file('output.16SribosomalRNA.fa'), read_file('t/data/expected_output.16SribosomalRNA.fa'), 'output fasta is as expected with all 16S');
unlink('output.16SribosomalRNA.fa');


ok(
    $obj = Bio::AutomatedAnnotation::ParseGenesFromGFFs->new(
        gff_files         => ['t/data/example_annotation.gff'],
        search_query      => '16S ribosomal RNA',
        search_qualifiers => [ 'gene']
    ),
    'initialise obj where we are only looking for genes not products'
);
ok($obj->create_fasta_file, 'Create an empty fasta file');
is(read_file('output.16SribosomalRNA.fa'), '', 'Create an empty fasta file and check its empty');
unlink('output.16SribosomalRNA.fa');


done_testing();
