# Before `make install' is performed this script should be runnable with 
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..15\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tie::DB_Lock;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

sub report_result {
	$TEST_NUM ||= 2; 
	print ( $_[0] ? "ok $TEST_NUM\n" : "not ok $TEST_NUM\n" );
	if ($ENV{TEST_VERBOSE} and not $_[0]) { print "Error is '$!'\n" }
	$TEST_NUM++;
}

$Tie::DB_Lock::TEMPDIR = "/tmp";  # Change this if you can't write to /tmp, or don't want to
$Tie::DB_Lock::RETRIES = 1;
$Tie::DB_Lock::VERBOSE = 1 if $ENV{VERY_VERBOSE};
$ENV{TEST_VERBOSE} = 1 if $ENV{VERY_VERBOSE};

my $file1 = 'db/db1';
my $file2 = 'db/db2';
unlink $file1;
unlink $file2;

# 2: Make sure we can write to the TEMPDIR
{
	my $ok = (-w $Tie::DB_Lock::TEMPDIR and -d $Tie::DB_Lock::TEMPDIR);
	&report_result($ok);
	unless ($ok) {
		die "ERROR: Can't write to tempdir '$Tie::DB_Lock::TEMPDIR'.\n" .
		    "Please change \$Tie::DB_Lock::TEMPDIR in test.pl to a directory\n" .
		    "that you can write to.\n";
	}
}

# 3: Create a simple database
&report_result( tie(%hash1, 'Tie::DB_Lock', $file1, 'rw') );

# 4: Put some data in the database
$hash1{one} = 1;
$hash1{two} = 2;
&report_result( $hash1{one} && $hash1{two} );
untie %hash1;

# 5: Make sure the file exists
&report_result( -e $file1 );

# 6: Re-open the database
&report_result( tie(%hash1, 'Tie::DB_Lock', $file1) );

# 7: Read the database values
&report_result( $hash1{one} eq 1  and  $hash1{two} eq 2);

# 8: Try to open another copy for reading (should work)
&report_result( tie(%hash2, 'Tie::DB_Lock', $file1) );

# 9: Try to open another copy for writing (should work)
&report_result( tie(%hash3, 'Tie::DB_Lock', $file1, 'rw') );

# 10: Try to open another copy for reading (shouldn't work)
&report_result( not tie(%hash4, 'Tie::DB_Lock', $file1) );
untie %hash1;
untie %hash2;
untie %hash3;
untie %hash4;

# 11: Open a copy for writing (should work)
&report_result( tie(%hash1, 'Tie::DB_Lock', $file1, 'rw') );

# 12: Open another copy for reading (shouldn't work)
&report_result( not tie(%hash2, 'Tie::DB_Lock', $file1) );
untie %hash1;
untie %hash2;


# 13: Open a copy for writing (should work)
&report_result( tie(%hash1, 'Tie::DB_Lock', $file1, 'rw') );

# 14: Open another copy for writing (shouldn't work)
&report_result( not tie(%hash2, 'Tie::DB_Lock', $file1, 'rw') );
untie %hash1;
untie %hash2;

# 15: Open a copy for writing (should work)
&report_result( tie(%hash1, 'Tie::DB_Lock', $file1, 'rw') );

# 16: Open a different file for writing (should work)
&report_result( tie(%hash2, 'Tie::DB_Lock', $file2, 'rw') );
untie %hash1;
untie %hash2;


unlink $file1;
unlink $file2;
