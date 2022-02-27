#!/usr/bin/perl

use strict;
use warnings;
use lib qw(/usr/lib/cgi-bin/);
use JSON;
use CGI;
use Data::Dumper;
use Vine;

my $cgi = CGI->new;

print $cgi->header('application/json');

my ($vinetable, $vinedb);

$vinetable = 'facility';
$vinedb = Vine->new({database => 'vine.db' });

my $display_row = return_facilities();
    
my $op = JSON->new->utf8-> pretty(1);
my $json = $op->encode({ data => $display_row });
print $json;
exit();

        
sub return_facilities{
    my $display_row;
    my $display_hash;
    my $cnt = 0;
    my $sql = qq{select * from $vinetable order by name};
    my $sth = $vinedb->do_sql( { sql => $sql } );
    while (my $rec = $sth->fetchrow_hashref() ){
        my $name = $rec->{name};
        push @{$display_row}, $name;
        $cnt++;
    }
    if (!$cnt){
        push @{$display_row}, "no facilities exist";
    }
    return $display_row;
}


sub logit{
    my $msg = shift;
    my $log = "/tmp/debug.log";
    if (! -e $log ){
        `touch $log`;
    }
    open my $f,">>", $log or die " could not open $log - $!";
    print $f "$msg\n";
    close $f;
}
    
    


