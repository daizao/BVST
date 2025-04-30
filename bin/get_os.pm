#!/usr/bin/perl -w

package get_os;

use strict;
use warnings;

sub which_os{
	my $os= $^O;
	return $os;
}

1;