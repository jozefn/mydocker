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

$vinetable = 'vine_user';
$vinedb = Vine->new({database => 'vine.db' });

    
my $user_rec = return_user_record();

my $op = JSON->new->utf8-> pretty(1);
my $json = $op->encode({ data => $user_rec });
print $json;
exit();

        
sub return_user_record{
    my $display_row;
    my $display_hash;
    my $cnt = 0;
    my $sql = qq{select * from $vinetable};
    my $sth = $vinedb->do_sql( { sql => $sql } );
    return $sth->fetchrow_hashref();
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
    
    


