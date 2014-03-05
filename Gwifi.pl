#!/usr/bin/perl -w
 ###########################################################################
 #            Gwifi.pl version 0.50.0
 #
 #  Thu Apr 14 14:33:04 2005
 #  Copyright  2005  David PIRY
 #  Email klessou@gmail.com
 ###########################################################################
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

use Gtk2 '-init' ;

use strict;
use English;

use constant TRUE	=> 1;
use constant FALSE	=> 0;

my $window = Gtk2::Window->new('toplevel') ;
$window->set_title('Interface de configutation Wifi (iwconfig Gui)');
$window->set_default_size(350,250);

my $essid	= "???"	;
my $mode	= "auto";
my $channel	= 11	;
my $key		= "off"	;
my $interf			;

#Chargement du fichier de configuration
my $commande_file = load_conf();

#Detection de l'interface Wifi
if ($EUID==0) {
	my @cmd=`iwconfig`;
	my @cmd_grep = grep (/ESSID/,@cmd);
	if (@cmd_grep) {
		$cmd_grep[0] =~ s/....................................................$//;
		chomp($cmd_grep[0]);
		if ($cmd_grep[0]) {$interf=$cmd_grep[0]} else {$interf="wlan0"}
	} else {$interf="wlan0"}
} else {$interf="wlan0"}
### 

$window->signal_connect('delete_event' 	, sub {Gtk2->main_quit();}	);
$window->signal_connect('destroy_event' , \&Destroy					);

$window->set_border_width(5) ;

my @menu_items = (
	#["/_Fichier", undef,
	#	0, 0, "<Branch>"				],
	["/Fichier/_Ouvrir un profil", "<control>O",
		\&file_open, 0, "<StockItem>", 'file'		],
	["/Fichier/_Sauvegarder un profil", "<control>S",
		\&file_sauv, 0, "<StockItem>", 'file'		],
	["/Fichier/_Quitter", "<control>Q",
		\&on_quitter, 0, "<StockItem>", 'gtk-quit'	],
	#["/_Aide", undef,
	#	0, 0, "<Branch>"							],
	["/Aide/_A propos", undef,
		\&on_about, 0, "<StockItem>", 'gtk-about'	]
);

my $raccourci_clavier_group = Gtk2::AccelGroup->new();
#Création du Menu
my $item_factory = Gtk2::ItemFactory->new(
	"Gtk2::MenuBar",
	"<main>",
	$raccourci_clavier_group
);
#Récupération des éléments du menu
$item_factory->create_items($window,@menu_items);
#Récupération du widget
my $menubar = $item_factory->get_widget("<main>");

my $adj = Gtk2::Adjustment->new(11.0, 1.0, 14.0, 1.0, 5.0, 0.0 );

my $label_modes 		= Gtk2::Label->new('Modes');
my $checkb_mode_managed = Gtk2::RadioButton->new(undef,'Managed');
my $checkb_mode_Group 	= $checkb_mode_managed->get_group();
my $checkb_mode_adhoc 	= Gtk2::RadioButton->new($checkb_mode_Group,'Ad-Hoc') ;
my $checkb_mode_repeater= Gtk2::RadioButton->new($checkb_mode_Group,'Repeater') ;
my $checkb_mode_monitor = Gtk2::RadioButton->new($checkb_mode_Group,'Monitor') ;
my $checkb_mode_auto 	= Gtk2::RadioButton->new($checkb_mode_Group,'Auto') ;
my $label_channel 		= Gtk2::Label->new('Channel');
my $spinner_channel 	= Gtk2::SpinButton->new($adj, 0, 0);
my $label_essid 		= Gtk2::Label->new('Essid');
my $entry_essid 		= Gtk2::Entry->new();
my $label_key 			= Gtk2::Label->new('Key(WEP)');
my $entry_key 			= Gtk2::Entry->new();
my $button_quitter 		= Gtk2::Button->new('Quitter') ;
my $button_valider 		= Gtk2::Button->new('Valider') ;
my $label_interf 		= Gtk2::Label->new();
$label_interf->set_markup("<span><b>Interface a configuer</b></span>\n");
my $entry_interf 		= Gtk2::Entry->new();
$entry_interf->insert_text($interf,0);

$button_valider->signal_connect('clicked', \&syst,$checkb_mode_managed);
$button_quitter->signal_connect('clicked', \&Destroy) ;
$entry_essid->signal_connect(
	'changed',
	sub{my ($widget) = @_; $essid = $widget->get_text();}
);
$spinner_channel->signal_connect(
	'changed',
	sub {my($widget) = @_; $channel=$widget->get_value_as_int();}
);
$entry_key->signal_connect(
	'changed',
	sub {my($widget) = @_; $key=$widget->get_text();}
);
$entry_interf->signal_connect(
	'changed',
	sub {my($widget) = @_; $interf=$widget->get_text();}
);

my $table = Gtk2::Table->new( 6 , 7 , TRUE );
$window->add($table);

