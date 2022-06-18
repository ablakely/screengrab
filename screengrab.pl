#!/usr/bin/perl -w
#
# screengrab.pl: scp screengrabber 
# Version: v1.0
#
# Written by Aaron Blakley <aaron@ephasic.org>
# Copyright 2020-2022 (C) Aaron Blakely
# 
# OS Compatibilty:
#  - Linux
#  - macOS
#  - Windows (requires clip command, strawberry perl, and git-bash)
#
# REQUIREMENTS: 
#  To use this script, it assumes you have several things set up:
#  1. [Linux] You have a working installation of scrot and xclip (optional: 
notify-send)
#  2. You are using pubkey (or some other automated form) authentication for scp
#
# INSTALLING:
#  chmod +x screengrab
#  Place in /usr/local/bin or somewhere else in your $PATH
#
# i3wm config:
#  bindsym Print exec /usr/local/bin/screengrab
#  bindsym Shift+Print exec /usr/local/bin/screengrab -s
#
# macOS Keyboard Shortcuts:
#   For keyboard shortcuts I am using this free software:
#     https://github.com/deseven/icanhazshortcut/releases
#
# Windows (Tested on 7 with strawberry perl and git-bash shell)
#   Save https://archive.ph/DWbeY to %USERPROFILE%
#   Save screengrab.sh, screengrab.bat, screengrab.pl to %USERPROFILE%
#   Create a new shortcut for cmd.exe
#    Name: Screengrab
#     Target: C:\Windows\System32\cmd.exe "/c start /min screengrab.bat"
#     Start In: %USERPROFILE%
#     Shortcut Key: Shift + Prt Scrn (or whatever)
#     Run: Minimized
#
# TODO:
#   Multiple display support.

use strict;
use warnings;
use POSIX qw(strftime);

# ==============[ script config ]===================

my $FILENAME      = '%Y-%m-%d-%T-sc.png'; # see strftime man page for more info
my $LOCAL_DIR     = "~/Pictures/SC/";
my $SCP_SERVER    = "ephasic";
my $SCP_USER      = "aaron";
my $SCP_DIR       = "/home/aaron/public_html/SC";
my $PUBLIC_URL    = "http://ephasic.org/~aaron/SC/";

#==================[ end ]==========================

# resolve ~

my $user = `whoami`; chomp $user;

if ($^O =~ /linux/) {
  $LOCAL_DIR =~ s/\~/\/home\/$user/;
} elsif ($^O =~ /darwin/) {
  $LOCAL_DIR =~ s/\~/\/Users\/$user/;
} elsif ($^O =~ /MSWin32/) {
  my $profile = `echo \%USERPROFILE\%`;
  chomp $profile;
  
  $LOCAL_DIR =~ s/\~/$profile/;
} else {
  die "Unsupported OS!\n";
}

my $PARSEDFN    = strftime($FILENAME, localtime(time));

if ($^O =~ /MSWin32/) {
  $PARSEDFN = time().".png";
}

my $OUTFILE     = $LOCAL_DIR.$PARSEDFN;
my $URL         = $PUBLIC_URL.$PARSEDFN;
my $MODE        = shift;

sub osascript {
  my @tmp = map {("-e '",  $_, "'")} split(/\n/, $_[0]);
  my $prog = "@tmp";

  return `osascript $prog`;
}

sub displayNotification {
  my ($text) = @_;

  if ($^O =~ /linux/) {
    if (-e "/usr/bin/notify-send") {
      system "/usr/bin/notify-send 'screengrab: $text'";
    }
  } elsif ($^O =~ /darwin/) {
osascript <<END;
  display notification "$text" with title "screengrab"
END
  } elsif ($^O =~ /MSWin32/) {
    system "call \%USERPROFILE\%\\ballon \"$text\" Asterisk screengrab";
  }
}

sub copyToClipboard { 
  my ($text) = @_;

  if ($^O =~ /linux/) {
    system "echo '$text' | xclip -sel clip -i";
  } elsif ($^O =~ /darwin/) {
    system "echo '$text' | pbcopy";
  } elsif ($^O =~ /MSWin32/) {
    system "echo $text|clip";
  }
}

sub scpUpload {
  my ($file) = @_;

  if (-e "$OUTFILE") {
    system "scp $OUTFILE $SCP_USER\@$SCP_SERVER:$SCP_DIR/$PARSEDFN";
    copyToClipboard($URL);
    displayNotification("$URL copied to clipboard!");
  } else {
    die "Error: Screenshot was not captured!\n";
  }

  return 1;
}

sub doCapture {
  my ($selectable, $screencount, @filenames) = @_;

  if ($^O eq "linux") {
    if ($selectable) {
      system "sleep 0.2 && scrot -s $OUTFILE";
    } else {
      system "scrot $OUTFILE";
    }
  } elsif ($^O eq "darwin") {
    if ($selectable) {
      system "screencapture -i $OUTFILE";
    } else {
      system "screencapture $OUTFILE";
    }
  } elsif ($^O eq "MSWin32") {
    if ($selectable) {
      die "Interactive mode currently not available on Windows.";
    } else {
      system "call \%USERPROFILE\%\\screenCapture $OUTFILE";
    }
  } else {
    print "Error: Unsupported OS!\n";
    exit;
  }

  unless (!scpUpload()) {
    print "Screenshot uploaded: $URL [$OUTFILE]\n";
  } else {
    die "Error: Something went wrong uploading the screenshot!\n";
  }
}

if ($MODE && $MODE eq "-s") {
  doCapture(1);
} else {
  doCapture(0);
}
