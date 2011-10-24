# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

my ($count, $message, $setting, $aubbc, $Current_version, %msg) =
 (1, '[[br]]', '', '', '', (1 => 'Test good ', 2 => 'Test error ',) );

BEGIN {
 $| = 1;
 print "Test's 1 to 4\n";
}

use AUBBC2;
$aubbc = AUBBC2->new();
{
 # did it load?
 #$aubbc = ''; # main reinforce failure
 $aubbc
  ? print $msg{1} . "$count\n"
  : print $msg{2} . "$count\n";

 if ($aubbc) {
  $aubbc->add_settings(html_type => 'xhtml');
  $message = $aubbc->parse_bbcode($message);
  $setting = $aubbc->get_setting('html_type');
  $Current_version = $aubbc->version();
 }
 $count++;
 
 # did it convert?
 #$message = ']'; # reinforce failure
 $message =~ m/&/
  ? print $msg{1} . "$count\n"
  : print $msg{2} . "$count\n";
}

END {
 $count++;
 # did we get a setting?
 #$setting = 5; # reinforce failure
 $setting eq ' /'
  ? print $msg{1} . "$count\n"
  : print $msg{2} . "$count\n";

  $count++;
 # did we get the version?
 #$Current_version = 5; # reinforce failure
 $Current_version eq '1.00a5'
  ? print $msg{1} . "$count\n"
  : print $msg{2} . "$count\n";
}
