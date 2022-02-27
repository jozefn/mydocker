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


my ($vinedb, $description, $partial_name, $facility, $msg, $user, $password, $queue_job);

$vinedb = Vine->new({database => 'vine.db' });

my $select = $cgi->param('select');

if ($select == 1){
    $partial_name = $cgi->param('partial_name');    
    $facility = $cgi->param('facility');    
    $msg = add_to_queue({ '1'=>$facility, '2'=>$partial_name });
} 
elsif ( $select == 2 ){
    $user = $cgi->param('user_name');
    $password = $cgi->param('password');
    $msg = update_vine_user({ '1'=>$user, '2'=>$password });
    
}
elsif ( $select == 3 ){
    $queue_job = $cgi->param('queue_job');
    $msg = run_queue_job({ job => $queue_job });
}
    
my $op = JSON->new->utf8-> pretty(1);
my $json = $op->encode({ data => $msg });
print $json;
exit();

sub add_to_queue{
    my $args = shift;
    my $msg;
    my @where = ();
    my $sql = ' select id  from queue where facility = ? and partial_name = ?';
    foreach my $k ( sort keys %{$args} ){
        push @where, $args->{$k};
    }
    my $sth = $vinedb->do_sql( { sql => $sql, where =>\@where } );
    my $rec = $sth->fetchrow_hashref();
    unless ($rec->{id}){
        $sql = 'insert into queue (facility, partial_name ) values ( ?, ?)';
        $sth = $vinedb->do_sql( { sql => $sql, where=>\@where } );
        my $new_job_id = $vinedb->last_inserted_id();
        $msg = "New job: $new_job_id added to queue - go to run job to extract from vine";
    }
    return ($msg);
}

sub run_queue_job{
    my $args = shift;
    my $msg = " future code ";
    return $msg;
}

sub update_vine_user{
    my $args = shift;
    my $msg;
    my @where = ();
    my $sql = 'select * from vine_user';
    foreach my $k ( sort keys %{$args} ){
        push @where, $args->{$k};
    }
    my $sth = $vinedb->do_sql( { sql => $sql } );
    my $rec = $sth->fetchrow_hashref();
    unless ($rec->{id}){
        $sql = 'insert into vine_user (user, password ) values (?, ?)';
        $sth = $vinedb->do_sql( { sql => $sql, where=>\@where } );
        $msg = "Vine User and Password have been added";
    } else {
        push @where, $rec->{id};
        $sql = 'update vine_user set user = ?, password = ? where id = ?';
        $sth = $vinedb->do_sql( { sql => $sql, where=>\@where } );
        $msg = "Vine User and Password have been updated";
    }

    return ($msg);
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
    
    


