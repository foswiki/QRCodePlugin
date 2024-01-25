# Plugin for Foswiki - The Free and Open Source Wiki, https://foswiki.org/
#
# QRCodePlugin is Copyright (C) 2018-2024 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Plugins::QRCodePlugin;

use strict;
use warnings;

use Foswiki::Func ();

our $VERSION = '1.02';
our $RELEASE = '%$RELEASE%';
our $SHORTDESCRIPTION = 'QR code generator';
our $LICENSECODE = '%$LICENSECODE%';
our $NO_PREFS_IN_TOPIC = 1;
our $core;

sub initPlugin {

  Foswiki::Func::registerTagHandler('QRCODE', sub { return getCore()->QRCODE(@_); });

  Foswiki::Func::registerRESTHandler('encode', sub { return getCore()->restQRCODE(@_); },
    authenticate => 0,
    validate => 0,
    http_allow => 'GET,POST',
  );

  return 1;
}

sub getCore {
  unless (defined $core) {
    require Foswiki::Plugins::QRCodePlugin::Core;
    $core = Foswiki::Plugins::QRCodePlugin::Core->new();
  }
  return $core;
}

sub finishPlugin {
  undef $core;
}

1;
