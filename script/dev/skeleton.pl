#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin::libs;
use autodie;
use SecretProject::Models;

use Text::MicroTemplate::DataSectionEx;
use String::CamelCase qw/camelize decamelize/;
use Getopt::Long;
use Pod::Usage;

=head1 SYNOPSIS

    script/dev/skeleton.pl controller Controller::Name
    script/dev/skeleton.pl schema TableName
    script/dev/skeleton.pl view ViewName
    script/dev/skeleton.pl module Module::Name
    script/dev/skeleton.pl script batch/name

    Options:
       -help    brief help message

=cut

my $help;
GetOptions('h|help' => \$help);
pod2usage(1) if $help;

my ($type, $name) = @ARGV;
pod2usage(1) if !$name;

$type = lc $type;

my $config = +{
    controller  => {
        dirs  => [qw/lib SecretProject Controller/],
    },
    schema      => {
        dirs => [qw/lib SecretProject Schema Result/],
    },
    view        => {
        dirs => [qw/lib SecretProject View/],
    },
    module      => {
        dirs => [qw/lib/],
    },
    script  => {
        dirs  => [qw/script/],
        ext     => 'pl',
    },
}->{$type};

die "no definition for $type" unless $config;

my @dirs = @{$config->{dirs}};
my $ext = $config->{ext} || 'pm';

$name = camelize $name if $type ~~ [qw/controller schema/];
my $decamelized = decamelize($name);
$decamelized =~ s!::!/!g;

my $params = +{
    name        => $name,
    decamelized => $decamelized,
};

my $template = Text::MicroTemplate::DataSectionEx->new(
    template_args => $params,
)->render_mt($type);

my @file_dirs = split m!(?:(?:::)|/)!, $name;
my $file = pop @file_dirs;
$file .= ".$ext";
push @dirs, @file_dirs;

my $dir = models('home')->subdir(@dirs);
$dir->mkpath unless -d $dir;
$dir->file($file)->openw->write($template);

__DATA__

@@ controller.mt
package SecretProject::Controller::<?= $name ?>;
use Ark 'Controller';

use SecretProject::Models;
has '+namespace' => default => '<?= $decamelized ?>';

sub auto :Private {
    1;
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;
}

__PACKAGE__->meta->make_immutable;

@@ schema.mt
package SecretProject::Schema::Result::<?= $name ?>;

use strict;
use warnings;
use utf8;
use parent qw/SecretProject::Schema::ResultBase/;

use SecretProject::Schema::Types;
use SecretProject::Models;

__PACKAGE__->table('<?= $decamelized ?>');
__PACKAGE__->add_columns(
    id => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        is_auto_increment => 1,
        extra => {
            unsigned => 1,
        },
    },
);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    # $sqlt_table->add_index( fields => [qw//]);
    $self->next::method($sqlt_table);
}

__PACKAGE__->set_primary_key('id');

1;

@@ view.mt
package SecretProject::View::<?= $name ?>;
use Ark 'View::<?= $name ?>';

__PACKAGE__->meta->make_immutable;

@@ module.mt
package <?= $name ?>;

use strict;
use warnings;
use utf8;

1;

@@ script.mt
#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use SecretProject::Models;
use Getopt::Long;
use Pod::Usage;

local $| = 1;

=head1 DESCRIPTION


=head1 SYNOPSIS

    script/<?= $name ?>.pl

    Options:
       -help            brief help message

=cut

my $help;
GetOptions(
    'h|help'          => \$help,
) or die pod2usage;
pod2usage(1) if $help;

1;
