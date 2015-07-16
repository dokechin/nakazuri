use strict;
use warnings;
use Imager::DTP::Textbox::Horizontal;
use Imager::DTP::Textbox::Vertical;
use URI;
use Digest::MD5 qw/md5_hex/;
use Config::PL;
use Furl;
use Encode qw/decode/;
use utf8;
$|=1;

my $config = config_do 'config.pl';

#get_icon_images($config);
make_cyuzuri($config);

sub make_cyuzuri {

    my $output = 'output.png';

    # IPA Pゴシックフォントをオブジェクト化
    my $black = Imager::Color->new("#000000");
    my $font = Imager::Font->new( file => 'ipagp.ttf' ,color => $black, size=> 64);

    my $named_img = Imager->new(xsize => 1280, ysize => 960);
    $named_img->box(filled => 1, color => 'white');

    # create textbox instance
    my $tb = Imager::DTP::Textbox::Vertical->new(
        text=> decode("utf-8", $config->{left}->{title}),font=>$font, wrapWidth=>128, wrapHeight=>800);
            
    $tb->draw(target=>$named_img,x=>70,y=>20);

    $tb = Imager::DTP::Textbox::Vertical->new(
        text=> decode("utf-8", $config->{right}->{title}),font=>$font, wrapWidth=>128, wrapHeight=>800);
            
    $tb->draw(target=>$named_img,x=>1168,y=>20);

    $tb = Imager::DTP::Textbox::Horizontal->new(
        text=> decode("utf-8", $config->{title}),font=>$font, wrapWidth=>500, wrapHeight=>1280);
            
    $tb->draw(target=>$named_img,x=>312,y=>800);

    my $file = md5_hex($config->{left}->{icon}) . ".png";
    my $img = Imager->new(file=> $file);
    $named_img->paste(left=>13, top=>800, src=>$img);

    $file = md5_hex($config->{right}->{icon}) . ".png";
    $img = Imager->new(file=> $file);
    $named_img->paste(left=>1088, top=>800, src=>$img);

    $named_img->write(file=> $output);

}

sub get_icon_image{

    my $url = shift;
    my $size = shift || 1; # 1:small(default) 2:large

    my $furl = Furl->new;

    my $res = $furl->get( $url );
    unless ( $res->is_success ) {
        die "Can't download $url\n";
    }

    my $file = md5_hex($url) . ".png";

    my $img = Imager->new();
    $img->read(data=> $res->content);

    my $xpixcels = 96;
    my $ypixcels = 96;
    if ($size == 2){
        my $xpixcels = 136;
        my $ypixcels = 136;
    }

    $img = $img->scale(xpixels=> $xpixcels, ypixels=> $ypixcels);

    $img->write(file=>$file);

}

sub get_icon_images {

    my $config = shift;

    get_icon_image($config->{left}->{icon}, 2);
    get_icon_image($config->{right}->{icon}, 2);

    for my $middle(@{$config->{middles}}){
      get_icon_image($middle->{icon});
    }
}

