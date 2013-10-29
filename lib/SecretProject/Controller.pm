package SecretProject::Controller;
use Ark 'Controller';
use SecretProject::Models;

# default 404 handler
sub default :Path :Args {
    my ($self, $c) = @_;

    $c->res->status(404);
    $c->res->body('404 Not Found');
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;
    $c->res->body('Ark Default Index');
}

__PACKAGE__->meta->make_immutable;
