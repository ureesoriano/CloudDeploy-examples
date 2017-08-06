use CCfn;

package CloudDeploy::Examples::InstanceInVPCWithAttachedBucketParams {
  use Moose;
  use CCfnX::Attachments;
  extends 'CCfnX::CommonArgs';

  has ami          => (is => 'ro', isa => 'Str', required => 1);
  has instancetype => (is => 'ro', isa => 'Str', default => 't2.nano');

  attachment Network => (type => 'Standard::BaseNetwork', documentation => 'The network to attach to', provides => {
    Subnet0 => 'net/public/0/id',
    Subnet1 => 'net/public/1/id',
    VPC     => 'vpc/id',
  });

  attachment Bucket => (type => 'CloudDeploy::Examples::Bucket', documentation => 'The attached Bucket', provides => {
    BucketName => 'bucket/name',
  });
};


package CloudDeploy::Examples::InstanceInVPCWithAttachedBucket {
  use Moose;
  extends 'CCfn';
  use CCfnX::Shortcuts;

  has params => (
    is  => 'ro',
    isa => 'CloudDeploy::Examples::InstanceInVPCWithAttachedBucketParams',
    default => sub {
      CloudDeploy::Examples::InstanceInVPCWithAttachedBucketParams->new_with_options()
  });


  resource MyInstance => 'AWS::EC2::Instance', {
    ImageId          => Parameter('ami'),
    InstanceType     => Parameter('instancetype'),
    SecurityGroupIds => [ Ref('MySG') ],
    SubnetId         => Ref('Subnet0'),
  };

  resource MySG => 'AWS::EC2::SecurityGroup', {
    GroupDescription     => "MyInstance SG",
    SecurityGroupIngress => [
      SGRule(80, '0.0.0.0/0'),
    ],
    VpcId => Ref('VPC'),
  };

  resource MyUser => 'AWS::IAM::User', {
  };

  resource MyUserAccessKey => 'AWS::IAM::AccessKey', {
    UserName => Ref('MyUser'),
  };

  resource MyUserPolicy => 'AWS::IAM::Policy', {
    PolicyName     => "AccessBucketObjects",
    PolicyDocument => {
      Statement => [
        {
          Effect   => 'Allow',
          Action   => [ 's3:GetObject' ],
          Resource => 'arn:aws:s3:::*',  # WATCH OUT! ALL S3 Buckets!
        },
      ],
    },
    Users => [ Ref('MyUser') ],
  };


  output 'bucket/name'           => Ref('BucketName');
  output 'bucket/user/accesskey' => Ref('MyUserAccessKey');
  output 'bucket/user/secretkey' => GetAtt('MyUserAccessKey', 'SecretAccessKey');
};


