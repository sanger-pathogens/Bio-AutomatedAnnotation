package Bio::AutomatedAnnotation;

# ABSTRACT: Prokka class for bacterial annotation

=head1 SYNOPSIS

    Modified prokka from a command line script to a Moose class - Bacterial annotation done fast and NCBI compliant (mostly).
    http://www.vicbioinformatics.com/software.prokka.shtml

  perl prokka --tempdir /tmp --prefix <lane_id> --locustag <> --centre SC --outdir annotation --dbdir /lustre/scratch108/pathogen/pathpipe/prokka --force --contig_uniq_id <ACCESSION> contigs.fa


  wrapper should create annotation in a subdirectory of the assembly and clean up any files not needed.
  Should lookup the accession numbers too
  name it as the lane and accession nubmer



=cut

#    Copyright (C) 2012 Torsten Seemann
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


use Moose;
use File::Copy;
use warnings;
use Time::Piece;
use Time::Seconds;
use XML::Simple;
use List::Util qw(min max sum);
use Scalar::Util qw(openhandle);
use Bio::SeqIO;
use Bio::SearchIO;
use Bio::Seq;
use Bio::SeqFeature::Generic;
use FindBin;
use POSIX;


# $quiet
has 'quiet' => ( is => 'ro', isa => 'Bool', default => 0 );

# $outdir
has 'outdir' => ( is => 'ro', isa => 'Str', default => '' );

# $dbdir
has 'dbdir' => ( is => 'ro', isa => 'Str', default => '/tmp/prokka' );

# $force
has 'force' => ( is => 'ro', isa => 'Bool', default => 0 );

# $prefix
has 'prefix' => ( is => 'ro', isa => 'Str', default => '' );

# $addgenes
has 'addgenes' => ( is => 'ro', isa => 'Bool', default => 0 );

# $locustag
has 'locustag' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_locustag' );

# $increment
has 'increment' => ( is => 'ro', isa => 'Int', default => 1 );

# $gffver
has 'gffver' => ( is => 'ro', isa => 'Int', default => 3 );

# $centre
has 'centre' => ( is => 'ro', isa => 'Str', default => 'VBC' );

# $genus
has 'genus' => ( is => 'ro', isa => 'Str', default => 'Genus' );

# $species
has 'species' => ( is => 'ro', isa => 'Str', default => 'species' );

# $strain
has 'strain' => ( is => 'ro', isa => 'Str', default => 'strain' );

# $contig_uniq_id
has 'contig_uniq_id' => ( is => 'ro', isa => 'Str', default => 'gnl' );

# $kingdom
has 'kingdom' => ( is => 'ro', isa => 'Str', default => 'Bacteria' );

# $gcode
has 'gcode' => ( is => 'ro', isa => 'Int', default => 0 );

# $gram
has 'gram' => ( is => 'ro', isa => 'Str', default => '' );

# $usegenus
has 'usegenus' => ( is => 'ro', isa => 'Bool', default => 0 );

# $proteins
has 'proteins' => ( is => 'ro', isa => 'Str', default => '' );

# $fast
has 'fast' => ( is => 'ro', isa => 'Bool', default => 0 );

# $cpus
has 'cpus' => ( is => 'ro', isa => 'Int', default => 0 );

# $mincontig
has 'mincontig' => ( is => 'ro', isa => 'Int', default => 200 );

# $evalue
has 'evalue' => ( is => 'ro', isa => 'Num', default => 1E-6 );

# $rfam
has 'rfam' => ( is => 'ro', isa => 'Bool', default => 0 );

# $files_per_chunk
has 'files_per_chunk' => ( is => 'ro', isa => 'Int', default => 10 );

# $tempdir
has 'tempdir' => ( is => 'ro', isa => 'Str', default => '/tmp' );


# $EXE
has 'exe' => ( is => 'ro', isa => 'Str', default => 'PROKKA' );

# $VERSION
has 'version' => ( is => 'ro', isa => 'Str', default => '1.5' );

# $AUTHOR
has 'author' => ( is => 'ro', isa => 'Str', default => 'Torsten Seemann <torsten.seemann@monash.edu>' );

# $URL
has 'url' => ( is => 'ro', isa => 'Str', default => 'http://www.vicbioinformatics.com' );

# $HYPO 
has 'hypo' => ( is => 'ro', isa => 'Str', default => 'hypothetical protein' );

# $UNANN 
has 'unann' => ( is => 'ro', isa => 'Str', default => 'unannotated protein' );

# $BLASTPCMD 
has 'blastcmd' => ( is => 'ro', isa => 'Str', default => "blastp -query %i -db %d -evalue %e -num_threads 1 -out %o -num_descriptions 1 -num_alignments 1 2>/dev/null" );

# $HMMER3CMD 
has 'hmmer3cmd' => ( is => 'ro', isa => 'Str', default => "hmmscan --noali --notextw --acc -E %e --cpu 1 -o %o %d %i 2>/dev/null" );

# $INFERNALCMD 
has 'infernalcmd' => ( is => 'ro', isa => 'Str', default => "cmscan --noali --notextw --acc -E %e --cpu 1 -o %o %d %i 2>/dev/null" );

# $starttime
has 'starttime' => ( is => 'ro', isa => 'Str', default => {sub{localtime}} );

sub _build_locustag
{
  my($self) = @_;
  return $self->exe;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