$table->attach_defaults($menubar				, 0, 7, 0, 1);
$table->attach_defaults($label_interf			, 0, 5, 1, 2);
$table->attach_defaults($entry_interf			, 5, 7, 1, 2);
$table->attach_defaults($label_modes			, 0, 2, 2, 3);
$table->attach_defaults($checkb_mode_managed	, 2, 3, 2, 3);
$table->attach_defaults($checkb_mode_adhoc		, 3, 4, 2, 3);
$table->attach_defaults($checkb_mode_repeater	, 4, 5, 2, 3);
$table->attach_defaults($checkb_mode_monitor	, 5, 6, 2, 3);
$table->attach_defaults($checkb_mode_auto		, 6, 7, 2, 3);
$table->attach_defaults($label_channel			, 0, 3, 3, 4);
$table->attach_defaults($spinner_channel		, 3, 4, 3, 4);
$table->attach_defaults($label_essid			, 4, 5, 3, 4);
$table->attach_defaults($entry_essid			, 5, 7, 3, 4);
$table->attach_defaults($label_key				, 0, 3, 4, 5);
$table->attach_defaults($entry_key				, 3, 7, 4, 5);
$table->attach_defaults($button_quitter			, 4, 7, 5, 6);
$table->attach_defaults($button_valider			, 0, 3, 5, 6);

$window->add_accel_group($raccourci_clavier_group);

$window->show_all();

Gtk2->main ;

