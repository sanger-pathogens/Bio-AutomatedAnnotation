#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AutomatedAnnotation::ParseGenesFromGFF');
}

my $obj;

ok(
    $obj = Bio::AutomatedAnnotation::ParseGenesFromGFF->new(
        gff_file     => 't/data/example_annotation.gff',
        search_query => 'yfnB'
    ),
    'initialise obj with all defaults'
);
is( @{ $obj->matching_features }, 1, 'Should have one matching feature' );
is_deeply( $obj->matching_features->[0]->get_tag_values('gene'), ('yfnB'),
    'Gene Name should match the input sequence' );

ok(
    $obj = Bio::AutomatedAnnotation::ParseGenesFromGFF->new(
        gff_file     => 't/data/example_annotation.gff',
        search_query => '16S'
    ),
    'initialise obj with all defaults for 16S'
);
is_deeply( $obj->matching_features->[0]->get_tag_values('product'),
    ('16S ribosomal RNA'), 'product should be searched as well' );

done_testing();
