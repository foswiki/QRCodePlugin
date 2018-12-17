# Plugin for Foswiki - The Free and Open Source Wiki, https://foswiki.org/
#
# QRCodePlugin is Copyright (C) 2018 Michael Daum http://michaeldaumconsulting.com
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

package Foswiki::Plugins::QRCodePlugin::Core;

use strict;
use warnings;

use Foswiki::Func ();
use Image::PNG::QRCode ();
use URI ();

sub new {
  my $class = shift;

  my $this = bless({
    @_
  }, $class);

  return $this;
}

sub QRCODE {
  my ($this, $session, $params, $topic, $web) = @_;

  my $text = $params->{_DEFAULT} || $params->{text} || '';

  if ($text =~ /\$perce?nt/) {
    $text = Foswiki::Func::decodeFormatTokens($text);
    $text = Foswiki::Func::expandCommonVariables($text, $topic, $web);
  }

  my $uri = URI->new ('data:');
  $uri->media_type ('image/png');
  $uri->data($this->plot($text, $params));

  my @class = ();
  push @class, "qrCode";
  push @class, $params->{class} if defined $params->{class};
  my $class = join(" ", @class);

  my $result = $params->{format} || '<img src="$uri" class="$class" />';

  $result =~ s/\$uri/$uri/g;
  $result =~ s/\$class/$class/g;

  return $result;
}

sub restQRCODE {
  my ($this, $session, $subject, $verb, $response) = @_;

  my $request = Foswiki::Func::getRequestObject();
  my $text = $request->param("text");

  my $params = {
    level => $request->param("level") || '',
    scale => $request->param("scale") || '',
    quiet => $request->param("quiet") || '',
  };

  my $data = $this->plot($text, $params);
  $response->header(
    status => 200,
    type => "image/png"
  );

  $response->body($data);

  return "";
}

sub plot {
  my ($this, $text, $params) = @_;

  $params ||= {};

  my $level = $params->{level} // '';
  $level =~ s/(\d+)/$1/;
  $level ||= 1;
  $level = 1 unless $level > 0 && $level < 5;

  my $scale = $params->{scale} // '';
  $scale =~ s/(\d+)/$1/;
  $scale ||= 3;
  $scale = 3 unless $scale > 0 && $scale < 101;

  my $quiet = $params->{quiet} // '';
  $quiet =~ s/(\d+)/$1/;
  $quiet ||= 0;

  return Image::PNG::QRCode::qrpng(
    text => $text,
    level => $level,
    scale => $scale,
    quiet => $quiet,
  );
}

1;
