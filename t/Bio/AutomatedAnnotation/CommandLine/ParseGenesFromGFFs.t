#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;
use File::Find;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AutomatedAnnotation::CommandLine::ParseGenesFromGFFs');
}

my $obj;

my $script_name = 'Bio::AutomatedAnnotation::CommandLine::ParseGenesFromGFFs';

my %scripts_and_expected_files = (
    '-g yfnB t/data/example_annotation.gff' => [
        'output.yfnB.fa', 't/data/expected_aa_output.yfnB.fa'
    ],
    '-g yfnB -n t/data/example_annotation.gff t/data/empty_annotation.gff' => [
        'output.yfnB.fa', 't/data/expected_output.yfnB.fa'
    ],
    '-g hypothetical -n -p t/data/example_annotation.gff t/data/empty_annotation.gff' => [
        'output.hypothetical.fa', 't/data/expected_output.hypothetical.fa'
    ],
    '-g yfnB -o output_filename.fa t/data/example_annotation.gff t/data/empty_annotation.gff' => [
        'output_filename.fa', 't/data/expected_aa_output.yfnB.fa'
    ],
    '-g 16S -p -n t/data/example_annotation.gff' => [
        'output.16S.fa', 't/data/expected_output.16SribosomalRNA.fa'
    ],
);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();


sub mock_execute_script_and_check_output {
    my ( $script_name, $scripts_and_expected_files ) = @_;
    
    open OLDOUT, '>&STDOUT';
    open OLDERR, '>&STDERR';
    eval("use $script_name ;");
    my $returned_values = 0;
    {
        local *STDOUT;
        open STDOUT, '>/dev/null' or warn "Can't open /dev/null: $!";
        local *STDERR;
        open STDERR, '>/dev/null' or warn "Can't open /dev/null: $!";

        for my $script_parameters ( sort keys %$scripts_and_expected_files ) {
            my $full_script = $script_parameters;
            my @input_args = split( " ", $full_script );

            my $cmd = "$script_name->new(args => \\\@input_args, script_name => '$script_name')->run;";
            eval($cmd);
            my $actual_output_file_name = $scripts_and_expected_files->{$script_parameters}->[0];
            my $expected_output_file_name = $scripts_and_expected_files->{$script_parameters}->[1];
            ok(-e $actual_output_file_name, "Actual output file exists $actual_output_file_name");
            is(read_file($actual_output_file_name), read_file($expected_output_file_name), "Actual and expected output match for '$script_parameters'");
        }
        close STDOUT;
        close STDERR;
    }

    # Restore stdout.
    open STDOUT, '>&OLDOUT' or die "Can't restore stdout: $!";
    open STDERR, '>&OLDERR' or die "Can't restore stderr: $!";

    # Avoid leaks by closing the independent copies.
    close OLDOUT or die "Can't close OLDOUT: $!";
    close OLDERR or die "Can't close OLDERR: $!";
}


