use CCfn;

package CloudDeploy::Examples::InstanceParams {
  use Moose;
  extends 'CCfnX::CommonArgs';

  has ami          => (is => 'ro', isa => 'Str', required => 1);
  has instancetype => (is => 'ro', isa => 'Str', default => 't2.nano');
};


package CloudDeploy::Examples::Instance {
  use Moose;
  extends 'CCfn';
  use CCfnX::Shortcuts;

  has params => (
    is  => 'ro',
    isa => 'CloudDeploy::Examples::InstanceParams',
    default => sub {
      CloudDeploy::Examples::InstanceParams->new_with_options()
  });

  resource MyInstance => 'AWS::EC2::Instance', {
    ImageId      => Parameter('ami'),
    InstanceType => Parameter('instancetype'),
    SecurityGroups => [ Ref('MySG') ],
  };

  resource MySG => 'AWS::EC2::SecurityGroup', {
    GroupDescription     => "Test Instance SG 1",
    SecurityGroupIngress => [
      SGRule(80, '0.0.0.0/0'),
    ],
  };
};


