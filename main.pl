#!/usr/bin/perl -w
use strict;
use warnings;
use 5.0.010;

my $main_file = open FILE, ">main.org";

sub make_header {
  say FILE <<EOF;
#+OPTIONS: ^:nil
#+OPTIONS: \\n:t
EOF
}

sub build_path {
  my ($dir, $name) = @_;
  $dir =~ s#/$##;
  $dir."/".$name;
}

sub print_sub {
  my ($dir, $deep) = @_;
  my ($dh, $entry);
  $deep++;
  print "dir:$dir deep:$deep\n";
  if (-d $dir) {
    opendir $dh, $dir or die "opendir err $!";
  } else {
    die "not dir $dir";
  }

  my @subs = grep { /^[^\.]/ } readdir $dh;
  @subs = map { build_path $dir, $_ } @subs;
  my @files = grep -T, @subs;
  my @dirs = grep -d, @subs;
  for (@files) {
    $entry = $_;
    $entry =~ s#^./##;
    if (/\.org$/) {
      say FILE "[[".$_."][".$entry."]]";
      next;
    }
  }

  for (@dirs) {
    $entry = $_;
    $entry =~ s#^./##;
    say FILE "*"x$deep." ".$entry;
    print_sub($_, $deep);
  }
  close $dh;
}

# readdir 文件与目录的顺序问题，可能显示不好
# sub print_sub {
#   my ($dir, $deep) = @_;
#   my ($dh, $entry);
#   $deep++;

#   if (-d $dir) {
#     opendir $dh, $dir or die "opendir err $!";
#   } else {
#     die "not dir $dir";
#   }

#   my @subs = grep { /^[^\.]/ } readdir $dh;

#   for (@subs) {
#     $entry = $_ = $dir."/".$_;
#     $entry =~ s#^./##;

#     if ( -f && /\.org$/) {
#       say FILE "[[".$_."][".$entry."]]";
#       next;
#     } elsif ( -d ) {
#       say FILE "*"x$deep." ".$entry;
#       print_sub($_, $deep);
#     }
#   }
#   close $dh;
# }

make_header;
my ($current, $start) = (".", 0);
print_sub($current);

close FILE;
