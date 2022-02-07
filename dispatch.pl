#!/usr/bin/perl

use strict;
use warnings;

use JSON;
use CGI;

my $cgi = CGI->new;

print $cgi->header('application/json;charset=UTF-8');

my ($from,$to);
my $select = $cgi->param('select');
if ($select == 1){
    $from = $cgi->param('from');    
    $to = $cgi->param('to');    
}

my $op = JSON -> new -> utf8 -> pretty(1);
my $json = $op -> encode({
    result => { from => $from, to => $to } 
});
print $json;
