use CCfn;

package CloudDeploy::Examples::InstanceInVPCWithPublicIpParams {
  use Moose;
  use CCfnX::Attachments;
  extends 'CCfnX::CommonArgs';

  has ami          => (is => 'ro', isa => 'Str', required => 1);
  has instancetype => (is => 'ro', isa => 'Str', default => 't2.nano');

  attachment Network => (
    documentation => 'The network to attach to',
    type          => 'CloudDeploy::Examples::BaseNetwork',
    provides      => {
      Subnet0 => 'net/public/0/id',
      Subnet1 => 'net/public/1/id',
      VPC     => 'vpc/id',
    },
  );
};


package CloudDeploy::Examples::InstanceInVPCWithPublicIp {
  use Moose;
  extends 'CCfn';
  use CCfnX::Shortcuts;

  has params => (
    is  => 'ro',
    isa => 'CloudDeploy::Examples::InstanceInVPCWithPublicIpParams',
    default => sub {
      CloudDeploy::Examples::InstanceInVPCWithPublicIpParams->new_with_options()
  });


  resource MyInstance => 'AWS::EC2::Instance', {
    ImageId           => Parameter('ami'),
    InstanceType      => Parameter('instancetype'),
    NetworkInterfaces => [{
      AssociatePublicIpAddress => 'true',
      DeviceIndex => '0',
      GroupSet    => [ Ref('MySG') ],
      SubnetId    => Ref('Subnet0'),
    }],
  };

  resource MySG => 'AWS::EC2::SecurityGroup', {
    GroupDescription     => "MyInstance SG",
    SecurityGroupIngress => [
      SGRule(80, '0.0.0.0/0'),
    ],
    VpcId => Ref('VPC'),
  };


  output 'Instance/PublicIp' => GetAtt('MyInstance', 'PublicIp');
};


