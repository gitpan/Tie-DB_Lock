# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..14\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tie::DB_Lock;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

sub report_result {
	$TEST_NUM ||= 2; 
	print ( $_[0] ? "ok $TEST_NUM\n" : "not ok $TEST_NUM\n" );
	$TEST_NUM++;
}

$Tie::DB_Lock::RETRIES = 1;
my $file1 = 'db/db1';
my $file2 = 'db/db2';
unlink $file1;
unlink $file2;

# 2: Create a simple database
&report_result( tie(%hash1, 'Tie::DB_Lock', $file1, 'rw') );

# 3: Put some data in the database
$hash1{one} = 1;
$hash1{two} = 2;
&report_result( $hash1{one} && $hash1{two} );

# 4: Re-open the database
untie %hash1;
&report_result( tie(%hash1, 'Tie::DB_Lock', $file1) );

# 5: Read the database values
&report_result( $hash1{one} eq 1  and  $hash1{two} eq 2);

# 6: Try to open another copy for reading (should work)
&report_result( tie(%hash2, 'Tie::DB_Lock', $file1) );

# 7: Try to open another copy for writing (should work)
&report_result( tie(%hash3, 'Tie::DB_Lock', $file1, 'rw') );

# 8: Try to open another copy for reading (shouldn't work)
&report_result( not tie(%hash4, 'Tie::DB_Lock', $file1) );
untie %hash1;
untie %hash2;
untie %hash3;
untie %hash4;

# 9: Open a copy for writing (should work)
&report_result( tie(%hash1, 'Tie::DB_Lock', $file1, 'rw') );

# 10: Open another copy for reading (shouldn't work)
&report_result( not tie(%hash2, 'Tie::DB_Lock', $file1) );
untie %hash1;
untie %hash2;


# 11: Open a copy for writing (should work)
&report_result( tie(%hash1, 'Tie::DB_Lock', $file1, 'rw') );

# 12: Open another copy for writing (shouldn't work)
&report_result( not tie(%hash2, 'Tie::DB_Lock', $file1. 'rw') );
untie %hash1;
untie %hash2;

# 13: Open a copy for writing (should work)
&report_result( tie(%hash1, 'Tie::DB_Lock', $file1, 'rw') );

# 14: Open a different file for writing (should work)
&report_result( tie(%hash2, 'Tie::DB_Lock', $file2, 'rw') );
untie %hash1;
untie %hash2;


unlink $file1;
unlink $file2;