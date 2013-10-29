use lib 'lib';

use Plack::Builder;
use SecretProject;
use SecretProject::Models;

my $app = SecretProject->new;
$app->setup;

# preload models
my $models = SecretProject::Models->instance;
$models->load_all;

my $app = SecretProject->new;
builder {
    $app->handler;
};
