use Cfn;
use CCfn;

package CloudDeploy::Examples::VPCParams {
  use Moose;
  extends 'CCfnX::CommonArgs';
}

package CloudDeploy::Examples::VPC {
  use Moose;
  extends 'CCfn';
  use CCfnX::Shortcuts;

  has params => (is => 'ro', isa => 'CloudDeploy::Examples::VPCParams', default => sub { CloudDeploy::Examples::VPCParams->new_with_options(); } );

  resource VPC => 'AWS::EC2::VPC', {
    CidrBlock => '10.0.0.0/16',
    EnableDnsSupport => 'true',
    EnableDnsHostnames => 'true',
  };

  resource PublicNetAz1  => 'AWS::EC2::Subnet', {
    AvailabilityZone => { 'Fn::Select' => [ 0, { "Fn::GetAZs" => "" } ] },
    CidrBlock => '10.0.0.0/20',
    VpcId => Ref('VPC')
  };

  resource PublicNetAz2  => 'AWS::EC2::Subnet', {
    AvailabilityZone => { 'Fn::Select' => [ 1, { "Fn::GetAZs" => "" } ] },
    CidrBlock => '10.0.16.0/20',
    VpcId => Ref('VPC')
  };

  resource IGW => 'AWS::EC2::InternetGateway', {};

  resource IGWAttachment => 'AWS::EC2::VPCGatewayAttachment', {
    InternetGatewayId => Ref('IGW'),
    VpcId => Ref('VPC')
  };

  resource AttachPublicAz1ToRoute => 'AWS::EC2::SubnetRouteTableAssociation', {
    RouteTableId => Ref('PublicNetRoutes'),
    SubnetId => Ref('PublicNetAz1'),
  };

  resource AttachPublicAz2ToRoute => 'AWS::EC2::SubnetRouteTableAssociation', {
    RouteTableId => Ref('PublicNetRoutes'),
    SubnetId => Ref('PublicNetAz2'),
  };

  resource PublicNetRoutes => 'AWS::EC2::RouteTable', {
    VpcId => Ref('VPC'),
  };

  resource RouteToInternet => 'AWS::EC2::Route', {
    DestinationCidrBlock => '0.0.0.0/0',
    GatewayId => Ref('IGW'),
    RouteTableId => Ref('PublicNetRoutes')
  };

  resource PrivateNetAz1  => 'AWS::EC2::Subnet', {
    AvailabilityZone => { 'Fn::Select' => [ 0, { "Fn::GetAZs" => "" } ] },
    CidrBlock => '10.0.32.0/20',
    VpcId => Ref('VPC')
  };

  resource PrivateNetAz2  => 'AWS::EC2::Subnet', {
    AvailabilityZone => { 'Fn::Select' => [ 1, { "Fn::GetAZs" => "" } ] },
    CidrBlock => '10.0.48.0/20',
    VpcId => Ref('VPC')
  };

  output 'vpc/region' => Ref('AWS::Region');
  output 'vpc/id'     => Ref('VPC');

  output 'net/public/0/id'  => Ref('PublicNetAz1');
  output 'net/public/1/id'  => Ref('PublicNetAz2');
  output 'net/private/0/id' => Ref('PrivateNetAz1');
  output 'net/private/1/id' => Ref('PrivateNetAz2');

  output 'net/public/0/az'  => GetAtt('PublicNetAz1', 'AvailabilityZone');
  output 'net/public/1/az'  => GetAtt('PublicNetAz2', 'AvailabilityZone');
  output 'net/private/0/az' => GetAtt('PrivateNetAz1', 'AvailabilityZone');
  output 'net/private/1/az' => GetAtt('PrivateNetAz2', 'AvailabilityZone');
}
