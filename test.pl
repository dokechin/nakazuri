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

get_icon_images($config);
make_cyuzuri($config);

sub make_cyuzuri {

    my $output = 'output.png';

    # IPA Pゴシックフォントをオブジェクト化
    my $white = Imager::Color->new("#ffffff");
    my $black = Imager::Color->new("#000000");
    my $font = Imager::Font->new( file => 'ipagp.ttf' ,color => $white, size=> 48);
    my $font_s_b = Imager::Font->new( file => 'ipagp.ttf' ,color => $black, size=> 30);
    my $font_l = Imager::Font->new( file => 'ipaexg.ttf' ,color => $white, size=> 64);
    my $font_m = Imager::Font->new( file => 'ipaexm.ttf' ,color => $white, size=> 64);

    my $named_img = Imager->new(file => "nakazuri.png");

    my $file = md5_hex($config->{left}->{icon}) . ".png";
    my $img = Imager->new(file=> $file);
    $named_img->paste(left=>64, top=>632, src=>$img);

    $file = md5_hex($config->{right}->{icon}) . ".png";
    $img = Imager->new(file=> $file);
    $named_img->paste(left=>832, top=>632, src=>$img);

    # create textbox instance
    my $tb = Imager::DTP::Textbox::Vertical->new(
        text=> decode("utf-8", $config->{left}->{title}),font=>$font_l, wrapWidth=>256, wrapHeight=>640);
            
    $tb->draw(target=>$named_img,x=>200,y=>10);

    $tb = Imager::DTP::Textbox::Vertical->new(
        text=> decode("utf-8", $config->{right}->{title}),font=>$font, wrapWidth=>256, wrapHeight=>640);
            
    $tb->draw(target=>$named_img,x=>900,y=>10);

    my $index = 0;
    for my $middle(@{$config->{middles}}){

         my $file = md5_hex($middle->{icon}) . ".png";
         my $img = Imager->new(file=> $file);
         $named_img->paste(left=>608- ($index * 48), top=> 540, src=>$img);

         $tb = Imager::DTP::Textbox::Vertical->new(
             text=> decode("utf-8", $middle->{title}),font=>$font_s_b, wrapWidth=>64, wrapHeight=>640);
                 
         $tb->draw(target=>$named_img,x=>640 - ($index * 48) ,y=>10);


         $index++;

    }

    $tb = Imager::DTP::Textbox::Horizontal->new(
        text=> decode("utf-8", $config->{title}),font=>$font_m, wrapWidth=>500, wrapHeight=>64);
            
    $tb->draw(target=>$named_img,x=>256,y=>640);

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

    my $xpixcels = 48;
    my $ypixcels = 48;
    if ($size == 2){
        $xpixcels = 160;
        $ypixcels = 160;
    }

    $img = $img->scale(xpixels=> $xpixcels, ypixels=> $ypixcels);

    my $img_dst = $img->convert(
       matrix => [ [ .4, .4, .2 ] ]
    );

    $img_dst->write(file=>$file);

}

sub get_icon_images {

    my $config = shift;

    get_icon_image($config->{left}->{icon}, 2);
    get_icon_image($config->{right}->{icon}, 2);

    for my $middle(@{$config->{middles}}){
      get_icon_image($middle->{icon});
    }
}