#Cette fonction est appelée au debut du proramme pour charger le fichier de
#configuration
sub load_conf{
	if (!open(FIC_OPEN_CONF, '/etc/gwifi.conf')) {
		die ("open: $!");
		printf ("impossible de lire le fichier : /etc/gwifi.conf\n");
	}
	my @commande_file = split(/'/, <FIC_OPEN_CONF>);

	return ($commande_file[1]);
}

#Cette fonction est appelée par le menu et permet de quitter Gwifi
sub on_quitter{
	#my ($widget,$window) = @_; 
	##$window=0 regarder si la fonction renvoi bien $window du main
	my $dialog = Gtk2::MessageDialog->new(
		$window,
		[qw/modal destroy-with-parent/],
		'question',
			'yes_no',
		'Voulez-vous vraiment'."\n".'quitter Gwifi?'
	);
	my $reponse = $dialog->run();
	if ($reponse eq "yes") {Destroy()} else {$dialog->destroy()}
}	

#Cette fonction est appelée par le menu et permet d'afficher les infomations
#consernant Gwifi
sub on_about{
	#my ($widget,$window) = @_; 
	##$window=0 regarder si la fonction renvoi bien $window du main
	my $dialog_about = Gtk2::MessageDialog->new(
		$window,
		[qw/modal destroy-with-parent/],
		'info',
		'ok',
		"Gwifi 0.50.0\nunder GPL License\nby David PIRY\nklessou\@gmail.com"
	);
	$dialog_about->run();
	$dialog_about->destroy()
}

sub save_setting{
	my ($widget, $file_sauv_dialog) = @_;
	my $file_sauv = $file_sauv_dialog->get_filename();
	
	#Creation d'un fichier s'il n'existe pas.
	unless (-e $file_sauv) {
		system("touch $file_sauv")
	}
	
	#Ouverture du fichier
	if (! open(FIC_SAUV, ">" . $file_sauv)) {
		die ("open: $!");
		my $dialog_open_file = 
			Gtk2::MessageDialog->new(
				$window,
				[qw/modal destroy-with-parent/],
				'info',
				'ok',
				'Impossible d\'ouvrir le fichier : '
					.$file_sauv
			);
		printf ("impossible de lire le fichier : $file_sauv\n");
	}
	
	#Recherche dans le tableau group le widget actif
	foreach my $but (@$checkb_mode_Group) {
		if ($but->get_active) {$mode=$but->get_label()}
	}
	print("i = $interf, m = $mode, c = $channel, e = $essid, k = $key");
	printf (FIC_SAUV 'interface = "'.$interf.'"'."\n"	);
	printf (FIC_SAUV 'mode = "'.$mode.'"'."\n"			);
	printf (FIC_SAUV 'changed = "'.$channel.'"'."\n"	);
	printf (FIC_SAUV 'essid = "'.$essid.'"'."\n"		);
	printf (FIC_SAUV 'key = "'.$key.'"'."\n"			);
	$file_sauv_dialog->destroy();
}

sub file_sauv{
	my $file_sauv_dialog = Gtk2::FileSelection->new('Sauvegarder votre profil');
	$file_sauv_dialog->signal_connect("destroy", sub{Gtk2->main();});
	
	#Connecte le bouton Ok à la fonction save_setting
	$file_sauv_dialog->ok_button->signal_connect(
		"clicked",
		\&save_setting,
		$file_sauv_dialog
	);
	
	#Connecte le bouton Cancel à la fonction qui détruit le widget
	$file_sauv_dialog->cancel_button->signal_connect(
		"clicked",
		sub{$file_sauv_dialog->destroy();}
	);
	$file_sauv_dialog->show();
}
sub load_setting{
	my ($widget, $file_sauv_dialog) = @_;
	my $file_open = $file_sauv_dialog->get_filename();
	
	#Ouverture du fichier
	if (!open(FIC_OPEN, $file_open)) {
		die ("open: $!");
		my $dialog_open_file = 
			Gtk2::MessageDialog->new(
				$window,
				[qw/modal destroy-with-parent/],
				'info',
				'ok',
				'Impossible d\'ouvrir le fichier : '
				.$file_open
			);
		printf ("impossible de lire le fichier : $file_open\n");
	}
	
	my @tableau_file = <FIC_OPEN>;

	my @interf_file	= split(/"/, $tableau_file[0]);
	$entry_interf->set_text($interf_file[1]);
	my @essid_file	= split(/"/, $tableau_file[3]);
	$entry_essid->set_text($essid_file[1]);
	my @key_file	= split(/"/, $tableau_file[4]);
	$entry_key->set_text($key_file[1]);
	my @channel_file= split(/"/, $tableau_file[2]);
	$spinner_channel->set_value($channel_file[1]);
	my @mode_file= split(/"/, $tableau_file[1]);
	if($mode_file[1] eq "Managed")		{$checkb_mode_managed->set_active(1)	}
	elsif($mode_file[1] eq "Ad_Hoc")	{$checkb_mode_managed->set_active(1)	}
	elsif($mode_file[1] eq "Repeater")	{$checkb_mode_repeater->set_active(1)	}
	elsif($mode_file[1] eq "Monitor")	{$checkb_mode_monitor->set_active(1)	}
	elsif($mode_file[1] eq "Auto")		{$checkb_mode_managed->set_active(1)	}
	
	$file_sauv_dialog->destroy();
}

sub file_open{
	my $file_sauv_dialog = Gtk2::FileSelection->new('Sauvegarder votre profil');
	$file_sauv_dialog->signal_connect("destroy", sub{Gtk2->main();});
	
	#Connecte le bouton Ok à la fonction save_setting
	$file_sauv_dialog->ok_button->signal_connect("clicked", \&load_setting, $file_sauv_dialog);
	
	#Connecte le bouton Cancel à la fonction qui détruit le widget
	$file_sauv_dialog->cancel_button->signal_connect("clicked", sub{$file_sauv_dialog->destroy();});
	$file_sauv_dialog->show();
}

sub syst{
	my ($widget,$radio) = @_;
	my $checkb_mode_Group = $radio->get_group();
	
	#il sera peut-être intressant de faire les appels à cette 
	#messagebox à travers une fonction
	my $dialog_root = Gtk2::MessageDialog->new($window,
		[qw/modal destroy-with-parent/],
		'info',
		'ok',
		'Il faut etre en root pour utiliser Gwifi!\n'
			.'Ou installer gksu (emerge gksu, 
			aptget install gksu, urpmi gksu, ...)'."\n"
	);

#Vérification : les champs sont-ils remplis (pour éviter d'avoir les valeurs par 
#defaut des variables modifiées)
	unless ($essid) 	{$essid = 'any'	}
	unless ($key)		{$key	= 'off'	}
	unless ($interf)	{
		printf "remplir le champ interface\n";
		my $dialog_interf = Gtk2::MessageDialog->new(
			$window,
			[qw/modal destroy-with-parent/],
			'info',
			'ok',
			"Veuillez inserer l'interface."
		);
		my $reponse = $dialog_interf->run();
		if ($reponse eq "yes") {Destroy()} else {$dialog_interf->destroy()}
		return FALSE;
	}
	#Initialisation de la commande :
	my $commande_conf='';
	my @elem_commande=split(/"/,$commande_file);
	#mise en relation des variables, attention on considère qu'il est
	#impossible d'avoir plusieur variables cote à cote.
	foreach my $elem (@elem_commande){
		if ($elem eq 'interf') {
			$commande_conf=$commande_conf.$interf;
		}
		elsif ($elem eq 'essid') {
			$commande_conf=$commande_conf.$essid;
		}
		elsif ($elem eq 'mode') {
			$commande_conf=$commande_conf.$mode;
		}
		elsif ($elem eq 'channel') {
			$commande_conf=$commande_conf.$channel;
		}
		elsif ($elem eq 'key') {
			$commande_conf=$commande_conf.$key;
		}
		else { $commande_conf=$commande_conf.$elem}
	}
		
#Recherche dans le tableau group le widget actif
	foreach my $but (@$checkb_mode_Group) {
		if ($but->get_active) {$mode=$but->get_label()}
	}
	
#Lancement des commandes inscritent dans le fichier de configuration	
	unless ($EUID==0) {	
		if (-e '/usr/bin/gksu') {
			print('gksu -m "Veuillez saisir votre mot de passe root" "'.$commande_conf.'"');
			system(
				'gksu -m "Veuillez saisir votre mot de passe root" "'."$commande_conf".'"'				
			);
		} else {
			$dialog_root->run();
			$dialog_root->destroy();
			printf 'Il faut etre en root pour utiliser Gwifi! 
				Ou installer gksu (emerge gksu, aptget install
				gksu, urpmi gksu, ...)'."\n";
		}
	} else {system("$commande_conf")}
}

sub Destroy{
	Gtk2->main_quit;
	return FALSE;
}
